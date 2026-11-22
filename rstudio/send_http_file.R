# =============================================================================
# send_http_file.R - send the raw .http files from RStudio, like telnet
# =============================================================================
#
# The lowest level, but from R: the file is sent byte for byte, exactly as
# written - nothing is added or fixed. So the "mistake" experiments
# (311, 312, 503 - 506, 404, 315) work here too, unlike with httr2.
#
# Only plain HTTP (files in ../telnet). HTTPS (../openssl) needs
# encryption, which a plain socket connection can't do.
#
# HOW TO USE
#   Open the repo folder as RStudio project (working directory = repo root),
#   run the function definition once, then one example at a time.
#   Files without "Connection: close" (502, 504) wait up to `timeout` seconds,
#   just like telnet hangs.
# =============================================================================

send_http_file <- function(file, host, port = 80, timeout = 10) {
  # read the file exactly as it is
  request_text <- readChar(file, file.size(file), useBytes = TRUE)

  # HTTP officially wants CRLF ("\r\n") line endings; the files use "\n"
  request_text <- gsub("\r?\n", "\r\n", request_text)

  # open a raw connection, like: telnet host port
  con <- socketConnection(host = host, port = port, open = "r+",
                          blocking = TRUE, timeout = timeout)
  on.exit(close(con))

  cat(request_text, file = con)          # "paste" the request
  readLines(con, warn = FALSE)           # read the raw response
}

dir <- "telnet"

# Local server (start it first: cd http_mini_server_root; python3 -m http.server 8080 --bind 127.0.0.1)
send_http_file(file.path(dir, "E301_get_root_200_telnet_local.http"), "127.0.0.1", 8080)
send_http_file(file.path(dir, "E311_get_fileNameSpaces_400_telnet_local.http"), "127.0.0.1", 8080)
send_http_file(file.path(dir, "E313_get_fileNameUrlEncoding_200_telnet_local.http"), "127.0.0.1", 8080)

# Internet server, port 80
send_http_file(file.path(dir, "E402_get_httpbin_ip_200_telnet_internet.http"), "httpbin.org")
send_http_file(file.path(dir, "E503_post_httpbinText_shortLength_200_telnet_internet.http"), "httpbin.org")
send_http_file(file.path(dir, "E506_post_httpbinText_missingBlankLine_400_telnet_internet.http"), "httpbin.org")

# Only the status line of every local file, with a for loop
local_files <- list.files(dir, pattern = "_telnet_local\\.http$")
for (f in local_files) {
  response <- send_http_file(file.path(dir, f), "127.0.0.1", 8080)
  cat(f, "->", response[1], "\n")      # first line = status line
}
