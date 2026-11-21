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
#   markers writes:
#     **Connect**  the command to open the connection, worked out from the
#                  file name suffix (_telnet_local, _telnet_internet,
#                  _openssl) and the Host: line of the request
#     **Request**  the file content as a code block
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
  # start marker: print it, then Connect + Request blocks for that file
  /^<!-- include: .* -->$/ {
    print
    path = $0
    sub(/^<!-- include: /, "", path)
    sub(/ -->$/, "", path)

    # read the request file into an array, remember the Host header
    n = 0; host = ""
    while ((getline line < path) > 0) {
      n++; req[n] = line
      if (line ~ /^Host:/) { host = line; sub(/^Host:[ ]*/, "", host); sub(/\r$/, "", host) }
    }
    close(path)

    if (n == 0) {
      print "MISSING FILE: " path > "/dev/stderr"
      missing = 1
    } else {
      # the connect command follows from the file name suffix (+ Host header)
      if (host == "") host = "httpbin.org"          # e.g. 034: no Host on purpose
      if (path ~ /_telnet_local\.http$/)         cmd = "telnet 127.0.0.1 8080"
      else if (path ~ /_telnet_internet\.http$/) cmd = "telnet " host " 80"
      else if (path ~ /_openssl\.http$/)         cmd = "openssl s_client -connect " host ":443 -quiet -crlf"
      else                                       cmd = "(unknown suffix: see file naming rule)"

      print "**Connect**"
      print ""
      print "```bash"
      print cmd
      print "```"
      print ""
      print "**Request**"
      print ""
      print "```http"
      for (i = 1; i <= n; i++) print req[i]
      print "```"
    }
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
