#!/usr/bin/env bash
# =============================================================================
# practice_part1_basics.sh - Part 1 (chapters 3 - 5) with curl
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
#
# LOCAL SERVER (files ending _local): see 000_run_python_mini_server.txt
# =============================================================================

# Safety: only line by line. A whole-script run stops here.
if [[ $- != *i* ]]; then
  echo "Run this file line by line (one example at a time), not as a whole."
  exit 0
fi

# SETUP: load the helper (run from the repository root)
source curl/http_to_curl.sh


# =============================================================================
# Chapter 3 - The local server (_local)
# =============================================================================

# E301  GET root, expect 200 (local)
http_to_curl messages/E301_get_root_200_local.http

# E302  GET foldernoSlash, expect 301 (local)
#   curl does NOT follow redirects by default, so you see the 301.
#   Add -L to follow it (second line).
http_to_curl messages/E302_get_foldernoSlash_301_local.http
http_to_curl messages/E302_get_foldernoSlash_301_local.http -L

# E303  GET folder slash, expect 200 (local)
http_to_curl messages/E303_get_folder_slash_200_local.http

# E304  GET missingFile, expect 404 (local)
http_to_curl messages/E304_get_missingFile_404_local.http

# E305  HEAD root, expect 200 (local)
#   The helper uses curl -I for HEAD (curl -X HEAD would wait for a body).
http_to_curl messages/E305_head_root_200_local.http

# E306  GET badMethod, expect 501 (local)
http_to_curl messages/E306_get_badMethod_501_local.http

# E307  GET file, expect 200 (local)
http_to_curl messages/E307_get_file_200_local.http

# E308  GET subFolderFile, expect 200 (local)
http_to_curl messages/E308_get_subFolderFile_200_local.http

# E309  GET doubleSlash, expect 200 (local)
http_to_curl messages/E309_get_doubleSlash_200_local.http

# E310  HEAD file headers, expect 200 (local)
http_to_curl messages/E310_head_file_headers_200_local.http

# E311  GET fileNameSpaces, expect 400 (local)
#   Raw spaces in the URL: curl refuses a malformed URL - the tool protects you.
http_to_curl messages/E311_get_fileNameSpaces_400_local.http

# E312  GET fileNameQuotes, expect 400 (local)
#   Raw quotes and spaces in the URL: curl refuses it, like E311.
http_to_curl messages/E312_get_fileNameQuotes_400_local.http

# E313  GET fileNameUrlEncoding, expect 200 (local)
http_to_curl messages/E313_get_fileNameUrlEncoding_200_local.http

# E314  GET fileNameSpecialCharUrlEncoding, expect 200 (local)
http_to_curl messages/E314_get_fileNameSpecialCharUrlEncoding_200_local.http

# E315  GET root missingHost, expect 200 (local)
#   curl always sends Host. To repeat the mistake, remove it with -H "Host:".
http_to_curl messages/E315_get_root_missingHost_200_local.http
http_to_curl messages/E315_get_root_missingHost_200_local.http -H "Host:"


# =============================================================================
# Chapter 4 - GET on the internet (_internet)
# =============================================================================

# E401  GET httpbin get, expect 200 (internet)
http_to_curl messages/E401_get_httpbin_get_200_internet.http

# E402  GET httpbin ip, expect 200 (internet)
http_to_curl messages/E402_get_httpbin_ip_200_internet.http

# E403  GET example, expect 200 (internet)
http_to_curl messages/E403_get_example_200_internet.http

# E404  GET httpbin missingHost, expect 400 (internet)
#   curl always sends Host. To repeat the mistake, remove it with -H "Host:".
http_to_curl messages/E404_get_httpbin_missingHost_400_internet.http
http_to_curl messages/E404_get_httpbin_missingHost_400_internet.http -H "Host:"

# E405  GET httpbin queryString, expect 200 (internet)
http_to_curl messages/E405_get_httpbin_queryString_200_internet.http

# E406  GET httpbin querySpaceEncoded, expect 200 (internet)
http_to_curl messages/E406_get_httpbin_querySpaceEncoded_200_internet.http

# E407  GET httpbin queryAmpersandEncoded, expect 200 (internet)
http_to_curl messages/E407_get_httpbin_queryAmpersandEncoded_200_internet.http

# E408  GET httpbin queryPlusSign, expect 200 (internet)
http_to_curl messages/E408_get_httpbin_queryPlusSign_200_internet.http

# E409  GET httpbin multipleHeaders, expect 200 (internet)
http_to_curl messages/E409_get_httpbin_multipleHeaders_200_internet.http

# E410  GET httpbin status201, expect 201 (internet)
http_to_curl messages/E410_get_httpbin_status201_201_internet.http

# E411  GET httpbin status204, expect 204 (internet)
http_to_curl messages/E411_get_httpbin_status204_204_internet.http

# E412  GET httpbin status500, expect 500 (internet)
http_to_curl messages/E412_get_httpbin_status500_500_internet.http

# E413  GET httpbin redirectChain, expect 302 (internet)
#   Without -L you see the first 302; with -L curl follows every hop.
http_to_curl messages/E413_get_httpbin_redirectChain_302_internet.http
http_to_curl messages/E413_get_httpbin_redirectChain_302_internet.http -L

# E414  GET httpbin keepAliveTwoRequests, expect 200 (internet)
#   The file holds two requests; the helper sends only the first.
#   For keep-alive with curl, give two URLs in one call (second line).
http_to_curl messages/E414_get_httpbin_keepAliveTwoRequests_200_internet.http
curl -v "http://httpbin.org/get?request=1" "http://httpbin.org/get?request=2"


# =============================================================================
# Chapter 5 - Sending data: POST and other methods (_internet)
# =============================================================================

# E501  POST httpbinText, expect 200 (internet)
http_to_curl messages/E501_post_httpbinText_200_internet.http

# E502  POST httpbinJson, expect 200 (internet)
http_to_curl messages/E502_post_httpbinJson_200_internet.http

# E503  POST httpbinText shortLength, expect 200 (internet)
#   curl calculates Content-Length itself: the wrong length in the file is
#   not copied, so the whole body arrives.
http_to_curl messages/E503_post_httpbinText_shortLength_200_internet.http

# E504  POST httpbinText longLength, timeout (internet)
#   Same as E503: curl sets the right length, so nothing hangs.
http_to_curl messages/E504_post_httpbinText_longLength_timeout_internet.http

# E505  POST httpbinText, missingLengthNoData (internet)
#   Same as E503: curl adds the Content-Length that the file left out.
http_to_curl messages/E505_post_httpbinText_missingLengthNoData_internet.http

# E506  POST httpbinText missingBlankLine, expect 400 (internet)
#   No empty line in the file, so "hello world" is read as a header line -
#   the same mistake the server sees with a raw Carrier.
http_to_curl messages/E506_post_httpbinText_missingBlankLine_400_internet.http

# E507  PUT httpbinJson, expect 200 (internet)
http_to_curl messages/E507_put_httpbinJson_200_internet.http

# E508  PATCH httpbinJson, expect 200 (internet)
http_to_curl messages/E508_patch_httpbinJson_200_internet.http

# E509  DELETE httpbin, expect 200 (internet)
http_to_curl messages/E509_delete_httpbin_200_internet.http

# E510  OPTIONS httpbin, expect 200 (internet)
http_to_curl messages/E510_options_httpbin_200_internet.http

# E511  GET httpbin wrongMethod, expect 405 (internet)
http_to_curl messages/E511_get_httpbin_wrongMethod_405_internet.http
