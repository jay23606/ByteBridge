#!/bin/sh
# Puts the product site from website/ into a folder ready to publish:
#
#   scripts/build-website.sh <out-dir>
#
# The APT repository workflow calls it after building the signed apt
# repository into the same folder, because GitHub Pages serves one site
# per repository: the product pages and the apt repository have to go
# out in the same deployment, or each would wipe the other. So nothing
# here may land on a path the apt repository uses (bytebridge.asc,
# dists/, pool/, apt/), and an existing file is never overwritten.
#
# The screenshots come from docs/assets, where scripts/docs-screens.py
# draws them, so the site never carries a copy that drifts.
#
# Run it against an empty folder to preview the site locally:
#
#   scripts/build-website.sh /tmp/site && python3 -m http.server -d /tmp/site
set -eu

OUT="${1:?usage: build-website.sh <out-dir>}"
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/website"

# Arabic-Indic digits look right in a browser and wrong next to the
# commands, ports and versions on the same page, which use 0-9.
if grep -rnP '[\x{0660}-\x{0669}\x{06F0}-\x{06F9}]' "$SRC"; then
  echo "website/ uses Arabic-Indic digits; write 0-9 instead." >&2
  exit 1
fi

mkdir -p "$OUT"

# copy <source> <path inside OUT>
copy() {
  case "$2" in
    bytebridge.asc|dists|dists/*|pool|pool/*|apt|apt/*)
      echo "$2 belongs to the apt repository." >&2
      exit 1 ;;
  esac
  if [ -e "$OUT/$2" ]; then
    echo "$OUT/$2 already exists; refusing to overwrite it." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$OUT/$2")"
  cp "$1" "$OUT/$2"
}

(cd "$SRC" && find . -type f | sed 's|^\./||' | sort) | while read -r path; do
  copy "$SRC/$path" "$path"
done

for lang in ar en; do
  copy "$ROOT/docs/assets/screens/$lang/6-all-good.svg" "assets/screens/$lang/6-all-good.svg"
done

echo "Site written to $OUT"
