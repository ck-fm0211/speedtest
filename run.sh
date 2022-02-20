#!/bin/bash

set -e

# 現在時刻を取得
echo "== start =="
NOW=`date +%Y%m%d%H%M%S`
echo ${NOW}

# 結果ファイル
RESULT_FILENAME_JSON=result_${NOW}.json
RESULT_FILENAME_TSV=result_${NOW}.tsv

# speedtestの結果を出力
echo "== exec speedtest =="
speedtest -L | grep "OPEN Project" | awk '{print $1}' | xargs -I{} speedtest -f json -s {} > output/${RESULT_FILENAME_JSON}

echo "== parse result =="
cat output/${RESULT_FILENAME_JSON} \
| jq -r '. | [(.timestamp | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime + (60 * 60 * 9) | strftime("%F %X")), .ping.jitter, .ping.latency, .download.bandwidth, .download.bytes, .download.elapsed, .upload.bandwidth, .upload.bytes, .upload.elapsed, ("mac mini"), ("addon")] | @tsv' \
> output/${RESULT_FILENAME_TSV}

echo "== upload =="
python upload.py ${RESULT_FILENAME_TSV}

echo "==rm files=="
rm -f output/${RESULT_FILENAME_JSON}
rm -f output/${RESULT_FILENAME_TSV}

echo "== end =="
