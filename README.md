# dotfiles

[chezmoi](https://www.chezmoi.io/) + [Brewfile](https://github.com/Homebrew/homebrew-bundle) + [1Password CLI](https://developer.1password.com/docs/cli/) + [mise](https://mise.jdx.dev/) で管理する dotfiles.

## Setup

```bash
bash <(curl -fsLS https://raw.githubusercontent.com/tktcorporation/dotfiles/main/setup.sh)
```

Xcode Command Line Tools のインストール待ちから chezmoi の init/apply まで自動で行います.

<details>
<summary>手動で実行する場合</summary>

```bash
# 1. Xcode Command Line Tools をインストールし、GUI ダイアログ完了を待つ
xcode-select --install
# ダイアログで「インストール」→ 完了を待ってから次へ

# 2. chezmoi で dotfiles をセットアップ
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tktcorporation
```

</details>

これだけで以下が全て完了します:

1. **chezmoi** インストール
2. **Homebrew** インストール (未導入の場合)
3. **Brewfile** の全パッケージインストール (CLI ツール, cask アプリ, Mac App Store)
4. **~/.gitconfig** 展開 (name/email/signing key をプロンプトで設定)
5. **~/.gitignore_global** 展開
6. **~/.zprofile** 展開 (Homebrew PATH + OrbStack)
7. **~/.zshrc** 展開 (mise, zoxide, direnv, fzf, aliases)
8. **~/.ssh/config** 展開 (1Password SSH agent + OrbStack)
9. **~/.config/mise/config.toml** 展開 (node, python, bun, pnpm 等)
10. **~/.config/ghostty/config** 展開
11. **macOS defaults** 適用 (Dock, Finder, キーボード設定)
12. **mise install** で各ランタイムインストール

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
dot_zprofile.tmpl                            # ~/.zprofile (Homebrew PATH + OrbStack)
dot_zshrc                                    # ~/.zshrc (mise, tool init, aliases)
private_dot_ssh/private_config.tmpl          # ~/.ssh/config (1Password SSH agent + OrbStack)
dot_config/mise/config.toml                  # ~/.config/mise/config.toml (ランタイム管理)
dot_config/ghostty/config                    # ~/.config/ghostty/config
run_onchange_before_install-packages.sh.tmpl # Brewfile 変更時に自動で brew bundle
run_once_after_macos-defaults.sh.tmpl        # macOS 初回セットアップ時のシステム設定
run_onchange_after_setup-tools.sh.tmpl       # mise config 変更時にランタイムインストール
```

## パッケージ管理

`Brewfile` を編集して `chezmoi apply` すると自動で `brew bundle` が走ります.

## ランタイム管理

[mise](https://mise.jdx.dev/) で node, python, bun, pnpm, uv 等を一元管理しています.
`dot_config/mise/config.toml` を編集して `chezmoi apply` すると自動で `mise install` が走ります.

## 1Password 連携

- **SSH agent**: `~/.ssh/config` に OS に応じた `IdentityAgent` を自動設定
- **commit signing**: 初回セットアップ時に SSH 公開鍵を入力すると `op-ssh-sign` 経由の署名を自動設定 (空欄でスキップ可)

## ローカル上書き

- `~/.gitconfig.local` でマシン固有の Git 設定を追加できます
- `~/.zshrc.local` でマシン固有のシェル設定を追加できます

## License

[MIT](LICENSE.txt)
