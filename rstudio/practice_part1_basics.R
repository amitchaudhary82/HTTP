# =============================================================================
# practice_part1_basics.R - Part 1 (chapters 3 - 5) with httr2
# =============================================================================
#
# The Message files (messages/) are the golden source: nothing is copied
# here. read_http_message_from_file() reads a file; WHERE it goes (host,
# port) is always written in the call - the Message and the Carrier stay apart.
#
# HOW TO USE
#   Open the repository folder in RStudio (working directory = repo root),
#   run SETUP once, then one example at a time (Cmd+Enter).
#     req_dry_run(req)   what httr2 WOULD send (nothing is sent)
#     send_request_to_server(req)   send it; "->" = sent, "<-" = received
#
#   send_raw_http_message_to_server() sends the Message byte for byte (raw
#   Carrier) - used below wherever httr2 behaves differently, so you can compare.
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
source("rstudio/http_helpers.R")   # read_http_message_from_file(), send_..., prepare_... (see the file header)




# =============================================================================
# Chapter 3 - Example 1: Send HTTP Local Server via R Studio
# =============================================================================

# 1. The Message: the same text you typed in telnet.
#    \r\n is the line ending HTTP needs; telnet adds it when you press Enter.
#    The empty line at the end (\r\n\r\n) means "headers finished".
# final message should have proper CRLF msg <- "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
example_msg <- "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"

# prepare the message
head_lines <- c(
  "GET / HTTP/1.1",
  "Host: localhost"
)
body <- ""

# Every line ends with CRLF (\r\n).
# At the end there are 2 CRLF:
#   1st: ends the last header line (Host: localhost)
#   2nd: an empty line = "headers finished"; the server can now answer
msg <- paste0(paste0(head_lines, collapse = "\r\n"), "\r\n\r\n", body)
print(msg)

# Compare
identical(msg, example_msg)


# 2. Open the connection (like: telnet 127.0.0.1 8080)
con <- socketConnection(host = "127.0.0.1", port = 8080,
                        open = "r+", blocking = TRUE, timeout = 10)  # r+ read and write, refer modes for more options


# 3. Send it (like typing it and pressing Enter)
#    Some connections first collect text in a small waiting area (a buffer)
#    and send it later; flush() pushes it out now.
writeChar(msg, con, eos = NULL)   # eos = NULL: send only the text, no extra end byte
flush(con)                        # send whatever is still waiting, now


# 4. Read the answer (what telnet printed on screen)
answer <- readLines(con, warn = FALSE)
close(con)

cat(answer, sep = "\n")



# =============================================================================
# Chapter 3 - Example 2: Send existing HTTP message from Message File
# =============================================================================

# 1. Prepare the Message: read the whole file
#    (head lines + empty line + body, all in one string)
file <- "messages/E301_get_root_200_local.http"
msg_file  <- readChar(con=file, nchars=file.size(file))   # readChar() needs to know how many characters to read; it has no "read everything" option

# Make Files message compatible with HTTP
msg_file <- gsub("\r?\n", "\r\n", msg_file)   # file has \n, HTTP needs \r\n

# Compare
print(msg_file)
identical(msg_file, example_msg)


# 2. Open the connection (like: telnet 127.0.0.1 8080)
con <- socketConnection(host = "127.0.0.1", port = 8080,
                        open = "r+", blocking = TRUE, timeout = 10)  # r+ read and write, refer modes for more options


# 3. Send it (like typing it and pressing Enter)
#    Some connections first collect text in a small waiting area (a buffer)
#    and send it later; flush() pushes it out now.
writeChar(msg_file, con, eos = NULL)   # eos = NULL: send only the text, no extra end byte
flush(con)                             # send whatever is still waiting, now


# 4. Read the answer (what telnet printed on screen)
answer <- readLines(con, warn = FALSE)
close(con)

cat(answer, sep = "\n")




# =============================================================================
# Chapter 3 - Example 3: Make our own Function
# =============================================================================
read_http_message_from_file <- function(file_name) {
  msg_file  <- readChar(con=file_name, nchars=file.size(file_name))   # readChar() needs to know how many characters to read; it has no "read everything" option
  msg_file <- gsub("\r?\n", "\r\n", msg_file)   # file has \n, HTTP needs \r\n, hence make it compatible with HTTP
  return(msg_file)
}

local_fx_send_raw_http_message_to_server <- function(msg, host_name, port_number, timeout_value = 10) {
  
  # 2. Open the connection
  con <- socketConnection(host = host_name, port = port_number,
                          open = "r+", blocking = TRUE, timeout = timeout_value)  # r+ read and write, refer modes for more options
  
  on.exit(close(con)) # is new: it closes the connection whenever the function ends, even if something goes wrong
  
  # 3. Send Raw Message to Server
  #    Some connections first collect text in a small waiting area (a buffer)
  #    and send it later; flush() pushes it out now.
  writeChar(msg, con, eos = NULL)   # eos = NULL: send only the text, no extra end byte
  flush(con)                             # send whatever is still waiting, now
  
  
  # 4. Read the answer (what telnet printed on screen)
  answer <- readLines(con, warn = FALSE)
  
  return(answer)
}

# Repeat Example 1
answer <- local_fx_send_raw_http_message_to_server("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n", "127.0.0.1", 8080)
cat(answer, sep = "\n")

# Repeat Example 2
answer <- local_fx_send_raw_http_message_to_server(read_http_message_from_file("messages/E301_get_root_200_local.http"),"127.0.0.1", 8080)
cat(answer, sep = "\n")


# Another Example 3
answer <- local_fx_send_raw_http_message_to_server(read_http_message_from_file("messages/E304_get_missingFile_404_local.http"),"127.0.0.1", 8080)
cat(answer, sep = "\n")


# Read a valid file
answer <- local_fx_send_raw_http_message_to_server("GET /testfile.txt HTTP/1.1\r\nHost: localhost\r\n\r\n", "127.0.0.1", 8080)
cat(answer, sep = "\n")




# =============================================================================
# Chapter 3 - Example 5: the same with httr2 (already known pagkage)

# Think of HTTP as sending a letter
# Examples 1–3: you write the whole letter yourself, word for word, take it to the post office (send_raw_http_message_to_server), and get the reply back as raw text.
# httr2: you fill in a form instead (address, path, method), and httr2 writes the letter for you, posts it, and opens the reply for you.

# Why are we switching to httr
# Because writing the letter by hand gets hard quickly:
#   
#   HTTPS: your socket can't encrypt (chapter 8). httr2 can.
# Spaces or & in a query: you'd have to encode them yourself (E406, E407).
# JSON body: you'd have to count Content-Length yourself (chapter 5).
# Redirects: you'd have to send a second request yourself (E302, E413).
# The answer: you get raw lines and have to find the status yourself.

# httr2 does all of this for you. The price is that you no longer see the letter, and that's why req_dry_run() exists: it shows you the letter httr2 wrote.

# WE DESCRIBE REQUEST AS URL 
# GET http://127.0.0.1:8080/testfile.txt

# HTTR TURNS INTO THE HTTP MESSAGE 
# GET /testfile.txt HTTP/1.1
# Host: 127.0.0.1:8080

# =============================================================================

# 1. Fill in the form
req <- request("http://127.0.0.1:8080")          # = host + port (and the Host header)
print(req)

req <- req_method(req, "GET")                    # = GET
print(req)

req <- req_url_path_append(req, "testfile.txt")
print(req)

# 2. Look at the Message httr2 wrote (nothing is sent)
#    Compare with the string in Example 4
req_dry_run(req)

# 3. Send it (= send_raw_http_message_to_server)
resp <- req_perform(req)
print(resp)                              # short summary: status, type, body size

# 4. The answer, already opened for us (= answer in Example 4)
resp_status(resp)                        # 200            = "HTTP/1.0 200 OK" (first line)
resp_status_desc(resp)                   # "OK"
resp_headers(resp)                       # header lines   = the lines after the first one
resp_header(resp, "Content-Length")      # one header     = the file size in bytes
resp_body_string(resp)                   # the body       = the text after the empty line

# 5. Compare with Example 4: the same answer, but there as raw lines
answer <- send_raw_http_message_to_server("GET /testfile.txt HTTP/1.1\r\nHost: localhost\r\n\r\n", "127.0.0.1", 8080)
cat(answer, sep = "\n")


# =============================================================================
# Chapter 3 - Example 6: Simplify using Pipes
# =============================================================================
req <-
  request("http://127.0.0.1:8080") %>%     # = host + port (and the Host header)
  req_method("GET") %>%                          # = GET
  req_url_path_append("testfile.txt")            # = /testfile.txt
  
# dry run  
req_dry_run(req)  

# actual run
resp <- req_perform(req)                                  # = send_raw_http_message_to_server
print(resp)

# 4. The answer
resp %>% resp_status()                           # 200
resp %>% resp_status_desc()                      # "OK"
resp %>% resp_headers()
resp %>% resp_header("Content-Length")
resp %>% resp_body_string()





# =============================================================================
# Chapter 3 - The local server (_local)
# =============================================================================

# E301  GET root, expect 200 (local)
req <-
  read_http_message_from_file("messages/E301_get_root_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E302  GET foldernoSlash, expect 301 (local)
#   Our helpers are strict: the 301 is shown, not followed (like telnet).
#   To let httr2 follow it, add  follow_redirects = TRUE  to the prepare_... call.
req <-
  read_http_message_from_file("messages/E302_get_foldernoSlash_301_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E303  GET folder slash, expect 200 (local)
req <-
  read_http_message_from_file("messages/E303_get_folder_slash_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E304  GET missingFile, expect 404 (local)
req <-
  read_http_message_from_file("messages/E304_get_missingFile_404_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E305  HEAD root, expect 200 (local)
req <-
  read_http_message_from_file("messages/E305_head_root_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E306  GET badMethod, expect 501 (local)
req <-
  read_http_message_from_file("messages/E306_get_badMethod_501_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E307  GET file, expect 200 (local)
req <-
  read_http_message_from_file("messages/E307_get_file_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E308  GET subFolderFile, expect 200 (local)
req <-
  read_http_message_from_file("messages/E308_get_subFolderFile_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E309  GET doubleSlash, expect 200 (local)
req <-
  read_http_message_from_file("messages/E309_get_doubleSlash_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E310  HEAD file headers, expect 200 (local)
req <-
  read_http_message_from_file("messages/E310_head_file_headers_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E311  GET fileNameSpaces, expect 400 (local)
#   Raw spaces in the URL: see whether httr2 refuses or encodes them (req_dry_run).
req <-
  read_http_message_from_file("messages/E311_get_fileNameSpaces_400_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E311_get_fileNameSpaces_400_local.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("127.0.0.1", 8080) %>%
  cat(sep = "\n")

# E312  GET fileNameQuotes, expect 400 (local)
#   Raw quotes and spaces: compare with E311.
req <-
  read_http_message_from_file("messages/E312_get_fileNameQuotes_400_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E312_get_fileNameQuotes_400_local.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("127.0.0.1", 8080) %>%
  cat(sep = "\n")

# E313  GET fileNameUrlEncoding, expect 200 (local)
req <-
  read_http_message_from_file("messages/E313_get_fileNameUrlEncoding_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E314  GET fileNameSpecialCharUrlEncoding, expect 200 (local)
req <-
  read_http_message_from_file("messages/E314_get_fileNameSpecialCharUrlEncoding_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)

# E315  GET root missingHost, expect 200 (local)
#   httr2 always sends Host, so the mistake only shows with the raw Carrier.
req <-
  read_http_message_from_file("messages/E315_get_root_missingHost_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E315_get_root_missingHost_200_local.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("127.0.0.1", 8080) %>%
  cat(sep = "\n")


# =============================================================================
# Chapter 4 - GET on the internet (_internet)
# =============================================================================

# E401  GET httpbin get, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E401_get_httpbin_get_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E402  GET httpbin ip, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E402_get_httpbin_ip_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E403  GET example, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E403_get_example_200_internet.http") %>%
    prepare_request_from_http_message("example.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E404  GET httpbin missingHost, expect 400 (internet)
#   httr2 always sends Host, so the mistake only shows with the raw Carrier.
req <-
  read_http_message_from_file("messages/E404_get_httpbin_missingHost_400_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E404_get_httpbin_missingHost_400_internet.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("httpbin.org", 80) %>%
  cat(sep = "\n")

# E405  GET httpbin queryString, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E405_get_httpbin_queryString_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E406  GET httpbin querySpaceEncoded, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E406_get_httpbin_querySpaceEncoded_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E407  GET httpbin queryAmpersandEncoded, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E407_get_httpbin_queryAmpersandEncoded_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E408  GET httpbin queryPlusSign, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E408_get_httpbin_queryPlusSign_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E409  GET httpbin multipleHeaders, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E409_get_httpbin_multipleHeaders_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E410  GET httpbin status201, expect 201 (internet)
req <-
  read_http_message_from_file("messages/E410_get_httpbin_status201_201_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E411  GET httpbin status204, expect 204 (internet)
req <-
  read_http_message_from_file("messages/E411_get_httpbin_status204_204_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E412  GET httpbin status500, expect 500 (internet)
req <-
  read_http_message_from_file("messages/E412_get_httpbin_status500_500_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E413  GET httpbin redirectChain, expect 302 (internet)
#   Strict helpers: the first 302 is shown instead of following the chain.
req <-
  read_http_message_from_file("messages/E413_get_httpbin_redirectChain_302_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E414  GET httpbin keepAliveTwoRequests, expect 200 (internet)
#   The file holds two requests; only the first is sent.
req <-
  read_http_message_from_file("messages/E414_get_httpbin_keepAliveTwoRequests_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)


# =============================================================================
# Chapter 5 - Sending data: POST and other methods (_internet)
# =============================================================================

# E501  POST httpbinText, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E501_post_httpbinText_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E502  POST httpbinJson, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E502_post_httpbinJson_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E503  POST httpbinText shortLength, expect 200 (internet)
#   httr2 calculates Content-Length itself: the wrong length in the file is
#   not copied, so the whole body arrives. Compare with the raw Carrier.
req <-
  read_http_message_from_file("messages/E503_post_httpbinText_shortLength_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E503_post_httpbinText_shortLength_200_internet.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("httpbin.org", 80) %>%
  cat(sep = "\n")

# E504  POST httpbinText longLength, timeout (internet)
#   Same as E503: httr2 sets the right length, so nothing hangs.
#   (The raw Carrier waits up to 10 seconds here.)
req <-
  read_http_message_from_file("messages/E504_post_httpbinText_longLength_timeout_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E504_post_httpbinText_longLength_timeout_internet.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("httpbin.org", 80) %>%
  cat(sep = "\n")

# E505  POST httpbinText, missingLengthNoData (internet)
#   Same as E503: httr2 adds the Content-Length that the file left out.
req <-
  read_http_message_from_file("messages/E505_post_httpbinText_missingLengthNoData_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E505_post_httpbinText_missingLengthNoData_internet.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("httpbin.org", 80) %>%
  cat(sep = "\n")

# E506  POST httpbinText missingBlankLine, expect 400 (internet)
#   No empty line in the file, so "hello world" is read as a header line.
req <-
  read_http_message_from_file("messages/E506_post_httpbinText_missingBlankLine_400_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)
read_http_message_from_file("messages/E506_post_httpbinText_missingBlankLine_400_internet.http") %>%   # the raw Carrier, for comparison
  send_raw_http_message_to_server("httpbin.org", 80) %>%
  cat(sep = "\n")

# E507  PUT httpbinJson, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E507_put_httpbinJson_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E508  PATCH httpbinJson, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E508_patch_httpbinJson_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E509  DELETE httpbin, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E509_delete_httpbin_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E510  OPTIONS httpbin, expect 200 (internet)
req <-
  read_http_message_from_file("messages/E510_options_httpbin_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E511  GET httpbin wrongMethod, expect 405 (internet)
req <-
  read_http_message_from_file("messages/E511_get_httpbin_wrongMethod_405_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)


# =============================================================================
# All Part 1 Messages at once: did each one get the status its name predicts?
# =============================================================================
# A for loop over the files, results collected in a tibble.
# Errors (for example a URL httr2 refuses, E311) are recorded, not stopped on.

part1_files <- list.files("messages", pattern = "^E[345][0-9]{2}_.*\\.http$", full.names = TRUE)

results <- list()
for (f in part1_files) {
  msg   <- read_http_message_from_file(f)
  parts <- split_http_message_into_parts(msg)

  # WHERE it goes - decided here by the caller, not by the helpers:
  #   _local files -> our local server, the others -> their Host line, port 80
  if (grepl("_local\\.http$", f)) {
    host <- "127.0.0.1"
    port <- 8080
  } else {
    host <- header_value(parts$headers, "host")
    if (host == "") host <- "httpbin.org"          # E404 has no Host line
    port <- 80
  }

  status <- tryCatch({
    resp <- msg %>%
      prepare_request_from_http_message(host, port) %>%
      req_timeout(10) %>%
      req_error(is_error = never_error) %>%
      req_perform()
    as.character(resp_status(resp))
  }, error = function(e) "error")
  results[[f]] <- tibble(
    id       = substr(basename(f), 1, 4),
    expected = expected_status(f),
    received = status
  )
}

results_df <- bind_rows(results) %>%
  mutate(same = expected == received)

results_df %>% print(n = Inf)
results_df %>% filter(!same)     # where httr2 differs from the raw Carrier: the lesson of chapter 6
