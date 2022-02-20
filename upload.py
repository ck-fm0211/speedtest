import os
import sys
from datetime import date
import csv
import gspread
from oauth2client.service_account import ServiceAccountCredentials

scope = [
    'https://spreadsheets.google.com/feeds',
    'https://www.googleapis.com/auth/drive'
]

SERVICE_ACCOUNT_JSON_PATH = os.getenv('SERVICE_ACCOUNT_JSON_PATH') # GCPサービスアカウントのキー
SPREADSHEET_KEY = os.getenv('SPREADSHEET_KEY') # 操作したいスプレッドシートの名前を指定する
WORKSHEET_NAME = os.getenv('WORKSHEET_NAME') # シートを指定する

credentials = ServiceAccountCredentials.from_json_keyfile_name(SERVICE_ACCOUNT_JSON_PATH, scope)
client = gspread.authorize(credentials)

if __name__ == "__main__":

    filename = sys.argv[1]

    spreadsheet = client.open_by_key(SPREADSHEET_KEY)
    worksheet = spreadsheet.worksheet(WORKSHEET_NAME)

    data = []

    with open(f'output/{filename}', encoding='utf-8', newline='') as f:
        for cols in csv.reader(f, delimiter='\t'):
            worksheet.append_row(cols, value_input_option='USER_ENTERED') # dataを最終行に挿入

