FROM ubuntu:26.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        locales language-pack-ja tzdata \
        git curl wget ca-certificates unzip ripgrep python3 python3-pip build-essential \
        software-properties-common gpg-agent \
    && sed -i 's/^# *ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo Asia/Tokyo > /etc/timezone

# GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt update \
	&& apt install gh -y

# mise
RUN add-apt-repository -y ppa:jdxcode/mise \
    && apt-get update \
    && apt-get install -y --no-install-recommends mise

# ここから先は各自開発に必要なものをインストール（これは例）
# 非常に多くの開発ツールを mise 経由で後からユーザー権限でインストールできる。
# mise 経由での自動インストールは entrypoint.sh 内で行う。
# ここではシステムにパッケージで入れたいものだけでよい。
# ====
RUN apt-get install -y --no-install-recommends \
        zsh fzf \
    && rm -rf /var/lib/apt/lists/*
RUN chsh -s /bin/zsh ubuntu
ENV SHELL=/bin/zsh
# ====
# 各自の開発に必要なもののインストールはここまで

# 初期化スクリプトをコピー
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8

USER ubuntu
WORKDIR /home/ubuntu
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
