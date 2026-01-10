# AIseed プロンプトリサーチ

AIseedが開発するアプリで使用するAIプロンプトの研究・改善を行います。

## 目的

ユーザーが自分のAI（ChatGPT、Claude、Gemini等）で情報を調べる際に、**最も効果的なプロンプト**を提供する。

## 原則

1. **ユーザーのAIを使う** - APIコストをかけず、ユーザー自身のAIサブスクリプションを活用
2. **コピペで使える** - 難しい操作なしで、そのまま貼り付けられる
3. **日本語・英語対応** - 両言語でのプロンプトを用意
4. **継続的改善** - フィードバックを基にプロンプトを改善

## リサーチプロセス

```
1. 仮説プロンプト作成
      ↓
2. 複数AIでテスト（ChatGPT, Claude, Gemini）
      ↓
3. 回答品質を評価
      ↓
4. プロンプト改善
      ↓
5. アプリに反映
```

## 評価基準

| 基準 | 説明 |
|------|------|
| 正確性 | 事実に基づいた情報か |
| 実用性 | 実際の栽培に役立つか |
| 具体性 | 具体的なアクションに繋がるか |
| 一貫性 | 複数のAIで同様の品質が得られるか |
| 理解しやすさ | 初心者でも理解できるか |

## ディレクトリ構成

```
docs/prompt-research/
├── README.md           # このファイル
├── grow/               # Growアプリ用プロンプト
│   ├── soil.md         # 土壌関連
│   ├── climate.md      # 気候・栽培カレンダー
│   ├── plant-care.md   # 栽培方法
│   ├── pest-disease.md # 病害虫
│   └── test-results/   # テスト結果
└── templates/          # 汎用テンプレート
    └── research-template.md
```

## 貢献方法

1. 新しいプロンプトを提案 → `docs/prompt-research/proposals/`
2. テスト結果を報告 → `docs/prompt-research/*/test-results/`
3. 改善案をIssueで議論

## 関連ファイル

- Growアプリのプロンプト実装: `grow/frontend/grow/lib/shared/data/ai_research_prompts.dart`
