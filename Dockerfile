# ビルドステージ
FROM --platform=linux/arm/v7 arm32v7/python:3.12-slim-bullseye as builder

# 作業ディレクトリの設定
WORKDIR /build

COPY requirements.txt /build/

# 必要なパッケージのインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget git curl gcc build-essential libpq-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# libsodiumのダウンロードとインストール
RUN wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.20-stable.tar.gz && \
    tar -xvf libsodium-1.0.20-stable.tar.gz && \
    cd libsodium-stable && \
    ./configure && \
    make -j && \
    make check && \
    make install && \
    cd .. && \
    rm -rf libsodium-1.0.20-stable*

# RustとCargoのインストール
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# pipをアップグレードし、依存関係をインストール
RUN pip install --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir --wheel-dir=/root/wheels -r requirements.txt

# COPY PyNaCl-remove-check.patch PyNaCl-remove-check.patch
# # pynaclのソースコードをダウンロードし、パッチを適用
# RUN wget -qO pynacl.tar.gz https://github.com/pyca/pynacl/archive/1.5.0.tar.gz && \
#     mkdir pynacl && tar --strip-components=1 -xvf pynacl.tar.gz -C pynacl && rm pynacl.tar.gz && \
#     cd pynacl && \
#     git apply ../PyNaCl-remove-check.patch && \
#     python3 setup.py bdist_wheel && \
#     cp -f dist/PyNaCl-1.5.0-py3-none-any.whl /root/wheels/ && \
#     cd .. && rm -rf pynacl && \
#     pip wheel --no-cache-dir --wheel-dir=/root/wheels -r requirements.txt

# 実行ステージ
FROM --platform=linux/arm/v7 arm32v7/python:3.12-slim-bullseye

# 作業ディレクトリの設定
WORKDIR /app

# ロケールの設定
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9

# ビルドステージから必要なファイルのみをコピー
COPY --from=builder /root/wheels /root/wheels
COPY --from=builder /build/requirements.txt .

# 事前にビルドされたホイールから依存関係をインストール
RUN pip install --no-cache /root/wheels/*

CMD ["python3"]