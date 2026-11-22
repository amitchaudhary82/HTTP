# =============================================================================
# httr2_examples.R - the HTTP experiments, written in R with httr2
# =============================================================================
#
# HOW TO USE
#   Open this repo folder in RStudio, then run one example at a time
#   (Cmd+Enter). Run section 0 first in every new R session.
#
#   Each section has the same experiment ID ECNN as the raw file in ../telnet
#   or ../openssl. Compare:
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
# Chapter 3 - Local server (telnet 127.0.0.1 8080)
# =============================================================================

# E301 local: GET the root
req <- local
req_dry_run(req)          # compare with E301: httr2 adds user-agent, accept-encoding
resp <- show(req)
resp_status(resp)         # 200

# E302 local: folder without slash.
# httr2 FOLLOWS redirects automatically, so by default you'd only see the
# final 200. followlocation = FALSE switches that off to show the 301.
req <- local |>
  req_url_path_append("testFolder") |>
  req_options(followlocation = FALSE)
resp <- show(req)
resp_status(resp)                 # 301
resp_header(resp, "location")     # /testFolder/

# E303 local: folder with slash -> 200
resp <- show(local |> req_url_path_append("testFolder/"))

# E304 local: missing file -> 404
resp <- show(local |> req_url_path_append("missingFile.txt"))
resp_status(resp)

# E305 local: HEAD = headers only
resp <- show(local |> req_method("HEAD"))

# E306 local: invented method -> 501
resp <- show(local |> req_method("BADMETHOD"))
resp_status(resp)

# E307 local: a file
resp <- show(local |> req_url_path_append("testfile.txt"))
resp_body_string(resp)

# E308 local: file in a sub-folder
resp <- show(local |> req_url_path_append("testFolder", "testSubfolderFile.txt"))

# E309 local: double slash - check in req_dry_run() what httr2 makes of it
req_dry_run(local |> req_url_path("//"))

# E310 local: response headers only
resp <- show(local |> req_url_path_append("testfile.txt") |> req_method("HEAD"))
resp_headers(resp)                # Server, Date, Content-Length, Last-Modified ...

# E311 / E312: raw spaces or quotes in the path are NOT possible: httr2 builds
#   a valid URL. That's the lesson - the tool protects you from the 400.

# E313 local: a file name with spaces.
# Exercise: does req_dry_run() show %20? (that's your file 313)
req <- local |> req_url_path_append("testfile with space.txt")
req_dry_run(req)
resp <- show(req)

# E314 local: % @ space and a-umlaut (\u00e4 = the letter a with two dots).
# Exercise: compare req_dry_run() with your file 314. If a character is not
# encoded, curl::curl_escape() shows what it should be:
curl::curl_escape("test_file%special@parm german_\u00e4.txt")
req <- local |> req_url_path_append("test_file%special@parm german_\u00e4.txt")
req_dry_run(req)


# =============================================================================
# Chapter 4 - Simple GET on the internet
# =============================================================================

# E401 plain HTTP to httpbin
resp <- show(web)

# E402 JSON API endpoint
resp <- show(bin |> req_url_path_append("ip"))
resp_body_json(resp)

# E403 another server
resp <- show(request("https://example.org"))

# E404 / E315 missing Host: NOT possible with httr2 - it always sends Host.
#   (curl can remove it with -H "Host:", see ../3_curl)

# E405 two parameters
req <- bin |>
  req_url_path_append("get") |>
  req_url_query(name = "Amit", city = "Zurich")
req$url
resp <- show(req)
resp_body_json(resp)$args

# E406 - E408 special characters in values.
# Exercise: look at req$url - how did httr2 encode the space, & and + ?
# Compare with your raw files 406, 407, 408.
req <- bin |>
  req_url_path_append("get") |>
  req_url_query(city = "St Gallen", company = "Johnson&Johnson", r = "a+b")
req$url
resp_body_json(show(req))$args

# E409 own headers
req <- bin |>
  req_url_path_append("get") |>
  req_headers(Accept = "application/json") |>
  req_user_agent("FileTest/1.0")
resp_body_json(show(req))$headers

# E410 - E412 status codes on demand, with a for loop
for (code in c("201", "204", "500")) {
  resp <- bin |>
    req_url_path_append("status", code) |>
    req_error(is_error = never_error) |>
    req_perform()
  cat(code, "->", resp_status(resp), resp_status_desc(resp), "\n")
}

# E413 redirect chain: switch off following to see the first 302
resp <- show(bin |> req_url_path_append("redirect", "2") |>
               req_options(followlocation = FALSE))
resp_header(resp, "location")

# E414 two requests. httr2 manages connections itself; compare the "*" or
#     connection lines of both calls in the verbose output.
resp1 <- show(bin |> req_url_path_append("get") |> req_url_query(request = 1))
resp2 <- show(bin |> req_url_path_append("get") |> req_url_query(request = 2))


# =============================================================================
# Chapter 5 - Sending data: POST and other methods
# =============================================================================

# E501 text body: httr2 calculates Content-Length (look at the -> lines)
req <- bin |>
  req_url_path_append("post") |>
  req_body_raw("hello world", type = "text/plain")
req_dry_run(req)
resp_body_json(show(req))$data

# E502 JSON body: req_body_json() sets Content-Type and turns the list into JSON
req <- bin |>
  req_url_path_append("post") |>
  req_body_json(list(name = "Amit", city = "Switzerland"))
req_dry_run(req)
resp_body_json(show(req))$json

# E503 - E506: NOT possible with httr2. It always calculates Content-Length and
#   inserts the empty line. To replay these mistakes from RStudio, send the
#   raw files with send_http_file.R.

# E507 PUT
req <- bin |>
  req_url_path_append("put") |>
  req_method("PUT") |>
  req_body_json(list(name = "Amit", city = "Zurich"))
resp_body_json(show(req))$json

# E508 PATCH
req <- bin |>
  req_url_path_append("patch") |>
  req_method("PATCH") |>
  req_body_json(list(city = "Bern"))
resp_body_json(show(req))$json

# E509 DELETE
resp <- show(bin |> req_url_path_append("delete") |> req_method("DELETE"))

# E510 OPTIONS: which methods are allowed?
resp <- show(bin |> req_url_path_append("get") |> req_method("OPTIONS"))
resp_header(resp, "allow")

# E511 wrong method: GET on /post -> 405
resp <- show(bin |> req_url_path_append("post"))
resp_status(resp)


# =============================================================================
# Chapter 6 - Authentication
# =============================================================================

# E601 without token -> 401
resp <- show(bin |> req_url_path_append("bearer"))
resp_status(resp)

# E602 with token -> 200. For real tokens use Sys.getenv("GITHUB_PAT"),
#     never a token written in the script.
req <- bin |>
  req_url_path_append("bearer") |>
  req_auth_bearer_token("test123")
resp_body_json(show(req))


# =============================================================================
# Chapter 7 - HTTPS
# =============================================================================

# E701 same as 409: encryption is invisible, just "https://"
resp <- show(bin |> req_url_path_append("get") |> req_user_agent("FileTest/1.0"))
resp_body_json(resp)$url          # "https://httpbin.org/get"

# E702 GitHub API
req <- request("https://api.github.com") |>
  req_url_path_append("zen") |>
  req_user_agent("hello-http-learning (amitchaudhary82)")
resp_body_string(show(req))
