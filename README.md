# speedtest

[speedtest](https://www.speedtest.net/apps/cli)ツールを利用したインターネット速度測定ツール。  
測定結果をspreadsheetへアップロードする  
cronで定期実行することを想定

# Requirement
- jq
- Python 3.7.10
- [requirements.txt](./requirements.txt)

# Usage
```
export SERVICE_ACCOUNT_JSON_PATH="path/to/google-service-account.json" # GCPサービスアカウント
export SPREADSHEET_KEY="xxx" # spreadsheetキー
export WORKSHEET_NAME="speedtest" # スプレッドシート シート名

bash run.sh
```

# Note
- Google Cloud Platformアカウントが必要
  - Spreadsheetへpythonでアクセスするため
- 途中で失敗するとoutputディレクトリにゴミファイルが生成されるので定期的に削除する
