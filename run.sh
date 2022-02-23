#!/bin/bash

set -e

# 引数を取得
MACHINE=$1  # 稼動マシン
ISP=$2  # 接続ISP
NETWORK_INTERFACE_ID=$3  # ネットワークインタフェースID

if [ ${NETWORK_INTERFACE_ID} = "en0" ]; then
    NETWORK_INTERFACE_NAME="Ethernet"
elif [ ${NETWORK_INTERFACE_ID} = "en1" ]; then
    NETWORK_INTERFACE_NAME="Wi-Fi"
else
    NETWORK_INTERFACE_NAME=""
fi

# 現在時刻を取得
echo "== start =="
NOW=`date +%Y%m%d%H%M%S`
echo ${NOW}

# 結果ファイル
RESULT_FILENAME_JSON=result_${MACHINE}_${ISP}_${NETWORK_INTERFACE_ID}_${NOW}.json
RESULT_FILENAME_TSV=result_${MACHINE}_${ISP}_${NETWORK_INTERFACE_ID}_${NOW}.tsv
SERVER_ID=server_id_${MACHINE}_${ISP}_${NETWORK_INTERFACE_ID}_${NOW}.txt

# speedtestの結果を出力
echo "== exec speedtest =="
speedtest -L | grep "OPEN Project" | awk '{print $1}' > output/${SERVER_ID}
if [ ! -s $FILE ]; then
    #OPEN Projectが存在しない場合はサーバーを指定しない
    echo "  use any server"
    speedtest -f json -I ${NETWORK_INTERFACE_ID}  > output/${RESULT_FILENAME_JSON}
else
    echo "  use OPEN PROJECT server"
    cat output/${SERVER_ID} | xargs -I{} speedtest -f json -s {} -I ${NETWORK_INTERFACE_ID}  > output/${RESULT_FILENAME_JSON}
fi

echo "== parse result =="
cat output/${RESULT_FILENAME_JSON} \
| jq -r '. | [(.timestamp | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime + (60 * 60 * 9) | strftime("%F %X")), .ping.jitter, .ping.latency, .download.bandwidth, .download.bytes, .download.elapsed, .upload.bandwidth, .upload.bytes, .upload.elapsed, .packetLoss, .server.name] | @tsv' \
| awk -v m=${MACHINE} -v i=${ISP} -v n=$NETWORK_INTERFACE_NAME -F "\t" 'BEGIN{OFS="\t"}{$NF=$NF"\t"m"\t"i"\t"n;print}' \
> output/${RESULT_FILENAME_TSV}

echo "== upload =="
python upload.py ${RESULT_FILENAME_TSV}

echo "==rm files=="
rm -f output/${RESULT_FILENAME_JSON}
rm -f output/${RESULT_FILENAME_TSV}
rm -f output/${SERVER_ID}

echo "== end =="
