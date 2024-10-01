# ビルドステージ
FROM --platform=linux/arm/v7 arm32v7/python:3.12-slim-bullseye as builder

# 作業ディレクトリの設定
WORKDIR /build

COPY requirements.txt /build/

# 必要なパッケージのインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gcc build-essential libpq-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# RustとCargoのインストール
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# pipをアップグレードし、依存関係をインストール
RUN pip install --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir --wheel-dir=/root/wheels -r requirements.txt

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
RUN SODIUM_INSTALL=system pip install --no-cache /root/wheels/*

CMD ["python3"]