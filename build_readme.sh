#!/usr/bin/env bash
# =============================================================================
# build_readme.sh - copy the request files into README.md
# =============================================================================
#
# WHY
#   The files in 1_telnet/ and 2_openssl/ are the GOLDEN SOURCE: the versions
#   that actually ran. The README shows them as code snippets so nobody has
#   to open the files. This script copies them in, so the README can never
#   drift away from the files.
#
# HOW IT WORKS
#   In README.md, each snippet sits between two markers:
#
#     <!-- include: 1_telnet/001_get_root_200_telnet_local.http -->
#     (everything here is replaced by the current file content)
#     <!-- /include -->
#
#   The script reads README.md line by line (awk), and between each pair of
#   markers writes the file's current content as a code block.
#   Never edit a snippet in the README: edit the file, then run this script.
#
# HOW TO USE (from the repo folder, after changing any request file)
#   bash build_readme.sh
#   git diff README.md        # check: only the snippets you expect changed
#
# TOOLS USED
#   awk     reads a file line by line and decides what to print
#   getline reads another file (the request file) from inside awk
#   mv      replaces README.md with the new version only if all went well
# =============================================================================

set -e                                 # stop at the first error

README="README.md"
TMP="README.md.tmp"

[ -f "${README}" ] || { echo "STOPPED: run this inside the repo folder (no ${README} here)"; exit 1; }

awk '
  # start marker: print it, then the file content as a code block
  /^<!-- include: .* -->$/ {
    print
    path = $0
    sub(/^<!-- include: /, "", path)
    sub(/ -->$/, "", path)
    if ((getline line < path) <= 0) {
      print "MISSING FILE: " path > "/dev/stderr"
      missing = 1
    } else {
      print "```http"
      print line
      while ((getline line < path) > 0) print line
      print "```"
    }
    close(path)
    skipping = 1                       # drop the old snippet until the end marker
    next
  }
  # end marker: stop skipping, print it
  /^<!-- \/include -->$/ { skipping = 0; print; next }
  # normal line: print unless we are inside an old snippet
  !skipping { print }
  END { if (missing) exit 2 }
' "${README}" > "${TMP}"

mv "${TMP}" "${README}"
echo "OK: snippets in ${README} updated from the request files"
grep -c "^<!-- include: " "${README}" | sed "s/^/snippets: /"
