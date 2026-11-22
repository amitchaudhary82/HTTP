# =============================================================================
# practice_part1_basics.R - Part 1 (chapters 3 - 5) with httr2
# =============================================================================
#
# The Message files (messages/) are the golden source: nothing is copied
# here. message_request() reads a file and builds the httr2 request from it.
#
# HOW TO USE
#   Open the repository folder in RStudio (working directory = repo root),
#   run SETUP once, then one example at a time (Cmd+Enter).
#     req_dry_run(req)   what httr2 WOULD send (nothing is sent)
#     show(req)          send it; "->" = sent, "<-" = received
#
#   send_http_file() sends a file byte for byte (raw Carrier) - used below
#   wherever httr2 behaves differently, so you can compare.
#
# LOCAL SERVER (files ending _local): see 000_run_python_mini_server.txt
# =============================================================================


# -----------------------------------------------------------------------------
# SETUP
# -----------------------------------------------------------------------------
for (pkg in c("httr2", "httpuv", "dplyr", "tibble")) {   # httpuv: needed by req_dry_run()
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}
library(httr2)
library(dplyr)
library(tibble)
source("rstudio/http_helpers.R")   # message_request(), show(), send_http_file() ...


# =============================================================================
# Chapter 3 - The local server (_local)
# =============================================================================

# E301  GET root, expect 200 (local)
req <- message_request("messages/E301_get_root_200_local.http")
req_dry_run(req)
resp <- show(req)

# E302  GET foldernoSlash, expect 301 (local)
#   httr2 follows redirects by default; followlocation = FALSE shows the 301.
req <- message_request("messages/E302_get_foldernoSlash_301_local.http") |> req_options(followlocation = FALSE)
resp <- show(req)

# E303  GET folder slash, expect 200 (local)
req <- message_request("messages/E303_get_folder_slash_200_local.http")
resp <- show(req)

# E304  GET missingFile, expect 404 (local)
req <- message_request("messages/E304_get_missingFile_404_local.http")
resp <- show(req)

# E305  HEAD root, expect 200 (local)
req <- message_request("messages/E305_head_root_200_local.http")
resp <- show(req)

# E306  GET badMethod, expect 501 (local)
req <- message_request("messages/E306_get_badMethod_501_local.http")
resp <- show(req)

# E307  GET file, expect 200 (local)
req <- message_request("messages/E307_get_file_200_local.http")
resp <- show(req)

# E308  GET subFolderFile, expect 200 (local)
req <- message_request("messages/E308_get_subFolderFile_200_local.http")
resp <- show(req)

# E309  GET doubleSlash, expect 200 (local)
req <- message_request("messages/E309_get_doubleSlash_200_local.http")
resp <- show(req)

# E310  HEAD file headers, expect 200 (local)
req <- message_request("messages/E310_head_file_headers_200_local.http")
resp <- show(req)

# E311  GET fileNameSpaces, expect 400 (local)
#   Raw spaces in the URL: see whether httr2 refuses or encodes them (req_dry_run).
req <- message_request("messages/E311_get_fileNameSpaces_400_local.http")
req_dry_run(req)
resp <- show(req)
send_http_file("messages/E311_get_fileNameSpaces_400_local.http")                 # the raw Carrier, for comparison

# E312  GET fileNameQuotes, expect 400 (local)
#   Raw quotes and spaces: compare with E311.
req <- message_request("messages/E312_get_fileNameQuotes_400_local.http")
resp <- show(req)
send_http_file("messages/E312_get_fileNameQuotes_400_local.http")                 # the raw Carrier, for comparison

# E313  GET fileNameUrlEncoding, expect 200 (local)
req <- message_request("messages/E313_get_fileNameUrlEncoding_200_local.http")
resp <- show(req)

# E314  GET fileNameSpecialCharUrlEncoding, expect 200 (local)
req <- message_request("messages/E314_get_fileNameSpecialCharUrlEncoding_200_local.http")
resp <- show(req)

# E315  GET root missingHost, expect 200 (local)
#   httr2 always sends Host, so the mistake only shows with the raw Carrier.
req <- message_request("messages/E315_get_root_missingHost_200_local.http")
resp <- show(req)
send_http_file("messages/E315_get_root_missingHost_200_local.http")                 # the raw Carrier, for comparison


# =============================================================================
# Chapter 4 - GET on the internet (_internet)
# =============================================================================

# E401  GET httpbin get, expect 200 (internet)
req <- message_request("messages/E401_get_httpbin_get_200_internet.http")
resp <- show(req)

# E402  GET httpbin ip, expect 200 (internet)
req <- message_request("messages/E402_get_httpbin_ip_200_internet.http")
resp <- show(req)

# E403  GET example, expect 200 (internet)
req <- message_request("messages/E403_get_example_200_internet.http")
resp <- show(req)

# E404  GET httpbin missingHost, expect 400 (internet)
#   httr2 always sends Host, so the mistake only shows with the raw Carrier.
req <- message_request("messages/E404_get_httpbin_missingHost_400_internet.http")
resp <- show(req)
send_http_file("messages/E404_get_httpbin_missingHost_400_internet.http")                 # the raw Carrier, for comparison

# E405  GET httpbin queryString, expect 200 (internet)
req <- message_request("messages/E405_get_httpbin_queryString_200_internet.http")
resp <- show(req)

# E406  GET httpbin querySpaceEncoded, expect 200 (internet)
req <- message_request("messages/E406_get_httpbin_querySpaceEncoded_200_internet.http")
resp <- show(req)

# E407  GET httpbin queryAmpersandEncoded, expect 200 (internet)
req <- message_request("messages/E407_get_httpbin_queryAmpersandEncoded_200_internet.http")
resp <- show(req)

# E408  GET httpbin queryPlusSign, expect 200 (internet)
req <- message_request("messages/E408_get_httpbin_queryPlusSign_200_internet.http")
resp <- show(req)

# E409  GET httpbin multipleHeaders, expect 200 (internet)
req <- message_request("messages/E409_get_httpbin_multipleHeaders_200_internet.http")
resp <- show(req)

# E410  GET httpbin status201, expect 201 (internet)
req <- message_request("messages/E410_get_httpbin_status201_201_internet.http")
resp <- show(req)

# E411  GET httpbin status204, expect 204 (internet)
req <- message_request("messages/E411_get_httpbin_status204_204_internet.http")
resp <- show(req)

# E412  GET httpbin status500, expect 500 (internet)
req <- message_request("messages/E412_get_httpbin_status500_500_internet.http")
resp <- show(req)

# E413  GET httpbin redirectChain, expect 302 (internet)
#   followlocation = FALSE shows the first 302 instead of following it.
req <- message_request("messages/E413_get_httpbin_redirectChain_302_internet.http") |> req_options(followlocation = FALSE)
resp <- show(req)

# E414  GET httpbin keepAliveTwoRequests, expect 200 (internet)
#   The file holds two requests; only the first is sent.
req <- message_request("messages/E414_get_httpbin_keepAliveTwoRequests_200_internet.http")
resp <- show(req)


# =============================================================================
# Chapter 5 - Sending data: POST and other methods (_internet)
# =============================================================================

# E501  POST httpbinText, expect 200 (internet)
req <- message_request("messages/E501_post_httpbinText_200_internet.http")
req_dry_run(req)
resp <- show(req)

# E502  POST httpbinJson, expect 200 (internet)
req <- message_request("messages/E502_post_httpbinJson_200_internet.http")
resp <- show(req)

# E503  POST httpbinText shortLength, expect 200 (internet)
#   httr2 calculates Content-Length itself: the wrong length in the file is
#   not copied, so the whole body arrives. Compare with the raw Carrier.
req <- message_request("messages/E503_post_httpbinText_shortLength_200_internet.http")
resp <- show(req)
send_http_file("messages/E503_post_httpbinText_shortLength_200_internet.http")                 # the raw Carrier, for comparison

# E504  POST httpbinText longLength, timeout (internet)
#   Same as E503: httr2 sets the right length, so nothing hangs.
#   (The raw Carrier waits up to 10 seconds here.)
req <- message_request("messages/E504_post_httpbinText_longLength_timeout_internet.http")
resp <- show(req)
send_http_file("messages/E504_post_httpbinText_longLength_timeout_internet.http")                 # the raw Carrier, for comparison

# E505  POST httpbinText, missingLengthNoData (internet)
#   Same as E503: httr2 adds the Content-Length that the file left out.
req <- message_request("messages/E505_post_httpbinText_missingLengthNoData_internet.http")
resp <- show(req)
send_http_file("messages/E505_post_httpbinText_missingLengthNoData_internet.http")                 # the raw Carrier, for comparison

# E506  POST httpbinText missingBlankLine, expect 400 (internet)
#   No empty line in the file, so "hello world" is read as a header line.
req <- message_request("messages/E506_post_httpbinText_missingBlankLine_400_internet.http")
resp <- show(req)
send_http_file("messages/E506_post_httpbinText_missingBlankLine_400_internet.http")                 # the raw Carrier, for comparison

# E507  PUT httpbinJson, expect 200 (internet)
req <- message_request("messages/E507_put_httpbinJson_200_internet.http")
resp <- show(req)

# E508  PATCH httpbinJson, expect 200 (internet)
req <- message_request("messages/E508_patch_httpbinJson_200_internet.http")
resp <- show(req)

# E509  DELETE httpbin, expect 200 (internet)
req <- message_request("messages/E509_delete_httpbin_200_internet.http")
resp <- show(req)

# E510  OPTIONS httpbin, expect 200 (internet)
req <- message_request("messages/E510_options_httpbin_200_internet.http")
resp <- show(req)

# E511  GET httpbin wrongMethod, expect 405 (internet)
req <- message_request("messages/E511_get_httpbin_wrongMethod_405_internet.http")
resp <- show(req)


# =============================================================================
# All Part 1 Messages at once: did each one get the status its name predicts?
# =============================================================================
# A for loop over the files, results collected in a tibble.
# Errors (for example a URL httr2 refuses, E311) are recorded, not stopped on.

part1_files <- list.files("messages", pattern = "^E[345][0-9]{2}_.*\\.http$", full.names = TRUE)

results <- list()
for (f in part1_files) {
  status <- tryCatch({
    resp <- message_request(f) |>
      req_options(followlocation = FALSE) |>
      req_timeout(10) |>
      req_error(is_error = never_error) |>
      req_perform()
    as.character(resp_status(resp))
  }, error = function(e) "error")
  results[[f]] <- tibble(
    id       = substr(basename(f), 1, 4),
    expected = expected_status(f),
    received = status
  )
}

results_df <- bind_rows(results) |>
  mutate(same = expected == received)

results_df |> print(n = Inf)
results_df |> filter(!same)     # where httr2 differs from the raw Carrier: the lesson of chapter 6
