/*
AIseed Gateway
高速処理を担当するAPIゲートウェイ

Copyright (c) 2026 AIseed.dev
Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
*/
package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

// ==================== 設定 ====================

type Config struct {
	DatabaseURL string
	APIServer   string
	Port        string
	DevMode     bool
}

func loadConfig() *Config {
	return &Config{
		DatabaseURL: getEnv("DATABASE_URL", "postgresql://aiseed:aiseed@localhost:5432/aiseed"),
		APIServer:   getEnv("API_SERVER", "http://localhost:8001"),
		Port:        getEnv("PORT", "8000"),
		DevMode:     getEnv("DEV_MODE", "false") == "true",
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// ==================== セッション管理 ====================

type Session struct {
	ID           string
	CreatedAt    time.Time
	LastSeenAt   time.Time
	RequestCount int
	MessageCount int
}

type SessionManager struct {
	sessions map[string]*Session
	mu       sync.RWMutex
	maxAge   time.Duration
}

func NewSessionManager(maxAge time.Duration) *SessionManager {
	sm := &SessionManager{
		sessions: make(map[string]*Session),
		maxAge:   maxAge,
	}
	go sm.cleanup()
	return sm
}

func (sm *SessionManager) CreateSession() *Session {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	bytes := make([]byte, 16)
	rand.Read(bytes)
	sessionID := "sess_" + hex.EncodeToString(bytes)

	session := &Session{
		ID:           sessionID,
		CreatedAt:    time.Now(),
		LastSeenAt:   time.Now(),
		RequestCount: 0,
		MessageCount: 0,
	}
	sm.sessions[sessionID] = session
	return session
}

func (sm *SessionManager) GetSession(sessionID string) *Session {
	sm.mu.RLock()
	defer sm.mu.RUnlock()

	session, exists := sm.sessions[sessionID]
	if !exists {
		return nil
	}

	// 期限切れチェック
	if time.Since(session.LastSeenAt) > sm.maxAge {
		return nil
	}

	return session
}

func (sm *SessionManager) UpdateSession(sessionID string) {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	if session, exists := sm.sessions[sessionID]; exists {
		session.LastSeenAt = time.Now()
		session.RequestCount++
	}
}

func (sm *SessionManager) IncrementMessageCount(sessionID string) {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	if session, exists := sm.sessions[sessionID]; exists {
		session.MessageCount++
	}
}

func (sm *SessionManager) cleanup() {
	ticker := time.NewTicker(10 * time.Minute)
	for range ticker.C {
		sm.mu.Lock()
		now := time.Now()
		for id, session := range sm.sessions {
			if now.Sub(session.LastSeenAt) > sm.maxAge {
				delete(sm.sessions, id)
			}
		}
		sm.mu.Unlock()
	}
}

// ==================== レート制限（セッション単位） ====================

type RateLimiter struct {
	requests map[string][]time.Time
	mu       sync.RWMutex
	limit    int
	window   time.Duration
}

func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
	rl := &RateLimiter{
		requests: make(map[string][]time.Time),
		limit:    limit,
		window:   window,
	}
	go rl.cleanup()
	return rl
}

func (rl *RateLimiter) Allow(sessionID string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	cutoff := now.Add(-rl.window)

	// 古いリクエストを削除
	var valid []time.Time
	for _, t := range rl.requests[sessionID] {
		if t.After(cutoff) {
			valid = append(valid, t)
		}
	}
	rl.requests[sessionID] = valid

	// 制限チェック
	if len(rl.requests[sessionID]) >= rl.limit {
		return false
	}

	// 新しいリクエストを記録
	rl.requests[sessionID] = append(rl.requests[sessionID], now)
	return true
}

func (rl *RateLimiter) cleanup() {
	ticker := time.NewTicker(5 * time.Minute)
	for range ticker.C {
		rl.mu.Lock()
		now := time.Now()
		cutoff := now.Add(-rl.window)
		for key, times := range rl.requests {
			var valid []time.Time
			for _, t := range times {
				if t.After(cutoff) {
					valid = append(valid, t)
				}
			}
			if len(valid) == 0 {
				delete(rl.requests, key)
			} else {
				rl.requests[key] = valid
			}
		}
		rl.mu.Unlock()
	}
}

// ==================== データベース ====================

var db *pgxpool.Pool

func initDB(ctx context.Context, databaseURL string) error {
	var err error
	db, err = pgxpool.New(ctx, databaseURL)
	if err != nil {
		return err
	}

	// 接続確認
	if err := db.Ping(ctx); err != nil {
		return err
	}

	log.Println("PostgreSQL接続完了")
	return nil
}

// テーブル初期化
func initTables(ctx context.Context) error {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS api_keys (
			id SERIAL PRIMARY KEY,
			key TEXT UNIQUE NOT NULL,
			user_id TEXT NOT NULL,
			plan TEXT DEFAULT 'free',
			rate_limit INTEGER DEFAULT 10,
			is_active BOOLEAN DEFAULT true,
			created_at TIMESTAMPTZ DEFAULT NOW(),
			last_used_at TIMESTAMPTZ
		)`,
		`CREATE TABLE IF NOT EXISTS conversations (
			id SERIAL PRIMARY KEY,
			session_id TEXT NOT NULL,
			user_id TEXT,
			service TEXT NOT NULL,
			role TEXT NOT NULL,
			content TEXT NOT NULL,
			created_at TIMESTAMPTZ DEFAULT NOW()
		)`,
		`CREATE TABLE IF NOT EXISTS request_logs (
			id SERIAL PRIMARY KEY,
			client_ip TEXT,
			user_id TEXT,
			endpoint TEXT NOT NULL,
			service TEXT,
			status_code INTEGER,
			response_time_ms INTEGER,
			created_at TIMESTAMPTZ DEFAULT NOW()
		)`,
		`CREATE INDEX IF NOT EXISTS idx_api_keys_key ON api_keys(key)`,
		`CREATE INDEX IF NOT EXISTS idx_conversations_session ON conversations(session_id)`,
		`CREATE INDEX IF NOT EXISTS idx_request_logs_created ON request_logs(created_at)`,
	}

	for _, q := range queries {
		if _, err := db.Exec(ctx, q); err != nil {
			return err
		}
	}

	log.Println("テーブル初期化完了")
	return nil
}

// ==================== 認証 ====================

type UserInfo struct {
	UserID    string
	Plan      string
	RateLimit int
}

func verifyAPIKey(ctx context.Context, apiKey string) (*UserInfo, error) {
	if apiKey == "" {
		return nil, nil
	}

	var userID, plan string
	var rateLimit int
	var isActive bool

	err := db.QueryRow(ctx,
		"SELECT user_id, plan, rate_limit, is_active FROM api_keys WHERE key = $1",
		apiKey,
	).Scan(&userID, &plan, &rateLimit, &isActive)

	if err != nil {
		return nil, nil // キーが見つからない
	}

	if !isActive {
		return nil, nil
	}

	// last_used_at を更新
	go func() {
		db.Exec(context.Background(),
			"UPDATE api_keys SET last_used_at = NOW() WHERE key = $1",
			apiKey,
		)
	}()

	return &UserInfo{
		UserID:    userID,
		Plan:      plan,
		RateLimit: rateLimit,
	}, nil
}

func createAPIKey(ctx context.Context, userID, plan string) (string, error) {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	apiKey := "aiseed_" + hex.EncodeToString(bytes)

	_, err := db.Exec(ctx,
		"INSERT INTO api_keys (key, user_id, plan) VALUES ($1, $2, $3)",
		apiKey, userID, plan,
	)
	if err != nil {
		return "", err
	}

	log.Printf("APIキー作成: user_id=%s, plan=%s", userID, plan)
	return apiKey, nil
}

// ==================== リクエストログ ====================

func logRequest(clientIP, userID, endpoint, service string, statusCode, responseTimeMs int) {
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		db.Exec(ctx,
			`INSERT INTO request_logs (client_ip, user_id, endpoint, service, status_code, response_time_ms)
			 VALUES ($1, $2, $3, $4, $5, $6)`,
			clientIP, userID, endpoint, service, statusCode, responseTimeMs,
		)
	}()
}

// ==================== ハンドラー ====================

type Gateway struct {
	config         *Config
	rateLimiter    *RateLimiter
	sessionManager *SessionManager
	apiClient      *http.Client
}

func NewGateway(config *Config) *Gateway {
	return &Gateway{
		config:         config,
		rateLimiter:    NewRateLimiter(100, time.Minute), // デフォルト: 100リクエスト/分
		sessionManager: NewSessionManager(24 * time.Hour), // セッション有効期限: 24時間
		apiClient: &http.Client{
			Timeout: 120 * time.Second, // AI処理は時間がかかる
		},
	}
}

// ルート
func (g *Gateway) handleRoot(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"message": "AIseed Gateway",
		"version": "1.0.0",
		"endpoints": map[string]string{
			"public":        "/public/",
			"authenticated": "/v1/",
			"admin":         "/admin/",
		},
	})
}

// ヘルスチェック
func (g *Gateway) handleHealth(c echo.Context) error {
	dbStatus := "connected"
	if err := db.Ping(c.Request().Context()); err != nil {
		dbStatus = "disconnected"
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":    "healthy",
		"database":  dbStatus,
		"timestamp": time.Now().Format(time.RFC3339),
	})
}

// Public API - セッション作成
func (g *Gateway) handlePublicSession(c echo.Context) error {
	session := g.sessionManager.CreateSession()

	log.Printf("新規セッション作成: %s", session.ID)

	return c.JSON(http.StatusOK, map[string]interface{}{
		"session_id": session.ID,
		"expires_in": 86400, // 24時間（秒）
		"message":    "セッションを作成しました",
	})
}

// Public API - 会話（認証なし、セッション単位でレート制限）
func (g *Gateway) handlePublicConversation(c echo.Context) error {
	start := time.Now()
	clientIP := c.RealIP()

	// セッションIDを取得（ヘッダーまたはボディから）
	sessionID := c.Request().Header.Get("X-Session-ID")

	// セッションがない場合は新規作成
	var session *Session
	if sessionID == "" {
		session = g.sessionManager.CreateSession()
		sessionID = session.ID
		log.Printf("自動セッション作成: %s (IP: %s)", sessionID, clientIP)
	} else {
		session = g.sessionManager.GetSession(sessionID)
		if session == nil {
			// 無効なセッションID → 新規作成
			session = g.sessionManager.CreateSession()
			sessionID = session.ID
			log.Printf("セッション再作成: %s (IP: %s)", sessionID, clientIP)
		}
	}

	// セッション単位でレート制限チェック (10リクエスト/分)
	if !g.rateLimiter.Allow(sessionID) {
		return c.JSON(http.StatusTooManyRequests, map[string]interface{}{
			"detail":     "レート制限を超過しました。1分後に再試行してください。",
			"session_id": sessionID,
		})
	}

	// セッション更新
	g.sessionManager.UpdateSession(sessionID)

	// リクエストボディを読み取り
	body, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"detail": "リクエストの読み取りに失敗しました"})
	}

	// サービスを判定して転送
	service := "spark" // デフォルト
	bodyStr := strings.ToLower(string(body))
	if strings.Contains(bodyStr, "野菜") || strings.Contains(bodyStr, "栽培") || strings.Contains(bodyStr, "料理") {
		service = "grow"
	} else if strings.Contains(bodyStr, "ai") || strings.Contains(bodyStr, "人工知能") || strings.Contains(bodyStr, "機械学習") {
		service = "learn"
	} else if strings.Contains(bodyStr, "web") || strings.Contains(bodyStr, "サイト") || strings.Contains(bodyStr, "ホームページ") {
		service = "create"
	}

	// メッセージカウント増加
	g.sessionManager.IncrementMessageCount(sessionID)

	// Python APIに転送
	resp, err := g.proxyToAPI(c, "/internal/"+service+"/conversation", body)
	if err != nil {
		log.Printf("API転送エラー: %v", err)
		return c.JSON(http.StatusBadGateway, map[string]string{"detail": "APIサーバーに接続できません"})
	}

	// ログ記録（セッションIDも記録）
	logRequest(clientIP, sessionID, "/public/conversation", service, resp.StatusCode, int(time.Since(start).Milliseconds()))

	// レスポンスにセッションIDを含める
	return g.sendProxyResponseWithSession(c, resp, sessionID)
}

// v1 API ミドルウェア（認証）
func (g *Gateway) authMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		apiKey := c.Request().Header.Get("X-API-Key")

		// 開発モード
		if g.config.DevMode {
			if apiKey == "" {
				c.Set("user", &UserInfo{UserID: "dev", Plan: "dev", RateLimit: 100})
				return next(c)
			}
		}

		// APIキー検証
		user, err := verifyAPIKey(c.Request().Context(), apiKey)
		if err != nil || user == nil {
			if g.config.DevMode {
				c.Set("user", &UserInfo{UserID: "dev", Plan: "dev", RateLimit: 100})
				return next(c)
			}
			return c.JSON(http.StatusUnauthorized, map[string]string{"detail": "無効なAPIキーです"})
		}

		// レート制限チェック
		if !g.rateLimiter.Allow("user:" + user.UserID) {
			return c.JSON(http.StatusTooManyRequests, map[string]string{
				"detail": "レート制限を超過しました。",
			})
		}

		c.Set("user", user)
		return next(c)
	}
}

// v1 API - 会話エンドポイント
func (g *Gateway) handleV1Conversation(service string) echo.HandlerFunc {
	return func(c echo.Context) error {
		start := time.Now()
		user := c.Get("user").(*UserInfo)

		body, err := io.ReadAll(c.Request().Body)
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{"detail": "リクエストの読み取りに失敗しました"})
		}

		// Python APIに転送
		resp, err := g.proxyToAPI(c, "/internal/"+service+"/conversation", body)
		if err != nil {
			log.Printf("API転送エラー: %v", err)
			return c.JSON(http.StatusBadGateway, map[string]string{"detail": "APIサーバーに接続できません"})
		}

		// ログ記録
		logRequest(c.RealIP(), user.UserID, "/v1/"+service+"/conversation", service, resp.StatusCode, int(time.Since(start).Milliseconds()))

		return g.sendProxyResponse(c, resp)
	}
}

// v1 API - 分析
func (g *Gateway) handleV1Analyze(c echo.Context) error {
	start := time.Now()
	user := c.Get("user").(*UserInfo)

	body, err := io.ReadAll(c.Request().Body)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"detail": "リクエストの読み取りに失敗しました"})
	}

	resp, err := g.proxyToAPI(c, "/internal/analyze", body)
	if err != nil {
		return c.JSON(http.StatusBadGateway, map[string]string{"detail": "APIサーバーに接続できません"})
	}

	logRequest(c.RealIP(), user.UserID, "/v1/analyze", "spark", resp.StatusCode, int(time.Since(start).Milliseconds()))

	return g.sendProxyResponse(c, resp)
}

// Admin API - APIキー作成
func (g *Gateway) handleAdminCreateAPIKey(c echo.Context) error {
	if !g.config.DevMode {
		return c.JSON(http.StatusForbidden, map[string]string{"detail": "開発モードでのみ利用可能"})
	}

	var req struct {
		UserID string `json:"user_id"`
		Plan   string `json:"plan"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"detail": "無効なリクエスト"})
	}

	if req.Plan == "" {
		req.Plan = "free"
	}

	apiKey, err := createAPIKey(c.Request().Context(), req.UserID, req.Plan)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"detail": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"api_key": apiKey,
		"user_id": req.UserID,
		"plan":    req.Plan,
	})
}

// Admin API - 統計情報
func (g *Gateway) handleAdminStats(c echo.Context) error {
	if !g.config.DevMode {
		return c.JSON(http.StatusForbidden, map[string]string{"detail": "開発モードでのみ利用可能"})
	}

	ctx := c.Request().Context()
	stats := make(map[string]interface{})

	// APIキー数
	var apiKeyCount int
	db.QueryRow(ctx, "SELECT COUNT(*) FROM api_keys").Scan(&apiKeyCount)
	stats["total_api_keys"] = apiKeyCount

	// 会話数
	var convCount int
	db.QueryRow(ctx, "SELECT COUNT(*) FROM conversations").Scan(&convCount)
	stats["total_conversations"] = convCount

	// リクエスト数
	var reqCount int
	db.QueryRow(ctx, "SELECT COUNT(*) FROM request_logs").Scan(&reqCount)
	stats["total_requests"] = reqCount

	// サービス別リクエスト数
	rows, _ := db.Query(ctx, "SELECT service, COUNT(*) FROM request_logs WHERE service IS NOT NULL GROUP BY service")
	defer rows.Close()

	byService := make(map[string]int)
	for rows.Next() {
		var service string
		var count int
		rows.Scan(&service, &count)
		byService[service] = count
	}
	stats["requests_by_service"] = byService

	return c.JSON(http.StatusOK, stats)
}

// プロキシヘルパー
func (g *Gateway) proxyToAPI(c echo.Context, path string, body []byte) (*http.Response, error) {
	req, err := http.NewRequestWithContext(
		c.Request().Context(),
		"POST",
		g.config.APIServer+path,
		strings.NewReader(string(body)),
	)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")

	return g.apiClient.Do(req)
}

func (g *Gateway) sendProxyResponse(c echo.Context, resp *http.Response) error {
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"detail": "レスポンスの読み取りに失敗しました"})
	}

	return c.JSONBlob(resp.StatusCode, body)
}

func (g *Gateway) sendProxyResponseWithSession(c echo.Context, resp *http.Response, sessionID string) error {
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"detail": "レスポンスの読み取りに失敗しました"})
	}

	// セッションIDをレスポンスヘッダーに追加
	c.Response().Header().Set("X-Session-ID", sessionID)

	return c.JSONBlob(resp.StatusCode, body)
}

// ==================== メイン ====================

func main() {
	config := loadConfig()

	// データベース初期化
	ctx := context.Background()
	if err := initDB(ctx, config.DatabaseURL); err != nil {
		log.Fatalf("データベース接続エラー: %v", err)
	}
	defer db.Close()

	if err := initTables(ctx); err != nil {
		log.Fatalf("テーブル初期化エラー: %v", err)
	}

	// Echo初期化
	e := echo.New()
	e.HideBanner = true

	// ミドルウェア
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Gateway初期化
	gw := NewGateway(config)

	// ルーティング
	e.GET("/", gw.handleRoot)
	e.GET("/health", gw.handleHealth)

	// Public API
	public := e.Group("/public")
	public.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]interface{}{
			"message":  "AIseed Public API",
			"status":   "running",
			"services": map[string]string{
				"spark":  "対話から能力と「らしさ」を発見",
				"grow":   "伝統野菜の栽培・料理アドバイス",
				"learn":  "AIと一緒にAIの使い方を学ぶ",
				"create": "会話だけでWebサイト等を作成",
			},
			"note": "Web用の制限付きAPI（セッション単位で管理）",
		})
	})
	public.POST("/session", gw.handlePublicSession)
	public.POST("/conversation", gw.handlePublicConversation)

	// v1 API（認証必須）
	v1 := e.Group("/v1")
	v1.Use(gw.authMiddleware)
	v1.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]interface{}{
			"message":  "AIseed Authenticated API v1",
			"status":   "running",
			"services": map[string]string{
				"spark":  "対話から能力と「らしさ」を発見",
				"grow":   "伝統野菜の栽培・料理アドバイス",
				"learn":  "AIと一緒にAIの使い方を学ぶ",
				"create": "会話だけでWebサイト等を作成",
			},
			"note": "認証が必要なAPI（個人データ保存）",
		})
	})
	v1.POST("/spark/conversation", gw.handleV1Conversation("spark"))
	v1.POST("/grow/conversation", gw.handleV1Conversation("grow"))
	v1.POST("/create/conversation", gw.handleV1Conversation("create"))
	v1.POST("/learn/conversation", gw.handleV1Conversation("learn"))
	v1.POST("/analyze", gw.handleV1Analyze)

	// Admin API
	admin := e.Group("/admin")
	admin.POST("/api-keys", gw.handleAdminCreateAPIKey)
	admin.GET("/stats", gw.handleAdminStats)

	// サーバー起動
	log.Printf("AIseed Gateway 起動: :%s (DEV_MODE=%v)", config.Port, config.DevMode)
	if err := e.Start(":" + config.Port); err != nil {
		log.Fatalf("サーバー起動エラー: %v", err)
	}
}
