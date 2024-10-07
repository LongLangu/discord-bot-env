#!/bin/bash

while true; do
    # main.pyが存在するか確認
    cd /app/
    if [ -f "main.py" ]; then
        # 存在する場合、コマンドを実行
        python main.py -e production
        break  # コマンド実行後、ループを終了
    else
        # 存在しない場合、30秒待機
        echo "main.pyが見つかりません。30秒後に再確認します..."
        sleep 30
    fi
done