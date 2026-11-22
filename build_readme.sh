#!/usr/bin/env bash
# =============================================================================
# build_readme.sh - copy the request files into README.md
# =============================================================================
#
# WHY
#   The files in telnet/ and openssl/ are the GOLDEN SOURCE: the versions
#   that actually ran. The README shows them as code snippets so nobody has
#   to open the files. This script copies them in, so the README can never
#   drift away from the files.
#
# HOW IT WORKS
#   In README.md, each snippet sits between two markers:
#
#     <!-- include: telnet/E301_get_root_200_telnet_local.http -->
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
      print "<br>"
      print ""
      print "**Request**"
      print ""
      print "```bash"
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

# -----------------------------------------------------------------------------
# Stage 2: number the headings and write the table of contents
# -----------------------------------------------------------------------------
#   ## chapters   -> "## Chapter 3: Title"  (number = position of the chapter)
#   ### sections  -> "### 3.2 Title"    (chapter.section)
#   #### headings (the experiments ECNN_...) are not numbered: they have ECNN.
#   The table of contents is written between <!-- toc --> and <!-- /toc -->,
#   with links GitHub understands (lower case, no punctuation, - for spaces).
#   Lines inside ``` code blocks are ignored (# there is a comment, not a heading).

awk '
  function anchor(t,   a) {
    a = tolower(t)
    gsub(/[^a-z0-9 _-]/, "", a)
    gsub(/ /, "-", a)
    return a
  }
  function renumber(line,   t) {
    if (line ~ /^## /) {
      ch++; sec = 0
      t = line; sub(/^## +/, "", t); sub(/^Chapter [0-9]+: +/, "", t); sub(/^[0-9]+\.? +/, "", t)
      return "## Chapter " ch ": " t
    }
    if (line ~ /^### / && ch > 0) {
      sec++
      t = line; sub(/^### +/, "", t); sub(/^[0-9]+\.[0-9]+\.? +/, "", t)
      return "### " ch "." sec " " t
    }
    return line
  }
  # ---- first read: collect the numbered headings for the table of contents
  NR == FNR {
    if ($0 ~ /^```/) { fence = !fence; next }
    if (!fence && ($0 ~ /^## / || $0 ~ /^### /)) {
      h = renumber($0)
      n++
      level[n] = ($0 ~ /^### /) ? 2 : 1
      title[n] = h; sub(/^#+ /, "", title[n])
      next
    }
    next
  }
  # ---- second read: write the file with numbered headings and a fresh toc
  FNR == 1 { ch = 0; sec = 0; fence = 0 }
  /^<!-- toc -->$/ {
    print
    print "**Contents**"
    print ""
    for (i = 1; i <= n; i++) {
      indent = (level[i] == 2) ? "  " : ""
      print indent "- [" title[i] "](#" anchor(title[i]) ")"
    }
    skip = 1; next
  }
  /^<!-- \/toc -->$/ { skip = 0; print; next }
  skip { next }
  /^```/ { fence = !fence; print; next }
  !fence && (/^## / || /^### /) { print renumber($0); next }
  { print }
' "${README}" "${README}" > "${TMP}"

mv "${TMP}" "${README}"
echo "OK: headings numbered, table of contents updated"
