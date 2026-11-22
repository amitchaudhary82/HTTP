#!/usr/bin/env bash
# =============================================================================
# practice_part2_auth_https.sh - Part 2 (chapters 7 - 8) with curl
# =============================================================================
#
# The Message files (messages/) are the golden source: nothing is copied
# here. http_to_curl reads a file and builds the curl command from it.
# Compare curl's "> " lines with the Message file: that is what the
# Carrier curl writes for you.
#
# HOW TO USE
#   From the repository root, run ONE line at a time (VS Code: select the
#   line, Cmd+Shift+P > "Run Selected Text"). Run SETUP first.
#   Only print a command:  HTTP_TO_CURL_DRY=1 http_to_curl messages/E301_...http
# =============================================================================

# Safety: only line by line. A whole-script run stops here.
if [[ $- != *i* ]]; then
  echo "Run this file line by line (one example at a time), not as a whole."
  exit 0
fi

# SETUP: load the helper (run from the repository root)
source curl/http_to_curl.sh


# =============================================================================
# Chapter 7 - Authentication (_internet)
# =============================================================================

# E701  GET httpbin bearerMissing, expect 401 (internet)
http_to_curl messages/E701_get_httpbin_bearerMissing_401_internet.http

# E702  GET httpbin bearerToken, expect 200 (internet)
#   The token travels in the Authorization header, copied from the file.
http_to_curl messages/E702_get_httpbin_bearerToken_200_internet.http


# =============================================================================
# Chapter 8 - HTTPS (_https)
# =============================================================================

# E801  GET httpbin, expect 200 (https)
#   https:// - curl builds the encrypted tunnel; the * lines in -v show it.
http_to_curl messages/E801_get_httpbin_200_https.http

# E802  GET githubApi zen, expect 200 (https)
#   The User-Agent from the file is sent; GitHub requires one.
http_to_curl messages/E802_get_githubApi_zen_200_https.http
