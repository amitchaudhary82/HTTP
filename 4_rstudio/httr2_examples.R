# =============================================================================
# httr2_examples.R - the HTTP experiments, written in R with httr2
# =============================================================================
#
# HOW TO USE
#   Open this repo folder in RStudio, then run one example at a time
#   (Cmd+Enter). Run section 0 first in every new R session.
#
#   Each section has the same number NNN as the raw file in ../1_telnet
#   or ../2_openssl. Compare:
#     raw file           what you typed by hand
#     req_dry_run(req)   what httr2 WOULD send (nothing is sent)
#     show(req)          sends it; "->" lines = sent, "<-" lines = received
#
#   httr2 uses curl inside, so everything curl does for you (Content-Length,
#   empty line, Host, encryption) httr2 does too.
# =============================================================================


# -----------------------------------------------------------------------------
# 0. Setup
# -----------------------------------------------------------------------------
for (pkg in c("httr2", "httpuv")) {        # httpuv is needed by req_dry_run()
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}
library(httr2)

local <- request("http://127.0.0.1:8080")   # Python mini server (start it first)
web   <- request("http://httpbin.org")      # plain HTTP, port 80 (like telnet)
bin   <- request("https://httpbin.org")     # HTTPS, port 443 (like openssl)

# Keep 4xx/5xx responses instead of stopping with an R error
never_error <- function(resp) FALSE

# Send a request and print the whole conversation (like curl -v)
show <- function(req) {
  req |>
    req_error(is_error = never_error) |>
    req_perform(verbosity = 1)
}


# =============================================================================
# Level 1 - The first request
# =============================================================================

# 001 local: GET the root
req <- local
req_dry_run(req)          # compare with 001: httr2 adds user-agent, accept-encoding
resp <- show(req)
resp_status(resp)         # 200


# =============================================================================
# Level 2 - Paths and redirects
# =============================================================================

# 002 local: folder without slash.
# httr2 FOLLOWS redirects automatically, so by default you'd only see the
# final 200. followlocation = FALSE switches that off to show the 301.
req <- local |>
  req_url_path_append("testFolder") |>
  req_options(followlocation = FALSE)
resp <- show(req)
resp_status(resp)                 # 301
resp_header(resp, "location")     # /testFolder/

# 003 local: folder with slash -> 200
resp <- show(local |> req_url_path_append("testFolder/"))

# 004 local: missing file -> 404
resp <- show(local |> req_url_path_append("missingFile.txt"))
resp_status(resp)


# =============================================================================
# Level 2b - Query strings (httr2 encodes for you)
# =============================================================================

# 029 two parameters
req <- bin |>
  req_url_path_append("get") |>
  req_url_query(name = "Amit", city = "Zurich")
req$url
resp <- show(req)
resp_body_json(resp)$args

# 030 - 032 special characters in values.
# Exercise: look at req$url - how did httr2 encode the space, & and + ?
# Compare with your raw files 030, 031, 032.
req <- bin |>
  req_url_path_append("get") |>
  req_url_query(city = "St Gallen", company = "Johnson&Johnson", r = "a+b")
req$url
resp_body_json(show(req))$args


# =============================================================================
# Level 3 / 3b - Methods
# =============================================================================

# 005 local: HEAD = headers only
resp <- show(local |> req_method("HEAD"))

# 006 local: invented method -> 501
resp <- show(local |> req_method("BADMETHOD"))
resp_status(resp)


# =============================================================================
# Level 4 - Files and the response
# =============================================================================

# 007 local: a file
resp <- show(local |> req_url_path_append("testfile.txt"))
resp_body_string(resp)

# 008 local: file in a sub-folder
resp <- show(local |> req_url_path_append("testFolder", "testSubfolderFile.txt"))

# 009 local: double slash - check in req_dry_run() what httr2 makes of it
req_dry_run(local |> req_url_path("//"))

# 033 local: response headers only
resp <- show(local |> req_url_path_append("testfile.txt") |> req_method("HEAD"))
resp_headers(resp)                # Server, Date, Content-Length, Last-Modified ...


# =============================================================================
# Level 5 - URL encoding in paths
# =============================================================================

# 010 / 011: raw spaces or quotes in the path are NOT possible: httr2 builds
#   a valid URL. That's the lesson - the tool protects you from the 400.

# 012 local: a file name with spaces.
# Exercise: does req_dry_run() show %20? (that's your file 012)
req <- local |> req_url_path_append("testfile with space.txt")
req_dry_run(req)
resp <- show(req)

# 013 local: % @ space and a-umlaut (\u00e4 = the letter a with two dots).
# Exercise: compare req_dry_run() with your file 013. If a character is not
# encoded, curl::curl_escape() shows what it should be:
curl::curl_escape("test_file%special@parm german_\u00e4.txt")
req <- local |> req_url_path_append("test_file%special@parm german_\u00e4.txt")
req_dry_run(req)


# =============================================================================
# Level 6 / 6b - Internet servers, Host, status codes
# =============================================================================

# 014 plain HTTP to httpbin
resp <- show(web)

# 015 JSON API endpoint
resp <- show(bin |> req_url_path_append("ip"))
resp_body_json(resp)

# 016 another server
resp <- show(request("https://example.org"))

# 034 / 035 missing Host: NOT possible with httr2 - it always sends Host.
#   (curl can remove it with -H "Host:", see ../3_curl)

# 036 - 038 status codes on demand, with a for loop
for (code in c("201", "204", "500")) {
  resp <- bin |>
    req_url_path_append("status", code) |>
    req_error(is_error = never_error) |>
    req_perform()
  cat(code, "->", resp_status(resp), resp_status_desc(resp), "\n")
}

# 039 redirect chain: switch off following to see the first 302
resp <- show(bin |> req_url_path_append("redirect", "2") |>
               req_options(followlocation = FALSE))
resp_header(resp, "location")


# =============================================================================
# Level 7 - Sending data (POST)
# =============================================================================

# 017 text body: httr2 calculates Content-Length (look at the -> lines)
req <- bin |>
  req_url_path_append("post") |>
  req_body_raw("hello world", type = "text/plain")
req_dry_run(req)
resp_body_json(show(req))$data

# 018 JSON body: req_body_json() sets Content-Type and turns the list into JSON
req <- bin |>
  req_url_path_append("post") |>
  req_body_json(list(name = "Amit", city = "Switzerland"))
req_dry_run(req)
resp_body_json(show(req))$json


# =============================================================================
# Level 8 - Wrong Content-Length / missing blank line
# =============================================================================

# 019 - 022: NOT possible with httr2. It always calculates Content-Length and
#   inserts the empty line. To replay these mistakes from RStudio, send the
#   raw files with send_http_file.R.


# =============================================================================
# Level 9 / 9b - Headers, tokens, connections
# =============================================================================

# 023 own headers
req <- bin |>
  req_url_path_append("get") |>
  req_headers(Accept = "application/json") |>
  req_user_agent("FileTest/1.0")
resp_body_json(show(req))$headers

# 040 without token -> 401
resp <- show(bin |> req_url_path_append("bearer"))
resp_status(resp)

# 041 with token -> 200. For real tokens use Sys.getenv("GITHUB_PAT"),
#     never a token written in the script.
req <- bin |>
  req_url_path_append("bearer") |>
  req_auth_bearer_token("test123")
resp_body_json(show(req))

# 042 two requests. httr2 manages connections itself; compare the "*" or
#     connection lines of both calls in the verbose output.
resp1 <- show(bin |> req_url_path_append("get") |> req_url_query(request = 1))
resp2 <- show(bin |> req_url_path_append("get") |> req_url_query(request = 2))


# =============================================================================
# Level 10 - Other methods
# =============================================================================

# 024 PUT
req <- bin |>
  req_url_path_append("put") |>
  req_method("PUT") |>
  req_body_json(list(name = "Amit", city = "Zurich"))
resp_body_json(show(req))$json

# 025 PATCH
req <- bin |>
  req_url_path_append("patch") |>
  req_method("PATCH") |>
  req_body_json(list(city = "Bern"))
resp_body_json(show(req))$json

# 026 DELETE
resp <- show(bin |> req_url_path_append("delete") |> req_method("DELETE"))

# 027 OPTIONS: which methods are allowed?
resp <- show(bin |> req_url_path_append("get") |> req_method("OPTIONS"))
resp_header(resp, "allow")

# 028 wrong method: GET on /post -> 405
resp <- show(bin |> req_url_path_append("post"))
resp_status(resp)


# =============================================================================
# Chapter 4 - HTTPS (043, 044)
# =============================================================================

# 043 same as 023: encryption is invisible, just "https://"
resp <- show(bin |> req_url_path_append("get") |> req_user_agent("FileTest/1.0"))
resp_body_json(resp)$url          # "https://httpbin.org/get"

# 044 GitHub API
req <- request("https://api.github.com") |>
  req_url_path_append("zen") |>
  req_user_agent("hello-http-learning (amitchaudhary82)")
resp_body_string(show(req))
