FROM golang:1.22-alpine AS builder

WORKDIR /app

# 依存関係インストール
COPY go.mod go.sum* ./
RUN go mod download

# ビルド
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o gateway .

# 実行用イメージ
FROM alpine:3.19

WORKDIR /app

# 必要なパッケージ
RUN apk --no-cache add ca-certificates tzdata

# バイナリコピー
COPY --from=builder /app/gateway .

# 非rootユーザーで実行
RUN adduser -D appuser
USER appuser

# ポート公開
EXPOSE 8000

# 起動コマンド
CMD ["./gateway"]
