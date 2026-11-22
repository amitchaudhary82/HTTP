# =============================================================================
# http_helpers.R - shared functions for the practice scripts (Part 1 and 2)
# =============================================================================
#
# Only definitions live here: sourcing this file sends nothing.
# The practice files start with:   source("rstudio/http_helpers.R")
#
#   read_message(file)      The Message file -> its parts (method, target,
#                           headers, body)
#   message_request(file)   The Message file -> an httr2 request
#   show(req)               send a request, print the whole conversation,
#                           keep 4xx/5xx responses (no R error)
#   send_http_file(file)    send The Message byte for byte over a raw socket:
#                           a raw Carrier inside R, like telnet or nc
#   expected_status(file)   the status the file name predicts (E304_..._404_...)
#
# Where the server is: taken from the file name suffix and the Host: line
#   _local     http://127.0.0.1:8080
#   _internet  http://<Host>        (httpbin.org if the file has no Host)
#   _https     https://<Host>
# =============================================================================

library(httr2)


# -----------------------------------------------------------------------------
# Keep 4xx/5xx responses instead of stopping with an R error
# -----------------------------------------------------------------------------
never_error <- function(resp) FALSE


# -----------------------------------------------------------------------------
# Send a request and print the conversation (like curl -v):
#   "->" lines = sent, "<-" lines = received
# -----------------------------------------------------------------------------
show <- function(req) {
  req |>
    req_error(is_error = never_error) |>
    req_perform(verbosity = 1)
}


# -----------------------------------------------------------------------------
# Base URL from the file name suffix (_local, _internet, _https) and Host
# -----------------------------------------------------------------------------
message_base_url <- function(file, host = "") {
  if (grepl("_local\\.http$", file)) {
    return("http://127.0.0.1:8080")
  }
  if (host == "") host <- "httpbin.org"
  if (grepl("_internet\\.http$", file)) return(paste0("http://", host))
  if (grepl("_https\\.http$", file))    return(paste0("https://", host))
  stop("Unknown suffix (expected _local, _internet, _https): ", file, call. = FALSE)
}


# -----------------------------------------------------------------------------
# The status the file name predicts: E304_get_missingFile_404_local.http -> "404"
# -----------------------------------------------------------------------------
expected_status <- function(file) {
  parts <- strsplit(sub("\\.http$", "", basename(file)), "_")[[1]]
  parts[length(parts) - 1]
}


# -----------------------------------------------------------------------------
# Read a Message file into its parts: method, target, headers, body
# -----------------------------------------------------------------------------
read_message <- function(file) {
  lines <- readLines(file, warn = FALSE)
  lines <- sub("\r$", "", lines)

  # request line: METHOD TARGET VERSION (TARGET may contain spaces, see E311)
  words  <- strsplit(lines[1], " ")[[1]]
  method <- words[1]
  target <- paste(words[2:(length(words) - 1)], collapse = " ")

  # headers: from line 2 until the first empty line
  header_names  <- character(0)
  header_values <- character(0)
  body_start <- length(lines) + 1
  for (i in seq_along(lines)[-1]) {
    if (lines[i] == "") {
      body_start <- i + 1
      break
    }
    header_names  <- c(header_names,  trimws(sub(":.*$", "", lines[i])))
    header_values <- c(header_values, trimws(sub("^[^:]*:", "", lines[i])))
  }

  # body: everything after the empty line
  body <- ""
  if (body_start <= length(lines)) {
    body <- paste(lines[body_start:length(lines)], collapse = "\n")
  }
  # a second request after the empty line (E414) is not a body
  if (grepl("^[A-Z]+ [^ ]+ HTTP/", body)) {
    message("Note: ", basename(file), " holds more than one request; only the first is used.")
    body <- ""
  }

  list(method = method, target = target,
       header_names = header_names, header_values = header_values,
       body = body)
}


# -----------------------------------------------------------------------------
# Build the httr2 request for a Message file
#   Host and Content-Length are NOT copied: httr2 (curl) sets them itself.
# -----------------------------------------------------------------------------
message_request <- function(file) {
  msg  <- read_message(file)
  host <- ""
  hit  <- which(tolower(msg$header_names) == "host")
  if (length(hit) > 0) host <- msg$header_values[hit[1]]

  req <- request(paste0(message_base_url(file, host), msg$target)) |>
    req_method(msg$method)

  content_type <- "text/plain"
  for (i in seq_along(msg$header_names)) {
    name  <- msg$header_names[i]
    value <- msg$header_values[i]
    if (tolower(name) %in% c("host", "content-length")) next   # httr2 sets these
    if (tolower(name) == "content-type") {
      content_type <- value                                    # used with the body
      next
    }
    req <- req_headers(req, !!name := value)
  }

  if (msg$body != "") {
    req <- req_body_raw(req, msg$body, type = content_type)
  }
  req
}


# -----------------------------------------------------------------------------
# Send a Message file exactly as written, over a raw TCP connection
#   LF line endings become CR LF; a final CR LF is added if the request does
#   not end with an empty line. Plain HTTP only (_local, _internet).
#   Files without "Connection: close" (E502, E504) wait up to `timeout` seconds.
# -----------------------------------------------------------------------------
send_http_file <- function(file, timeout = 10) {
  if (!file.exists(file)) {
    stop("Message file does not exist: ", file, call. = FALSE)
  }
  if (grepl("_https\\.http$", file)) {
    stop("HTTPS needs encryption; use carriers/openssl.txt or ncat --ssl.", call. = FALSE)
  }

  lines <- sub("\r$", "", readLines(file, warn = FALSE))
  host_line <- grep("^[Hh]ost:", lines, value = TRUE)
  if (grepl("_local\\.http$", file)) {
    host <- "127.0.0.1"
    port <- 8080
  } else {
    host <- if (length(host_line) > 0) trimws(sub("^[Hh]ost:", "", host_line[1])) else "httpbin.org"
    port <- 80
  }

  request_text <- readChar(file, file.size(file), useBytes = TRUE)
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
