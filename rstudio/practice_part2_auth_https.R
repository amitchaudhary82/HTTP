# =============================================================================
# practice_part2_auth_https.R - Part 2 (chapters 7 - 8) with httr2
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
# Chapter 7 - Authentication (_internet)
# =============================================================================

# E701  GET httpbin bearerMissing, expect 401 (internet)
req <-
  read_http_message_from_file("messages/E701_get_httpbin_bearerMissing_401_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

# E702  GET httpbin bearerToken, expect 200 (internet)
#   The token is copied from the file into the Authorization header.
req <-
  read_http_message_from_file("messages/E702_get_httpbin_bearerToken_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)


# =============================================================================
# Chapter 8 - HTTPS (_https)
# =============================================================================

# E801  GET httpbin, expect 200 (https)
#   https:// - httr2 builds the encrypted tunnel, nothing else changes.
req <-
  read_http_message_from_file("messages/E801_get_httpbin_200_https.http") %>%
    prepare_request_from_http_message("httpbin.org", 443, scheme = "https")

req_dry_run(req)
resp <- send_request_to_server(req)

# E802  GET githubApi zen, expect 200 (https)
#   The User-Agent from the file is sent; GitHub requires one.
req <-
  read_http_message_from_file("messages/E802_get_githubApi_zen_200_https.http") %>%
    prepare_request_from_http_message("api.github.com", 443, scheme = "https")

req_dry_run(req)
resp <- send_request_to_server(req)


# =============================================================================
# Beyond the Messages: a real API with your own token
# =============================================================================
# Never write a token into a file. Store it once in ~/.Renviron:
#   usethis::edit_r_environ()     add the line  GITHUB_PAT=ghp_...   then restart R
# Then use it from the environment:

req <-
  request("https://api.github.com/user") %>%
    req_auth_bearer_token(Sys.getenv("GITHUB_PAT")) %>%
    req_user_agent("hello-http-learning (amitchaudhary82)")

req_dry_run(req)
resp <- send_request_to_server(req)
resp_body_json(resp)$login        # your GitHub user name
