# =============================================================================
# send_http_file.R - send the raw .http files from RStudio, like telnet
# =============================================================================
#
# Sends a plain-text request file over a raw TCP connection. LF line endings
# are converted to HTTP's CRLF, and a final CRLF is added when needed to
# terminate the request. The response is returned as text lines.
# So the "mistake" experiments (311, 312, 503 - 506, 404, 315) work here too,
# unlike with httr2.
#
# Only plain HTTP (files in ../telnet). HTTPS (../openssl) needs
# encryption, which a plain socket connection can't do.
#
# HOW TO USE
#   Open the repo folder as RStudio project (working directory = repo root),
#   source this file to define the helper, then run one example at a time.
#   Files without "Connection: close" (502, 504) wait up to `timeout` seconds,
#   just like telnet hangs.
# =============================================================================

send_http_file <- function(file, host, port = 80, timeout = 10) {
  if (!file.exists(file)) {
    stop("Request file does not exist: ", file, call. = FALSE)
  }

  request_text <- readChar(file, file.size(file), useBytes = TRUE)

  # The request fixtures use LF; HTTP headers use CRLF on the wire.
  request_text <- gsub("\r?\n", "\r\n", request_text)
  if (!grepl("\r\n\r\n$", request_text)) {
    request_text <- paste0(request_text, "\r\n")
  }

  con <- socketConnection(host = host, port = port, open = "r+",
                          blocking = TRUE, timeout = timeout)
  on.exit(close(con))

  writeChar(request_text, con, eos = NULL, useBytes = TRUE)
  flush(con)
  response <- readLines(con, warn = FALSE)
  if (length(response) == 0L) {
    stop("No response received from ", host, ":", port, call. = FALSE)
  }
  response
}

# Run individual examples explicitly, e.g.:
# send_http_file("telnet/E301_get_root_200_telnet_local.http", "127.0.0.1", 8080)
# send_http_file("telnet/E402_get_httpbin_ip_200_telnet_internet.http", "httpbin.org")
