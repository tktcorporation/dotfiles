# dotfiles

[chezmoi](https://www.chezmoi.io/) + [Brewfile](https://github.com/Homebrew/homebrew-bundle) + [1Password CLI](https://developer.1password.com/docs/cli/) で管理するシンプルな dotfiles.

## Setup

### 新しいマシン (ワンライナー)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation
```

初回実行時に以下を聞かれます:

- **Git user name** / **Git email address** — gitconfig に設定
- **SSH public key for commit signing** — 1Password SSH signing に使う公開鍵 (空欄でスキップ)

### 既にセットアップ済みの場合

```bash
chezmoi update
```

## 構成

```
.chezmoi.yaml.tmpl                          # chezmoi 設定 (初回プロンプト定義)
.chezmoiignore                              # chezmoi が HOME にコピーしないファイル
Brewfile                                    # brew bundle で管理するパッケージ
dot_gitconfig.tmpl                          # ~/.gitconfig
dot_gitignore_global                        # ~/.gitignore_global
run_onchange_before_install-packages.sh.tmpl # Brewfile 変更時に自動で brew bundle
```

## パッケージ管理

`Brewfile` を編集して `chezmoi apply` すると自動で `brew bundle` が走ります.

```bash
# Brewfile にパッケージを追加した後
chezmoi apply
```

## 1Password 連携

### SSH commit signing

`chezmoi init` 時に SSH 公開鍵を入力すると、gitconfig に以下が自動設定されます:

- `gpg.format = ssh`
- `gpg.ssh.program` — OS に応じた `op-ssh-sign` のパス
- `commit.gpgsign = true`

### SSH agent

1Password アプリの設定で SSH agent を有効にし、`~/.ssh/config` に以下を追加:

```ssh-config
# macOS
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Linux
Host *
    IdentityAgent ~/.1password/agent.sock
```

## ローカル設定

`~/.gitconfig.local` で gitconfig をマシン固有に上書きできます:

```gitconfig
[user]
    signingKey = ssh-ed25519 AAAA...
```

## License

[MIT](LICENSE.txt)
