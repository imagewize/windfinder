#!/usr/bin/env bash
# Render one Elayne pattern as a clean page on the local demo site and screenshot it.
#
#   screenshot.sh [--pattern SLUG] [--out FILE.png] [--width 1200] [--height 900]
#                 [--forbid REGEX] [--dry-run]
#
# Defaults: pattern elayne/page-homepage, out ./screenshot.png, 1200x900 (the WP.org size).
#
# What it does:
#   1. creates a throwaway published page that holds the pattern, on the page-no-title template, plus
#      a <style> that hides the cookie banner and its toggle (the page is deleted again on exit);
#   2. fetches the rendered HTML and fails if it matches --forbid (promo text such as version badges);
#   3. takes the PNG with the html-page-review skill's measure.mjs (headless Chrome, fonts and lazy
#      images loaded) and checks the size.
#
# The pattern must already be on the demo site: sync this working copy first, with the explicit source
#   SITE_ROOT=~/code/imagewize.com/demo/web/app wp-ops rsync-package-to-site theme elayne ~/code/elayne
# Never run it from inside the demo site. Needs Node 22, Chrome, and the Trellis VM running.
#
# Env overrides: TRELLIS_DIR, SITE_URL, WP_WORKDIR, MEASURE (path to measure.mjs).
# Not for the theme repo: Theme Check rejects .sh files in a shipped theme, so keep this in the toolbox.

set -euo pipefail

PATTERN="elayne/page-homepage"
OUT="screenshot.png"
WIDTH=1200
HEIGHT=900
FORBID='released this week|spots q[0-9]|open · [0-9]|>v[0-9]+\.[0-9]+'
DRY=0
SLUG="elayne-screenshot-temp"

TRELLIS_DIR="${TRELLIS_DIR:-$HOME/code/imagewize.com/trellis}"
SITE_URL="${SITE_URL:-http://demo.imagewize.test}"
WP_WORKDIR="${WP_WORKDIR:-/srv/www/demo.imagewize.com/current}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEASURE="${MEASURE:-$HERE/../../html-page-review/measure.mjs}"

while [ $# -gt 0 ]; do
  case "$1" in
    --pattern) PATTERN="$2"; shift 2 ;;
    --out)     OUT="$2"; shift 2 ;;
    --width)   WIDTH="$2"; shift 2 ;;
    --height)  HEIGHT="$2"; shift 2 ;;
    --forbid)  FORBID="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

wp() { (cd "$TRELLIS_DIR" && trellis vm shell --workdir "$WP_WORKDIR" -- wp "$@" --path=web/wp); }

CONTENT=$(cat <<EOF
<!-- wp:html -->
<style>#cc-main,.cc-main,[class*="warder"],[id*="warder"]{display:none!important}</style>
<!-- /wp:html -->
<!-- wp:pattern {"slug":"$PATTERN"} /-->
EOF
)

if [ "$DRY" = 1 ]; then
  echo "pattern:   $PATTERN"; echo "out:       $OUT (${WIDTH}x${HEIGHT})"; echo "site:      $SITE_URL/$SLUG/"
  echo "forbid:    /$FORBID/i"; echo "measure:   $MEASURE"; echo "page content:"; echo "$CONTENT"
  [ -f "$MEASURE" ] || { echo "measure.mjs not found" >&2; exit 1; }
  exit 0
fi

[ -f "$MEASURE" ] || { echo "measure.mjs not found at $MEASURE (set MEASURE)" >&2; exit 1; }
[ -d "$TRELLIS_DIR" ] || { echo "TRELLIS_DIR not found: $TRELLIS_DIR" >&2; exit 1; }

# A leftover page from an interrupted run would make the slug collide, so remove it first.
OLD=$(wp post list --post_type=page --name="$SLUG" --post_status=any --field=ID 2>/dev/null | tr -d '\r' || true)
[ -n "$OLD" ] && wp post delete $OLD --force >/dev/null

B64=$(printf '%s' "$CONTENT" | base64 | tr -d '\n')
ID=$( (cd "$TRELLIS_DIR" && trellis vm shell --workdir "$WP_WORKDIR" -- \
  bash -c "echo $B64 | base64 -d | wp post create - --post_type=page --post_status=publish --post_title=$SLUG --post_name=$SLUG --porcelain --path=web/wp") | tr -d '\r' | tail -1)
case "$ID" in ''|*[!0-9]*) echo "could not create the temp page (got: $ID)" >&2; exit 1 ;; esac
cleanup() { wp post delete "$ID" --force >/dev/null 2>&1 || echo "WARNING: delete page $ID ($SLUG) by hand" >&2; }
trap cleanup EXIT
wp post meta update "$ID" _wp_page_template page-no-title >/dev/null

URL="$SITE_URL/$SLUG/"
HTML=$(curl -fsS "$URL") || { echo "could not fetch $URL" >&2; exit 1; }
if printf '%s' "$HTML" | grep -qiE "$FORBID"; then
  echo "FAIL: rendered page matches /$FORBID/i:" >&2
  printf '%s' "$HTML" | grep -oiE ".{0,40}($FORBID).{0,40}" | head -5 >&2
  exit 1
fi
if printf '%s' "$HTML" | grep -qiE 'Block contains unexpected|has encountered an error'; then
  echo "FAIL: the page shows an unrendered pattern or block error; is $PATTERN synced to the demo site?" >&2
  exit 1
fi

node "$MEASURE" "$URL" --width "$WIDTH" --height "$HEIGHT" --screenshot "$OUT"

SIZE=$(file "$OUT" | grep -oE '[0-9]+ x [0-9]+' | head -1)
[ "$SIZE" = "$WIDTH x $HEIGHT" ] || { echo "FAIL: $OUT is $SIZE, expected $WIDTH x $HEIGHT" >&2; exit 1; }
echo "OK $OUT ($SIZE) from $PATTERN. Look at it before committing: no banners, no stray text."
