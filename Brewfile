# ─── Core CLI Tools ───
brew "chezmoi"
brew "gh"
brew "ghq"
brew "fzf"
brew "direnv"
brew "zoxide"
brew "jq"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "mas"

# ─── Runtime Manager ───
brew "mise"

# ─── Development Tools ───
brew "cocoapods"
brew "fastlane"

# ─── Media & Utilities ───
brew "ffmpeg"
brew "exiftool"

# ─── Security & Networking ───
brew "cloudflared"
brew "clamav"

if OS.mac?
  # ─── Essentials ───
  cask "1password"
  cask "1password-cli"
  cask "raycast"

  # ─── Terminals & Editors ───
  cask "ghostty"
  cask "warp"
  cask "visual-studio-code"

  # ─── Browsers ───
  cask "arc"
  cask "google-chrome"
  # chromium は 2026-09-01 に Homebrew cask 側で disable 予定
  # (fails_gatekeeper_check)。宣言してもその後の brew bundle が
  # 時限爆弾的に失敗するため、Brewfile管理には含めない
  # (Codex review PR #102 で指摘)。

  # ─── Communication ───
  cask "slack"
  cask "discord"

  # ─── Productivity ───
  cask "notion"
  cask "notion-calendar"
  cask "notion-mail"

  # ─── Dev Infrastructure ───
  cask "orbstack"
  cask "cloudflare-warp"
  cask "tailscale"

  # ─── Creative / Media ───
  cask "screen-studio"
  cask "cleanshot"
  cask "inkscape"

  # ─── AI ───
  cask "chatgpt"
  cask "claude"

  # ─── Input ───
  cask "aqua-voice"
  cask "typeless"
  cask "karabiner-elements"

  # ─── Other ───
  cask "thunderbird"

  # ─── Mac App Store ───
  # mas install requires App Store sign-in
  mas "Xcode", id: 497799835
end
