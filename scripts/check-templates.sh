#!/bin/bash
# chezmoi テンプレートを実際に展開して検証する。CI (validate.yml) とローカルで同じものを走らせる。
#
#   bash scripts/check-templates.sh
#
# 検証内容:
#   1. 全 .tmpl をテスト用データで展開する。エラーは握りつぶさず失敗扱い
#      (以前の CI は「未定義関数」だけを拾い、構文エラーやデータ欠落は素通りしていた)
#   2. 展開後のシェルスクリプト (*.sh.tmpl) に bash -n と shellcheck をかける
#   3. .chezmoi.yaml.tmpl は 1Password CLI (op) に依存するため、偽の op を PATH 先頭に置いて
#      chezmoi init を模擬し、生成された設定が YAML として読めることを確認する
#
# macOS 専用のスクリプトは `{{ if eq .chezmoi.os "darwin" }}` で囲っているので、
# 中身まで検証するには macOS で実行する必要がある (Linux だと空に展開されて素通りする)。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 利用者の ~/.config/chezmoi や実行中の chezmoi (state のロック) に影響されないよう隔離する。
: > "$WORK/chezmoi.yaml"
CHEZMOI=(chezmoi --source "$ROOT" --config "$WORK/chezmoi.yaml" --persistent-state "$WORK/state.boltdb")
TEST_DATA='{"name":"CI User","email":"ci@example.com","signingkey":"ssh-ed25519 AAAATEST ci"}'

errors=0
fail() {
    echo "::error::$*"
    errors=$((errors + 1))
}

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "WARN: macOS 以外では darwin 向けテンプレートが空に展開されるため、検証が不完全になります" >&2
fi

# ── 1 & 2. 通常テンプレートの展開とシェルスクリプトの検査 ──────────
checked=0
while IFS= read -r -d '' tmpl; do
    rel="${tmpl#"$ROOT"/}"
    [[ "$rel" == ".chezmoi.yaml.tmpl" ]] && continue
    out="$WORK/rendered/${rel%.tmpl}"
    mkdir -p "$(dirname "$out")"
    if ! "${CHEZMOI[@]}" execute-template --override-data "$TEST_DATA" < "$tmpl" > "$out" 2> "$WORK/err"; then
        fail "$rel: テンプレートの展開に失敗しました"
        sed 's/^/    /' "$WORK/err"
        continue
    fi
    if [[ "$rel" == *.sh.tmpl ]]; then
        bash -n "$out" 2> "$WORK/err" || { fail "$rel: 展開後のシェルスクリプトに構文エラーがあります"; sed 's/^/    /' "$WORK/err"; }
        # SC1091: source 先 (bootstrap-lib.sh) を絶対パスで読むため shellcheck が辿れない。情報レベルなので除外。
        shellcheck -e SC1091 "$out" || fail "$rel: shellcheck の指摘があります"
    fi
    checked=$((checked + 1))
done < <(find "$ROOT" \( -path "$ROOT/.git" -o -path "$ROOT/.claude/worktrees" \) -prune -o -name '*.tmpl' -print0)

# 除外条件の誤りなどで 1 件も検査していないのに成功扱いになるのを防ぐ
# (.claude/worktrees 配下で実行すると、パス全体へのマッチで全件除外されたことがある)。
[ "$checked" -gt 0 ] || fail "検査対象のテンプレートが 1 件も見つかりませんでした"

# 素のスクリプト (テンプレートではないもの) も同じ基準で検査する。
for f in "$ROOT/setup.sh" "$ROOT/scripts/bootstrap-lib.sh" "$ROOT/scripts/check-templates.sh"; do
    bash -n "$f" || fail "${f#"$ROOT"/}: 構文エラーがあります"
    shellcheck -x "$f" || fail "${f#"$ROOT"/}: shellcheck の指摘があります"
done

# ── 3. .chezmoi.yaml.tmpl (chezmoi init) の模擬 ────────────────────
# op whoami は成功、op item get は鍵なし (空出力) として振る舞う偽 op。
mkdir -p "$WORK/bin"
cat > "$WORK/bin/op" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$WORK/bin/op"
if PATH="$WORK/bin:$PATH" "${CHEZMOI[@]}" execute-template --init --promptString profile= \
        < "$ROOT/.chezmoi.yaml.tmpl" > "$WORK/init.yaml" 2> "$WORK/err"; then
    ruby -ryaml -e 'd = YAML.safe_load(File.read(ARGV[0])); abort("data.name が空です") if d.dig("data", "name").to_s.empty?' "$WORK/init.yaml" \
        || fail ".chezmoi.yaml.tmpl: 生成された設定が不正です"
else
    fail ".chezmoi.yaml.tmpl: chezmoi init の模擬に失敗しました"
    sed 's/^/    /' "$WORK/err"
fi

if [ "$errors" -gt 0 ]; then
    echo "::error::$errors 件の問題が見つかりました"
    exit 1
fi
echo "All templates rendered and checked"
