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

# 2. Homebrew を入れ (https://brew.sh)、chezmoi で dotfiles をセットアップ
brew install chezmoi
chezmoi init --apply tktcorporation
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
dot_config/karabiner/karabiner.json          # Karabiner 本体設定 (両ルールを有効化済み)
dot_config/karabiner/assets/complex_modifications/cmd-eisuu-kana.json
                                             # Karabiner: 左右Command 単押しで英数/かな切り替え (GUI 取込用)
dot_config/karabiner/assets/complex_modifications/caps-to-control.json
                                             # Karabiner: Caps Lock を Control に変更 (GUI 取込用)
run_onchange_before_install-packages.sh.tmpl # Brewfile 変更時に自動で brew bundle (mas 行を除く)
run_after_install-mas-apps.sh.tmpl           # apply 毎に未導入の Mac App Store アプリだけ導入 (失敗は警告)
run_after_setup-clamav.sh.tmpl               # apply 毎に ClamAV 設定と初回定義 DB を用意 (揃っていれば何もしない)
run_onchange_after_macos-defaults.sh.tmpl    # macOS のシステム設定 (設定内容が変わったときに再適用)
run_after_upgrade-tools.sh.tmpl              # apply 毎に mise ツールを導入し範囲内の最新へ追従
```

## パッケージ管理

`Brewfile` を編集して `chezmoi apply` すると自動で `brew bundle` が走ります.

自己更新機能を持つ cask (`auto_updates true`: Chrome, Slack, Cursor 等) は, brew では未インストール時の導入だけを行い, 更新は各アプリの updater に任せています (`HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1`). brew による upgrade はアプリ自身の updater と競合して失敗しやすく, 回避のためにターミナルへ App Management 権限を与えるのも権限が広すぎるためです. brew でまとめて更新したい場合は `brew upgrade --greedy` を使います.

## ランタイム管理

[mise](https://mise.jdx.dev/) で node, python, bun, pnpm, uv 等を一元管理しています.
`chezmoi apply` のたびに `mise install` と `mise upgrade` が走り, `dot_config/mise/config.toml` に書いた範囲 (`node = "lts"`, `pnpm = "11"` 等) の中で最新版へ追従します. 古いバージョンに固定したまま忘れてセキュリティ修正を取りこぼさないよう, 厳密なバージョン固定はしていません. メジャーを上げたいときは範囲自体を編集します.

## サプライチェーン対策 (12 時間クールダウン)

バージョンを固定せず最新に追従する代わりに, **公開から 12 時間未満のバージョンは入れない** ようにしています. 乗っ取られたパッケージの悪性バージョン (ワーム等) は公開後数時間で検知・取り下げられることが多く, その間に巻き込まれるのを避けるためです.

| ツール | 設定 (chezmoi 管理) | 一時的にクールダウンを外すコマンド |
|---|---|---|
| mise | `dot_config/mise/config.toml` の `minimum_release_age = "12h"` | `mise upgrade --minimum-release-age 0s <tool>` |
| pnpm | `dot_config/mise/config.toml` の `[env]` `pnpm_config_minimum_release_age = "720"` (分) | `pnpm add <pkg> --config.minimum-release-age=0` |
| npm | `dot_config/mise/config.toml` の `[env]` `npm_config_min_release_age = "0.5"` (日) | `npm install <pkg> --min-release-age=0` |
| bun | `dot_bunfig.toml` の `minimumReleaseAge = 43200` (秒) | `bun add <pkg> --minimum-release-age=0` |
| uv | `dot_config/mise/config.toml` の `[env]` `UV_EXCLUDE_NEWER = "12 hours"` | `uv pip install <pkg> --exclude-newer "$(date -u +%Y-%m-%dT%H:%M:%SZ)"` |

npm / pnpm / uv はホームディレクトリにグローバル設定ファイルを増やさないよう, mise の `[env]` で環境変数として渡しています (mise 経由で動くシェル・shim・`mise exec` に効きます). bun だけは環境変数で設定できないため `~/.bunfig.toml` を使っています.

Homebrew には同等の機能がありません. 自己更新する cask はベンダーの updater に任せており (上記「パッケージ管理」), formula は Homebrew の CI がビルドした bottle を使います.

### 例外 (重要なセキュリティ修正をすぐ入れたいとき)

クールダウンを待つより修正を入れる方が優先なケースがあります (悪用中の脆弱性の修正など). その場合は **設定は変えずに**, 上表のコマンドで対象の 1 つだけを一時的に入れます. 入れる前に次を確認します.

1. 修正対象の脆弱性が実在し深刻か (GitHub Security Advisory / CVE / 公式アナウンス)
2. そのリリースが正規のメンテナから出ているか (公式リポジトリのタグ・リリースノート, npm の provenance 等)
3. そのバージョン自体に乗っ取り・不審な挙動の報告がないか
4. 差分が修正内容に見合っているか (不自然な依存追加や install スクリプトの追加がないか)

AI エージェントに作業させる場合も同じ手順で調べさせ, 根拠を示したうえで人が許可してから実行します.

## 1Password 連携

- **SSH agent**: `~/.ssh/config` に OS に応じた `IdentityAgent` を自動設定
- **commit signing**: 初回セットアップ時に SSH 公開鍵を入力すると `op-ssh-sign` 経由の署名を自動設定 (空欄でスキップ可)

## Karabiner-Elements (キーマッピング)

`~/.config/karabiner/karabiner.json` 本体を chezmoi で直接管理し, 以下のルールを有効化済みの状態で配布しています. `chezmoi apply` だけで即適用されます (GUI での手動有効化は不要).

- **Caps Lock → Control**: Caps Lock を Control キーとして使う
- **左右 Command 単押しで英数/かな** (US キーボード向け): 左 Command 単押しで英数, 右 Command 単押しでかな. 他キー併用時は通常の Command として動作

初回のみ Karabiner-Elements を起動してアクセシビリティ等の権限を付与する必要があります.

各ルールは GUI から個別に取り込める complex modification としても `dot_config/karabiner/assets/complex_modifications/` に置いてあります.

> 注意: Karabiner GUI で設定を変更すると `karabiner.json` が書き換わり chezmoi 差分が出ます. その場合は `chezmoi re-add ~/.config/karabiner/karabiner.json` で取り込むか, `chezmoi apply` で管理状態へ戻してください.

## 設計上あえて分離しているもの

一見重複に見えるが、対象や実行タイミングが異なるため意図的に分けている設定. 統合すると差異吸収の抽象化が必要になり複雑さが増すため, あえて一本化しない.

- **`.mise.toml`（リポジトリ自身の開発用） vs `dot_config/mise/config.toml`（配布先ユーザー環境用）**: 前者はこの dotfiles リポジトリ自体の開発・CI で使うランタイム設定（幅を持たせたバージョン指定）, 後者は `chezmoi apply` で `~/.config/mise/config.toml` に展開されるユーザー環境向け設定（メジャー等の範囲指定. apply 毎に範囲内の最新へ追従）. 対象読者が違う.
- **`Brewfile`（macOS ローカル環境全体） vs `.devcontainer/devcontainer.json` の `onCreateCommand`（Linux コンテナ最小限）**: パッケージマネージャー（brew/apt）・対象環境・目的が異なる. パッケージ名も両者で一致するとは限らないため共有マニフェスト化しない.

## ローカル上書き

- `~/.gitconfig.local` でマシン固有の Git 設定を追加できます
- `~/.zshrc.local` でマシン固有のシェル設定を追加できます

## License

[MIT](LICENSE.txt)
