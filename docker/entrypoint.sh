#!/usr/bin/bash
# ここでコンテナ起動時の初期化処理を行う。
# 何かをユーザー権限で初回起動時に自動インストールするのであれば、ここで行うのが良い。
# zsh のセットアップがまだ終わっていない場合があるので、bash で実行する。

# まだ .zshrc がなければ初回セットアップ。
if [ ! -f /home/ubuntu/.zshrc ]; then
  # システムが用意している .zshrc テンプレートをコピー
  cp /etc/zsh/newuser.zshrc.recommended /home/ubuntu/.zshrc
  # mise を zsh で使うための設定を .zshrc に追記
  echo 'eval "$(mise activate zsh)"' >> "${ZDOTDIR-$HOME}/.zshrc"
  # 開発に利用するツールを mise 経由でインストール（グローバルに使うもの）
  mise use --global rust go uv codex zellij fd tokei eza bat lazygit ghq yazi
  # 今この bash 上で mise を有効化して、インストールしたものを使えるようにする
  eval "$(mise activate bash)"
  # mise 経由でないインストール
  go install github.com/d-kuro/gwq/cmd/gwq@latest
fi

# セットアップ終了したことをログに出力
echo "=== entrypoint.sh: setup finished ==="

# 常駐させる
if [ "$#" -eq 0 ]; then
  exec sleep infinity
fi
exec "$@"
