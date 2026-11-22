# =============================================================================
# http_helpers.R - shared functions for the practice scripts (Part 1 and 2)
# =============================================================================
#
# Only definitions live here: sourcing this file sends nothing.
# The practice files start with:   source("rstudio/http_helpers.R")
#
# The Message and the Carrier stay apart:
#   - a Message file only stores the HTTP text
#   - WHERE it goes (host, port, scheme) is always given by you when you call
#     a function; nothing here guesses the server
#
# The functions follow Examples 1 - 6 in practice_part1_basics.R.
# "read/split/prepare" = nothing is sent;  "send" = something goes out.
#
#   THE MESSAGE
#     read_http_message_from_file(file)        file -> HTTP text (CRLF)
#     split_http_message_into_parts(msg)       HTTP text -> method, path,
#                                              headers, body
#
#   THE CARRIER - raw socket, no httr2 (Examples 1 - 3)
#     send_raw_http_message_to_server(msg, host, port)
#                                              send HTTP text exactly as it
#                                              is, return the answer lines
#
#   THE FORM - httr2 writes the Message for us (Examples 5 - 6)
#     prepare_request_from_parts(scheme, host, port, method, path, headers, body,
#                                follow_redirects = FALSE)
#                                              the ONLY function that fills
#                                              in the httr2 form; strict by
#                                              default: a 301/302 is shown,
#                                              not followed
#     prepare_request_from_http_message(msg, host, port, scheme)
#                                              HTTP text -> parts -> form
#     send_request_to_server(req)              httr2 sends it, prints the
#                                              conversation, keeps 4xx/5xx
#
#   SMALL HELPERS
#     header_value(headers, name)              one header, any upper/lower case
#     never_error(resp)                        for req_error(): never an R error
#     expected_status(file)                    the status the file name predicts
#
# Typical use (pipes):
#   read_http_message_from_file("messages/E301_get_root_200_local.http") %>%
#     send_raw_http_message_to_server("127.0.0.1", 8080)
#
#   req <-
#     read_http_message_from_file("messages/E301_get_root_200_local.http") %>%
#     prepare_request_from_http_message("127.0.0.1", 8080)
#   req_dry_run(req)
#   resp <- send_request_to_server(req)
# =============================================================================

library(httr2)


# =============================================================================
# SMALL HELPERS
# =============================================================================

# -----------------------------------------------------------------------------
# Keep 4xx/5xx responses instead of stopping with an R error
# -----------------------------------------------------------------------------
never_error <- function(resp) FALSE


# -----------------------------------------------------------------------------
# The status the file name predicts: E304_get_missingFile_404_local.http -> "404"
# -----------------------------------------------------------------------------
expected_status <- function(file) {
  parts <- strsplit(sub("\\.http$", "", basename(file)), "_")[[1]]
  parts[length(parts) - 1]
}


# -----------------------------------------------------------------------------
# One header from the list, name in any upper/lower case ("" if missing)
#   header_value(parts$headers, "host")   -> "localhost"
# -----------------------------------------------------------------------------
header_value <- function(headers, name) {
  for (header_name in names(headers)) {
    if (tolower(header_name) == tolower(name)) {
      return(headers[[header_name]])
    }
  }
  ""
}


# =============================================================================
# THE MESSAGE
# =============================================================================

# -----------------------------------------------------------------------------
# Read a Message file and make it ready for HTTP (CRLF line endings)
# -----------------------------------------------------------------------------
read_http_message_from_file <- function(file_name) {
  if (!file.exists(file_name)) {
    stop("Message file does not exist: ", file_name, call. = FALSE)
  }
  msg_file <- readChar(con = file_name, nchars = file.size(file_name), useBytes = TRUE)
  gsub("\r?\n", "\r\n", msg_file)                # file has \n, HTTP needs \r\n
}


# -----------------------------------------------------------------------------
# HTTP text -> its parts: list(method, path, headers, body)
#   "GET /testfile.txt HTTP/1.1\r\nHost: localhost\r\n\r\n"
#   -> method "GET", path "/testfile.txt", headers list(Host = "localhost"),
#      body ""
#   Works with CRLF (\r\n) and LF (\n) line endings.
# -----------------------------------------------------------------------------
split_http_message_into_parts <- function(msg) {
  msg <- gsub("\r\n", "\n", msg)                 # one line-ending style to work with

  # head | empty line | body
  split_at <- regexpr("\n\n", msg, fixed = TRUE)
  if (split_at == -1) {                          # no empty line (E506)
    head_text <- msg
    body      <- ""
  } else {
    head_text <- substr(msg, 1, split_at - 1)
    body      <- substr(msg, split_at + 2, nchar(msg))
  }
  head_lines <- strsplit(head_text, "\n", fixed = TRUE)[[1]]

  # first line: METHOD PATH VERSION (PATH may contain spaces, see E311)
  words  <- strsplit(head_lines[1], " ")[[1]]
  method <- words[1]
  path   <- paste(words[2:(length(words) - 1)], collapse = " ")

  # header lines: "Name: value"
  headers <- list()
  for (line in head_lines[-1]) {
    if (!grepl(":", line)) next                  # not a header (E506: the body line)
    name  <- trimws(sub(":.*$", "", line))
    value <- trimws(sub("^[^:]*:", "", line))
    headers[[name]] <- value
  }

  # a second request after the empty line (E414) is not a body
  if (grepl("^[A-Z]+ [^ ]+ HTTP/", body)) {
    message("Note: the Message holds more than one request; only the first is used.")
    body <- ""
  }

  list(method = method, path = path, headers = headers, body = body)
}


# =============================================================================
# THE CARRIER - raw socket, no httr2 (Examples 1 - 3)
# =============================================================================

# -----------------------------------------------------------------------------
# Send HTTP text exactly as it is (like telnet) and return the answer lines
#   Plain HTTP only: a raw socket cannot encrypt (HTTPS: carriers/openssl.txt).
#   Messages without "Connection: close" (E502, E504) wait up to
#   timeout_value seconds.
# -----------------------------------------------------------------------------
send_raw_http_message_to_server <- function(msg, host_name, port_number, timeout_value = 10) {
  # 2. Open the connection
  con <- socketConnection(host = host_name, port = as.integer(port_number),
                          open = "r+", blocking = TRUE, timeout = timeout_value)
  on.exit(close(con))                            # closes the connection whenever the function ends

  # 3. Send the Message
  writeChar(msg, con, eos = NULL, useBytes = TRUE)   # eos = NULL: only the text, no extra end byte
  flush(con)                                     # send whatever is still waiting, now

  # 4. Read the answer
  answer <- readLines(con, warn = FALSE)
  if (length(answer) == 0) {
    stop("No answer from ", host_name, ":", port_number, call. = FALSE)
  }
  answer
}


# =============================================================================
# THE FORM - httr2 writes the Message for us (Examples 5 - 6)
# =============================================================================

# -----------------------------------------------------------------------------
# Fill in the httr2 form from parts - the only function that builds a request
#   prepare_request_from_parts("http", "127.0.0.1", 8080, "GET", "/testfile.txt")
#   Host and Content-Length are NOT copied: httr2 (curl) writes them itself.
# -----------------------------------------------------------------------------
prepare_request_from_parts <- function(scheme, host, port, method = "GET", path = "/",
                                       headers = list(), body = "",
                                       follow_redirects = FALSE) {
  # address: scheme://host:port (the port is left out when it is the usual one)
  base_url <- paste0(scheme, "://", host)
  usual_port <- (scheme == "http" && port == 80) || (scheme == "https" && port == 443)
  if (!usual_port) {
    base_url <- paste0(base_url, ":", port)
  }

  # = request(base_url) + req_url_path_append(path), in one go, so the path and
  #   a query (?city=St%20Gallen) stay exactly as written in the Message
  req <- request(paste0(base_url, path))
  req <- req_method(req, method)

  content_type <- "text/plain"
  for (name in names(headers)) {
    value <- headers[[name]]
    if (tolower(name) %in% c("host", "content-length")) next   # httr2 writes these
    if (tolower(name) == "content-type") {
      content_type <- value                                    # used with the body
      next
    }
    req <- req_headers(req, !!name := value)
  }

  if (body != "") {
    req <- req_body_raw(req, body, type = content_type)
  }

  # Strict like telnet: show a 301/302 instead of asking again at its Location.
  # follow_redirects = TRUE gives httr2's normal behaviour (follow them).
  if (!follow_redirects) {
    req <- req_options(req, followlocation = FALSE)
  }
  req
}


# -----------------------------------------------------------------------------
# HTTP text -> parts -> httr2 form (nothing is sent)
#   prepare_request_from_http_message(
#     "GET /testfile.txt HTTP/1.1\r\nHost: localhost\r\n\r\n", "127.0.0.1", 8080)
#   For HTTPS: ..., "httpbin.org", 443, scheme = "https")
# -----------------------------------------------------------------------------
prepare_request_from_http_message <- function(msg, host, port, scheme = "http",
                                              follow_redirects = FALSE) {
  parts <- split_http_message_into_parts(msg)
  prepare_request_from_parts(scheme, host, port,
                             method = parts$method, path = parts$path,
                             headers = parts$headers, body = parts$body,
                             follow_redirects = follow_redirects)
}


# -----------------------------------------------------------------------------
# httr2 sends the request and prints the conversation (like curl -v):
#   "->" lines = sent, "<-" lines = received. 4xx/5xx are kept, not R errors.
# -----------------------------------------------------------------------------
send_request_to_server <- function(req) {
  req <- req_error(req, is_error = never_error)
  req_perform(req, verbosity = 1)
}
