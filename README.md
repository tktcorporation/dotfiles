# dotfiles

[chezmoi](https://www.chezmoi.io/) + [Brewfile](https://github.com/Homebrew/homebrew-bundle) + [1Password CLI](https://developer.1password.com/docs/cli/) で管理するシンプルな dotfiles.

## Setup

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation
```

これだけで以下が全て完了します:

1. **chezmoi** インストール
2. **Homebrew** インストール (未導入の場合)
3. **Brewfile** の全パッケージインストール (gh, ghq, fzf, direnv, zoxide, 1password-cli, ...)
4. **~/.gitconfig** 展開 (name/email/signing key をプロンプトで設定)
5. **~/.gitignore_global** 展開
6. **~/.zprofile** 展開 (Homebrew PATH)
7. **~/.zshrc** 展開 (zoxide, direnv, fzf, ghq/fzf aliases)
8. **~/.ssh/config** 展開 (1Password SSH agent)

### 更新

```bash
chezmoi update
```

## 構成

```
.chezmoi.yaml.tmpl                           # chezmoi 設定 (初回プロンプト定義)
Brewfile                                     # brew bundle で管理するパッケージ
dot_gitconfig.tmpl                           # ~/.gitconfig (aliases + 1Password signing)
dot_gitignore_global                         # ~/.gitignore_global
dot_zprofile.tmpl                            # ~/.zprofile (Homebrew PATH)
dot_zshrc                                    # ~/.zshrc (tool init + aliases)
private_dot_ssh/private_config.tmpl          # ~/.ssh/config (1Password SSH agent)
run_onchange_before_install-packages.sh.tmpl # Brewfile 変更時に自動で brew bundle
```

## パッケージ管理

`Brewfile` を編集して `chezmoi apply` すると自動で `brew bundle` が走ります.

## 1Password 連携

- **SSH agent**: `~/.ssh/config` に OS に応じた `IdentityAgent` を自動設定
- **commit signing**: 初回セットアップ時に SSH 公開鍵を入力すると `op-ssh-sign` 経由の署名を自動設定 (空欄でスキップ可)

## ローカル上書き

`~/.gitconfig.local` でマシン固有の設定を追加できます.

## License

[MIT](LICENSE.txt)
