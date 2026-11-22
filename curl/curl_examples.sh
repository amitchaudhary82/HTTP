#!/usr/bin/env bash
# =============================================================================
# curl_examples.sh - the HTTP experiments, written with curl
# =============================================================================
#
# HOW TO USE
#   Run ONE example at a time, line by line (VS Code: select the line,
#   Cmd+Shift+P > "Run Selected Text"). Do NOT run the whole file:
#   it would fire 40 requests at once, and some wait on purpose.
#   Run the SETTINGS lines first in every new terminal.
#
#   Each section has the same experiment ID ECNN as the raw file in ../telnet
#   or ../openssl. Compare: raw file = what you typed by hand,
#   curl -v output lines starting with ">" = what curl typed for you.
#
# CURL OPTIONS USED
#   -v               verbose: > = request sent, < = response received,
#                    * = curl's own notes (connection, TLS, redirects)
#   -i               include the response headers in the output
#   -I               send HEAD instead of GET
#   -X METHOD        use this method (PUT, PATCH, DELETE, OPTIONS ...)
#   -H "Name: val"   add a header;  -H "Name:" (empty) REMOVES a header
#   -A "text"        set the User-Agent header
#   -d / --data-binary  send a body (makes it a POST unless -X says otherwise)
#   -G               put -d values into the query string instead of a body
#   --data-urlencode encode a value for you (spaces, &, + ...)
#   -L               follow redirects (curl does NOT follow by default)
#   -s               silent: no progress bar
#
# LOCAL SERVER (examples marked "local")
#   cd http_mini_server_root && python3 -m http.server 8080 --bind 127.0.0.1
# =============================================================================

# Safety: only line by line. A whole-script run stops here.
if [[ $- != *i* ]]; then
  echo "Run this file line by line (one example at a time), not as a whole."
  exit 0
fi


# -----------------------------------------------------------------------------
# SETTINGS
# -----------------------------------------------------------------------------
LOCAL="http://127.0.0.1:8080"
WEB="http://httpbin.org"        # plain HTTP, port 80 (like telnet)
BIN="https://httpbin.org"       # HTTPS, port 443 (like openssl)
echo "${LOCAL} ${WEB} ${BIN}"   # check: three addresses


# =============================================================================
# Chapter 3 - Local server (telnet 127.0.0.1 8080)
# =============================================================================

# E301 local: GET the root. Compare the ">" lines with E301: curl adds
#            User-Agent and Accept on its own.
curl -v "${LOCAL}/"

# E302 local: folder without slash -> 301. curl does NOT follow redirects
#            unless you add -L, so you see the 301 just like in telnet.
curl -v "${LOCAL}/testFolder"
curl -vL "${LOCAL}/testFolder"        # with -L: follows to /testFolder/ -> 200

# E303 local: folder with slash -> 200
curl -v "${LOCAL}/testFolder/"

# E304 local: missing file -> 404
curl -v "${LOCAL}/missingFile.txt"

# E305 local: HEAD = headers only, no body
curl -I "${LOCAL}/"

# E306 local: an invented method -> 501
curl -v -X BADMETHOD "${LOCAL}/"

# E307 local: a file -> 200, Content-Type, Content-Length, body
curl -i "${LOCAL}/testfile.txt"

# E308 local: file in a sub-folder
curl -i "${LOCAL}/testFolder/testSubfolderFile.txt"

# E309 local: double slash. Check the "> GET" line: does curl keep "//"?
curl -v "${LOCAL}//"

# E310 local: response headers only (Server, Date, Content-Length, Last-Modified)
curl -I "${LOCAL}/testfile.txt"

# E311 / E312: raw spaces or quotes in the path.
#   NOT possible with curl: it expects a valid (encoded) URL and refuses or
#   rejects raw spaces. That's the point: the tool protects you from 400.

# E313 local: space written as %20 -> 200
curl -i "${LOCAL}/testfile%20with%20space.txt"

# E314 local: % @ space and a-umlaut, all encoded -> 200
curl -i "${LOCAL}/test_file%25special%40parm%20german_%C3%A4.txt"

# E315 local: missing Host on the local server -> 200 (it doesn't enforce Host;
#     compare E404 in chapter 4)
curl -v -H "Host:" "${LOCAL}/"


# =============================================================================
# Chapter 4 - Simple GET on the internet
# =============================================================================

# E401 plain HTTP to httpbin (port 80, like telnet)
curl -v "${WEB}/"

# E402 an API endpoint answering JSON
curl -s "${BIN}/ip"

# E403 another server
curl -s "https://example.org/"

# E404 missing Host -> 400. -H "Host:" with an empty value REMOVES the
#     Host header curl would normally add.
curl -v -H "Host:" "${WEB}/get"

# E405 two parameters. -G turns the -d values into ?name=Amit&city=Zurich
curl -G "${BIN}/get" -d name=Amit -d city=Zurich

# E406 space in a value. Look at the "> GET" line in -v: how was it encoded?
curl -v -G "${BIN}/get" --data-urlencode "city=St Gallen"

# E407 & inside a value: curl encodes it as %26 so it stays one value
curl -G "${BIN}/get" --data-urlencode "company=Johnson&Johnson" -d country=US

# E408 plus sign: compare a raw + (becomes a space) with an encoded one
curl -G "${BIN}/get" -d "q=a+b" --data-urlencode "r=a+b"

# E409 own headers: Accept and User-Agent
curl -v -H "Accept: application/json" -A "FileTest/1.0" "${BIN}/get"

# E410 - E412 status codes on demand
curl -i "${BIN}/status/201"
curl -i "${BIN}/status/204"
curl -i "${BIN}/status/500"

# E413 redirect chain: without -L you see the first 302, with -L all hops
curl -i "${BIN}/redirect/2"
curl -iL "${BIN}/redirect/2"

# E414 keep-alive: two URLs in one curl call. Look for
#     "Re-using existing connection" in the * lines.
curl -v "${BIN}/get?request=1" "${BIN}/get?request=2"


# =============================================================================
# Chapter 5 - Sending data: POST and other methods
# =============================================================================

# E501 text body. curl calculates Content-Length: 11 for you (see "> " lines)
curl -v -H "Content-Type: text/plain" --data-binary "hello world" "${BIN}/post"

# E502 JSON body. curl does not close the connection itself either, but it
#     ends cleanly after one request - no hanging like telnet.
curl -v -H "Content-Type: application/json" \
  -d '{"name":"Amit","city":"Switzerland"}' "${BIN}/post"

# E503 - E506: NOT needed with curl. curl always calculates Content-Length and
#   inserts the empty line, so these mistakes can't happen by accident.
#   (You could force a wrong length with -H "Content-Length: 8", but that
#    only breaks your own request - the lesson is that the tool does it.)

# E507 PUT: replace the whole resource
curl -X PUT -H "Content-Type: application/json" \
  -d '{"name":"Amit","city":"Zurich"}' "${BIN}/put"

# E508 PATCH: change only one part
curl -X PATCH -H "Content-Type: application/json" \
  -d '{"city":"Bern"}' "${BIN}/patch"

# E509 DELETE
curl -X DELETE "${BIN}/delete"

# E510 OPTIONS: look for the Allow header
curl -i -X OPTIONS "${BIN}/get"

# E511 wrong method: GET on /post -> 405
curl -i "${BIN}/post"


# =============================================================================
# Chapter 6 - Authentication
# =============================================================================

# E601 protected endpoint without token -> 401
curl -i "${BIN}/bearer"

# E602 with a token -> 200
curl -H "Authorization: Bearer test123" "${BIN}/bearer"


# =============================================================================
# Chapter 7 - HTTPS
# =============================================================================

# E701 same as E409, encrypted. The "*" lines in -v show the TLS tunnel
#     being built - the work openssl did by hand.
curl -v -H "Accept: application/json" -A "FileTest/1.0" "${BIN}/get"

# E702 GitHub API. Try it once without -A: GitHub needs a User-Agent
#     (curl sends its own "curl/x.y", so this one still works).
curl -A "hello-http-learning (amitchaudhary82)" "https://api.github.com/zen"
