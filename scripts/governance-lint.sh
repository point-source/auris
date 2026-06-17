#!/usr/bin/env bash
#
# Local mirror of the CI "Governance Lint" job so the full contract can be run
# before pushing — not discovered after. It reproduces the reusable workflow
#   repentsinner/symphonize/.github/workflows/governance-lint.yml@notation--v0
# (readme-type: library) step for step: Vale prose, markdownlint, SPEC status
# lines, README headings, and the heading-addressing grammar (§spec/§req/§road
# slugs, uniqueness, reference resolution, no positional/numeric addressing).
#
# The local pre-commit hook only runs markdownlint, which is why the other
# checks used to surface only on CI. Keep this in sync if the upstream ref moves;
# re-fetch with:
#   gh api 'repos/repentsinner/symphonize/contents/.github/workflows/governance-lint.yml?ref=notation--v0' --jq .content | base64 -d
#
# Exit 0 if every check passes, 1 otherwise. Runs ALL checks (no early exit) so
# every problem is reported in one pass.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
readme_type="library"
total=0

hr() { printf '\n\033[1m── %s\033[0m\n' "$1"; }

# ---- Vale prose linter (errors fail; warnings don't), if configured ----------
hr "Vale prose"
if [ -f .vale.ini ]; then
  if command -v vale >/dev/null 2>&1; then
    if ! vale SPEC.md REQUIREMENTS.md ROADMAP.md README.md; then
      echo "✗ Vale reported error-level alerts"
      total=$((total + 1))
    else
      echo "✓ Vale clean"
    fi
  else
    echo "⚠ vale not installed — skipping (brew install vale). The error-level"
    echo "  rule is Requirements.MustDeprecated: no '\bmust\b' in SPEC/REQUIREMENTS."
    if grep -rnE '\b[Mm]ust\b' SPEC.md REQUIREMENTS.md >/dev/null 2>&1; then
      echo "✗ found 'must' (use 'shall'):"
      grep -rnE '\b[Mm]ust\b' SPEC.md REQUIREMENTS.md
      total=$((total + 1))
    else
      echo "✓ no 'must' in SPEC/REQUIREMENTS"
    fi
  fi
fi

# ---- markdownlint ------------------------------------------------------------
hr "markdownlint"
if npx --yes markdownlint-cli2 SPEC.md ROADMAP.md README.md REQUIREMENTS.md >/tmp/gl-mdlint 2>&1; then
  echo "✓ markdownlint clean"
else
  cat /tmp/gl-mdlint
  total=$((total + 1))
fi

# ---- SPEC.md status lines ----------------------------------------------------
hr "SPEC status lines"
status_errors=0
for specfile in $(find . -name 'SPEC.md' -not -path './.git/*' | sort); do
  section=""
  expect_status=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\ [^#] ]]; then
      if $expect_status; then
        echo "✗ ${specfile}: section '$section' has no *Status: line"
        status_errors=$((status_errors + 1))
      fi
      section="$line"; expect_status=true; continue
    fi
    if $expect_status; then
      [[ -z "$line" ]] && continue
      if [[ "$line" =~ ^\*Status:\ (not\ started|in\ progress|complete)\*$ ]]; then
        expect_status=false
      else
        echo "✗ ${specfile}: section '$section' invalid/missing status: $line"
        status_errors=$((status_errors + 1)); expect_status=false
      fi
    fi
  done < <(tr -d '\r' < "$specfile")
  if $expect_status; then
    echo "✗ ${specfile}: section '$section' has no *Status: line (end of file)"
    status_errors=$((status_errors + 1))
  fi
done
[ "$status_errors" -eq 0 ] && echo "✓ status lines valid" || total=$((total + status_errors))

# ---- README.md headings (library profile) ------------------------------------
hr "README headings ($readme_type)"
readme_errors=0
if [ ! -f README.md ]; then
  echo "✗ README.md not found"; readme_errors=$((readme_errors + 1))
else
  headings=$(grep -E '^## ' README.md | sed 's/^## //' | tr '[:upper:]' '[:lower:]')
  check_heading() {
    if ! echo "$headings" | grep -qxE "$2"; then
      echo "✗ README.md missing required heading: $1 (pattern: $2)"
      readme_errors=$((readme_errors + 1))
    fi
  }
  check_heading "License" "licen(se|sing)|licensing note"
  check_heading "Installation" "install(ation)?|getting started|quick start"
  check_heading "Usage" "usage"
  check_heading "API" "api|api reference"
fi
[ "$readme_errors" -eq 0 ] && echo "✓ README headings present" || total=$((total + readme_errors))

# ---- Heading addressing grammar ----------------------------------------------
hr "Heading addressing grammar"
ha_errors=0
defs_file=$(mktemp)
prefix_for() {
  case "$1" in
    SPEC.md) echo "spec" ;; REQUIREMENTS.md) echo "req" ;; ROADMAP.md) echo "road" ;; *) echo "" ;;
  esac
}
govfiles=$(find . \( -name 'SPEC.md' -o -name 'ROADMAP.md' -o -name 'REQUIREMENTS.md' \) -not -path './.git/*' | sort)

# Pass 1 — required ## slug, reject numeric ordinals, collect definitions.
for govfile in $govfiles; do
  base=$(basename "$govfile")
  prefix=$(prefix_for "$base")
  [ -z "$prefix" ] && continue
  lineno=0; in_fenced=false
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    if echo "$line" | grep -qE '^```'; then
      $in_fenced && in_fenced=false || in_fenced=true; continue
    fi
    $in_fenced && continue
    echo "$line" | grep -qE '^##+ ' || continue
    if echo "$line" | grep -qE '^#+ [0-9]+(\.[0-9]+)*[. ]'; then
      echo "✗ ${govfile}:${lineno}: positional heading (numeric ordinal): $line"
      ha_errors=$((ha_errors + 1))
    fi
    heading_slugs=$(echo "$line" | grep -oE '§(spec|req|road):[a-z0-9-]+' || true)
    if echo "$line" | grep -qE '^## '; then
      if ! echo "$line" | grep -qE "§${prefix}:[a-z0-9-]+"; then
        echo "✗ ${govfile}:${lineno}: ## heading missing §${prefix}: slug: $line"
        ha_errors=$((ha_errors + 1))
      fi
    fi
    for s in $heading_slugs; do echo "${s#§}" >> "$defs_file"; done
  done < <(tr -d '\r' < "$govfile")
done

dupes=$(sort "$defs_file" | uniq -d)
if [ -n "$dupes" ]; then
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    echo "✗ duplicate slug definition: §${d}"
    ha_errors=$((ha_errors + 1))
  done <<< "$dupes"
fi

# Pass 2 — references resolve to exactly one definition; reject §<number>.
for govfile in $govfiles; do
  lineno=0; in_fenced=false
  while IFS= read -r line; do
    lineno=$((lineno + 1))
    if echo "$line" | grep -qE '^```'; then
      $in_fenced && in_fenced=false || in_fenced=true; continue
    fi
    $in_fenced && continue
    stripped=$(echo "$line" | sed 's/`[^`]*`//g')
    if echo "$stripped" | grep -qE '§[0-9]'; then
      echo "✗ ${govfile}:${lineno}: positional reference (numeric address): $line"
      ha_errors=$((ha_errors + 1))
    fi
    scan="$stripped"
    if echo "$stripped" | grep -qE '^##+ '; then
      scan=$(echo "$stripped" | sed -E 's/§(spec|req|road):[a-z0-9-]+//g')
    fi
    refs=$(echo "$scan" | grep -oE '§(spec|req|road):[a-z0-9-]+' || true)
    [ -z "$refs" ] && continue
    for ref in $refs; do
      key="${ref#§}"
      count=$(grep -cxF "$key" "$defs_file" || true)
      if [ "$count" -eq 0 ]; then
        echo "✗ ${govfile}:${lineno}: dangling reference ${ref}"
        ha_errors=$((ha_errors + 1))
      elif [ "$count" -gt 1 ]; then
        echo "✗ ${govfile}:${lineno}: ambiguous reference ${ref} (resolves to ${count})"
        ha_errors=$((ha_errors + 1))
      fi
    done
  done < <(tr -d '\r' < "$govfile")
done
rm -f "$defs_file"
[ "$ha_errors" -eq 0 ] && echo "✓ heading addressing valid" || total=$((total + ha_errors))

# ---- Result ------------------------------------------------------------------
hr "Result"
if [ "$total" -gt 0 ]; then
  echo "✗ $total governance error(s) — fix before pushing"
  exit 1
fi
echo "✓ governance lint clean"
