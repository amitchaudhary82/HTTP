# HTTP from the ground up - learning by example

This repository teaches HTTP, the language browsers and apps use to talk to
web servers, by **typing raw requests by hand** and watching what the server
answers. No browser, no library: just text over a connection.

Each file is one small experiment. They are numbered in the order they were
created; the chapters below arrange them into **levels** that build on each
other. Work through the levels in order.

| Chapter | What you learn | Tool | Folder |
|---|---|---|---|
| 1 - 2 | What HTTP is, how to set up | - | - |
| 3 | 42 experiments with raw requests | telnet | `1_telnet/` |
| 4 | Bridge: the same requests, encrypted (HTTPS) | openssl | `2_openssl/` |
| 5 | The same examples three ways | curl, RStudio (httr2) | `3_curl/`, `4_rstudio/` |

The folders go from the **lowest level** (you type every byte) to the
**highest** (R code). The number `NNN` connects them: example 017 is the file
`1_telnet/017_...http`, the section `# 017` in `3_curl/curl_examples.sh`
and the section `# 017` in `4_rstudio/httr2_examples.R`.

```
HTTP/
  README.md                                   this guide
  000_Syntax_NNN_method_scenario_status.txt   file naming rule
  build_readme.sh                             refreshes the snippets in this README
  1_telnet/        42 raw requests + start commands        (chapter 3)
  2_openssl/       2 raw HTTPS requests + connect commands (chapter 4)
  3_curl/          curl_examples.sh                        (chapter 5)
  4_rstudio/       httr2_examples.R, send_http_file.R      (chapter 5)
  http_mini_server_root/   files served by the local server
```

---

<br>
<br>
<br>


## 1. The big idea in 60 seconds

When you open a web page, your computer sends the server a short **text
message** (the *request*) and the server sends a text message back (the
*response*). That's HTTP.

A request looks like this:

```
GET /testfile.txt HTTP/1.1      <- request line: METHOD  PATH  VERSION
Host: localhost                 <- headers: extra information, one per line
                                <- empty line: "my headers are finished"
(optional body)                 <- data you send, only for e.g. POST
```

A response looks like this:

```
HTTP/1.0 200 OK                 <- status line: VERSION  CODE  TEXT
Content-Type: text/plain        <- headers about the answer
Content-Length: 12
                                <- empty line
Hello there!                    <- body: the actual content
```

The rest of this repo is about learning each of those parts by changing one
thing at a time.

### Status codes: the server's short answer

| Family | Meaning | Examples in this repo |
|---|---|---|
| 2xx | Success | 200 OK, 201 Created, 204 No Content |
| 3xx | Go somewhere else | 301 Moved Permanently, 302 Found |
| 4xx | **Your** request has a problem | 400 Bad Request, 401 Unauthorized, 404 Not Found, 405 Method Not Allowed |
| 5xx | The **server** can't do it | 500 Internal Server Error, 501 Not Implemented |

---

<br>
<br>
<br>


## 2. Setup

### The servers we talk to

| Server | What | File suffix | Folder |
|---|---|---|---|
| Local mini server | Python's built-in web server, on your own Mac | `_telnet_local` | `1_telnet/` |
| httpbin.org / example.org | Real test servers on the internet, plain HTTP | `_telnet_internet` | `1_telnet/` |
| httpbin.org / api.github.com | The same, encrypted (HTTPS) - chapter 4 | `_openssl` | `2_openssl/` |

The suffix names the **tool and the server**, so a file still tells you how
to send it even when it's copied somewhere else.

**httpbin.org** is a test server made for learning: it replies with a
description of the request it received, so you can see exactly what you sent.

### Start the local server

Open a Terminal, go into the server folder and start it

```bash
cd http_mini_server_root
python3 -m http.server 8080 --bind 127.0.0.1
```




Additional Info:
- `8080` is the **port**: like a door number on your computer
- `127.0.0.1` means "this computer only", so nobody else can connect
- leave this Terminal open; it shows every request it receives


### Connect with telnet

Open a **second** Terminal and connect to the server

```bash
telnet 127.0.0.1 8080       # local server    (files ending _telnet_local)

```
All requests are stored as files in `1_telnet/` and `2_openssl/`.

Then paste the request shown with each experiment. The response appears below.

Tips:
- The **empty line at the end is part of the request**. Without it the server
  keeps waiting for more headers.
- The local server answers once and closes the connection. Connect again for
  the next file.
- To quit a hanging telnet: press `Ctrl + ]`, then type `quit`.
- The files contain **only** the request: no comments, so copy-paste is
  always safe. All explanations live in this README.


<br>
<br>
<br>


## 3. The experiments (telnet)

### Level 1 - The first request

#### 001_get_root_200_telnet_local

<!-- include: 1_telnet/001_get_root_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET / HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET / HTTP/1.1
Host: localhost

HTTP/1.0 200 OK
Server: SimpleHTTP Python/3.15.2
Date: Sat, 21 Nov 2026 21:18:56 GMT
Content-type: text/html; charset=utf-8
Content-Length: 617

<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<style type="text/css">
:root {
color-scheme: light dark;
}
</style>
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="Info_Encoding_Characters.txt">Info_Encoding_Characters.txt</a></li>
<li><a href="test_file%25special%40parm%20german_a%CC%88.txt">test_file%special@parm german_ä.txt</a></li>
<li><a href="testfile%20with%20space.txt">testfile with space.txt</a></li>
<li><a href="testfile.txt">testfile.txt</a></li>
<li><a href="testFolder/">testFolder/</a></li>
</ul>
<hr>
</body>
</html>
Connection closed by foreign host.
```

- **Objective:** send the smallest valid request and get an answer.
- **New concepts:** request line (`GET / HTTP/1.1`), the `Host` header
  (required in HTTP/1.1, it names the server you mean), the empty line.
- **What happens:** `200 OK` and an HTML page listing the files in
  `http_mini_server_root`. `/` means "the root", the top folder of the server.
- **Notice:** the server answers `HTTP/1.0` even though you asked in 1.1. The
  Python mini server only speaks 1.0, and that's allowed.
- **Read the response:** `Content-Length: 617` = size of the HTML body in
  bytes. `Connection closed by foreign host` = the server hung up after
  answering (HTTP/1.0 does that every time).

<img width="3536" height="1378" alt="CleanShot 2026-11-21 at 21 23 43@2x" src="https://github.com/user-attachments/assets/1be62d6f-e9e0-4b0b-878b-8432cb987896" />


This can also be simulated in browser via using
```bash
http://localhost:8080
```

<img width="3182" height="632" alt="CleanShot 2026-11-21 at 21 28 18@2x" src="https://github.com/user-attachments/assets/8ddde72b-0799-4f47-b0c8-2fcb97a152b9" />


---

### Level 2 - Paths: asking for different things

#### 002_get_foldernoSlash_301_telnet_local

<!-- include: 1_telnet/002_get_foldernoSlash_301_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /testFolder HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /testFolder HTTP/1.1
Host: localhost

HTTP/1.0 301 Moved Permanently
Server: SimpleHTTP Python/3.15.2
Date: Sat, 21 Nov 2026 21:20:00 GMT
Location: /testFolder/
Content-Length: 0

Connection closed by foreign host.
```

- **Objective:** ask for a folder **without** the trailing slash: `/testFolder`.
- **What happens:** `301 Moved Permanently` with a header
  `Location: /testFolder/`. The server says "the right address has a slash,
  ask there instead". A browser follows this automatically; telnet doesn't.
- **New concept:** redirects (3xx) and the `Location` header.
- **Read the response:** `Content-Length: 0` - no body at all, the
  `Location` header is the whole message.

<img width="3546" height="1352" alt="CleanShot 2026-11-21 at 21 46 50@2x" src="https://github.com/user-attachments/assets/31bf410c-5a3d-4ea6-8413-6183b66fe51d" />


#### 003_get_folder_slash_200_telnet_local

<!-- include: 1_telnet/003_get_folder_slash_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /testFolder/ HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /testFolder/ HTTP/1.1
Host: localhost

HTTP/1.0 200 OK
Server: SimpleHTTP Python/3.15.2
Date: Sat, 21 Nov 2026 21:20:40 GMT
Content-type: text/html; charset=utf-8
Content-Length: 345

<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<style type="text/css">
:root {
color-scheme: light dark;
}
</style>
<title>Directory listing for /testFolder/</title>
</head>
<body>
<h1>Directory listing for /testFolder/</h1>
<hr>
<ul>
<li><a href="testSubfolderFile.txt">testSubfolderFile.txt</a></li>
</ul>
<hr>
</body>
</html>
Connection closed by foreign host.
```

- **Objective:** follow the redirect by hand: ask for `/testFolder/`.
- **What happens:** `200 OK` and a listing of the folder's content.
- **Lesson:** for a folder, `/testFolder` and `/testFolder/` are different
  requests.


This can also be simulated in browser via using
```bash
localhost:8080/testFolder/
```
<img width="3914" height="634" alt="CleanShot 2026-11-21 at 21 43 05@2x" src="https://github.com/user-attachments/assets/7ca2fdcd-85e2-4c36-92ac-e8028f676e73" />




#### 004_get_missingFile_404_telnet_local

<!-- include: 1_telnet/004_get_missingFile_404_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /missingFile.txt HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /missingFile.txt HTTP/1.1
Host: localhost        

HTTP/1.0 404 File not found
Server: SimpleHTTP Python/3.15.2
Date: Sat, 21 Nov 2026 21:21:33 GMT
Connection: close
Content-Type: text/html;charset=utf-8
Content-Length: 460

<!DOCTYPE HTML>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <style type="text/css">
            :root {
                color-scheme: light dark;
            }
        </style>
        <title>Error response</title>
    </head>
    <body>
        <h1>Error response</h1>
        <p>Error code: 404</p>
        <p>Message: File not found.</p>
        <p>Error code explanation: 404 - Nothing matches the given URI.</p>
    </body>
</html>
Connection closed by foreign host.
```

- **Objective:** ask for a file that does not exist.
- **What happens:** `404 File not found`. The connection worked, the request
  was valid, there is just nothing at that path.
- **Lesson:** 4xx means "your request asked for something wrong", not "the
  server is broken".
- **Read the response:** even an error has a body - an HTML error page
  (`Content-Length: 460`).

---

### Level 2b - Query strings: asking with options

The path says **what** you want. The **query**, everything after `?`, says
**how** you want it: `key=value` pairs joined by `&`. These go to httpbin
(`telnet httpbin.org 80`), whose `/get` replies with the pairs it understood
under `"args"`.

#### 029_get_httpbin_queryString_200_telnet_internet

<!-- include: 1_telnet/029_get_httpbin_queryString_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get?name=Amit&city=Zurich HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet httpbin.org 80
Trying 54.172.45.38...
Connected to httpbin.org.
Escape character is '^]'.
GET /get?name=Amit&city=Zurich HTTP/1.1
Host: httpbin.org
Connection: close

HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
access-control-expose-headers: Retry-After, RateLimit, RateLimit-Policy, WWW-Authenticate
content-length: 211
content-type: application/json
x-content-type-options: nosniff
date: Sat, 21 Nov 2026 21:22:39 GMT
connection: close

{
  "args": {
    "city": "Zurich",
    "name": "Amit"
  },
  "headers": {
    "Host": "httpbin.org"
  },
  "method": "GET",
  "origin": "xx.xxx.xxx.x",
  "url": "http://httpbin.org/get?name=Amit&city=Zurich"
}
Connection closed by foreign host.
```

- **Objective:** send two query parameters.
- **What happens:** `200 OK`, JSON with `"args": {"city": "Zurich", "name": "Amit"}`.
- **Lesson:** `?` starts the query, `=` joins key and value, `&` separates pairs.
- **Read the response:** `"headers"` lists only `Host` - telnet sends nothing
  you didn't type. (curl and httr2 add more, see chapter 5.)

#### 030_get_httpbin_querySpaceEncoded_200_telnet_internet

<!-- include: 1_telnet/030_get_httpbin_querySpaceEncoded_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get?city=St%20Gallen HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet httpbin.org 80
Trying 54.172.45.38...
Connected to httpbin.org.
Escape character is '^]'.
GET /get?city=St%20Gallen HTTP/1.1
Host: httpbin.org
Connection: close

HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
access-control-expose-headers: Retry-After, RateLimit, RateLimit-Policy, WWW-Authenticate
content-length: 189
content-type: application/json
x-content-type-options: nosniff
date: Sat, 21 Nov 2026 21:24:11 GMT
connection: close

{
  "args": {
    "city": "St Gallen"
  },
  "headers": {
    "Host": "httpbin.org"
  },
  "method": "GET",
  "origin": "xx.xxx.xxx.x",
  "url": "http://httpbin.org/get?city=St%20Gallen"
}
Connection closed by foreign host.
```

- **Objective:** a value with a space: `city=St%20Gallen`.
- **What happens:** `"args": {"city": "St Gallen"}`, while `"url"` still
  shows `St%20Gallen`: the URL travels encoded, the value arrives decoded.
- **Lesson:** the same `%20` rule as in paths (Level 5) applies in the query.

#### 031_get_httpbin_queryAmpersandEncoded_200_telnet_internet

<!-- include: 1_telnet/031_get_httpbin_queryAmpersandEncoded_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get?company=Johnson%26Johnson&country=US HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet httpbin.org 80
Trying 3.221.253.123...
Connected to httpbin.org.
Escape character is '^]'.
GET /get?company=Johnson%26Johnson&country=US HTTP/1.1
Host: httpbin.org
Connection: close

HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
access-control-expose-headers: Retry-After, RateLimit, RateLimit-Policy, WWW-Authenticate
content-length: 239
content-type: application/json
x-content-type-options: nosniff
date: Sat, 21 Nov 2026 21:25:44 GMT
connection: close

{
  "args": {
    "company": "Johnson&Johnson",
    "country": "US"
  },
  "headers": {
    "Host": "httpbin.org"
  },
  "method": "GET",
  "origin": "xx.xxx.xxx.x",
  "url": "http://httpbin.org/get?company=Johnson%26Johnson&country=US"
}
Connection closed by foreign host.
```

- **Objective:** a value that contains `&`: `company=Johnson%26Johnson`.
- **What happens:** two values: `"company": "Johnson&Johnson"` and
  `"country": "US"` - the encoded `%26` stayed inside the value.
- **Lesson:** a raw `&` would start a new parameter, so inside a value it must
  be encoded as `%26`. Try it unencoded and see the value split in two.

#### 032_get_httpbin_queryPlusSign_200_telnet_internet

<!-- include: 1_telnet/032_get_httpbin_queryPlusSign_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get?q=a+b&r=a%2Bb HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
MacBook-Pro-2:HTTP amitchaudhary$ telnet httpbin.org 80
Trying 3.221.253.123...
Connected to httpbin.org.
Escape character is '^]'.
GET /get?q=a+b&r=a%2Bb HTTP/1.1
Host: httpbin.org
Connection: close

HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
access-control-expose-headers: Retry-After, RateLimit, RateLimit-Policy, WWW-Authenticate
content-length: 193
content-type: application/json
x-content-type-options: nosniff
date: Sat, 21 Nov 2026 21:26:33 GMT
connection: close

{
  "args": {
    "q": "a b",
    "r": "a+b"
  },
  "headers": {
    "Host": "httpbin.org"
  },
  "method": "GET",
  "origin": "xx.xxx.xxx.x",
  "url": "http://httpbin.org/get?q=a+b&r=a%2Bb"
}
Connection closed by foreign host.
```

- **Objective:** compare `q=a+b` with `r=a%2Bb`.
- **What happens:** `"q": "a b"` but `"r": "a+b"`.
- **Lesson:** in a **query**, `+` traditionally means a space. A real plus
  sign must be sent as `%2B`. (In a *path*, `+` is just a plus.)

---

### Level 3 - Methods: what you want to do

#### 005_head_root_200_telnet_local

<!-- include: 1_telnet/005_head_root_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
HEAD / HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** use the `HEAD` method instead of `GET`.
- **What happens:** `200 OK` with the same headers as 001, but **no body**.
- **Lesson:** the method says *what to do*. `HEAD` = "only tell me about it"
  (size, type, date), useful to check something without downloading it.

#### 006_get_badMethod_501_telnet_local

<!-- include: 1_telnet/006_get_badMethod_501_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
BADMETHOD / HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** invent a method the server doesn't know: `BADMETHOD`.
- **What happens:** `501 Unsupported method ('BADMETHOD')`.
- **Lesson:** a method is just a word; the server decides which ones it
  supports. 5xx because the *server* can't do it (it isn't "your path is
  wrong" like 404).

---

### Level 3b - All request methods at a glance

The method is the first word of the request line. It tells the server
**what you want to do**. These are the ones you will meet most:

| Method | In plain words | Used for | Has a body? | Tried in |
|---|---|---|---|---|
| GET | "Give me information" | Read data only. Should NOT change anything. The most common method. | No | most files |
| HEAD | "Give me info, but no body" | Like GET, but returns only status + headers. Check if something exists, its type, its date. Mostly used by systems. | No | 005, 033 |
| POST | "I am sending you data" | Create something / send data to process. Usually changes something on the server. | Yes (often JSON) | 017 - 022 |
| PUT | "Replace it with this" | Replace a WHOLE resource: delete the old version, store the new one. | Yes | 024 |
| PATCH | "Change only this part" | Update PART of a resource. | Yes | 025 |
| DELETE | "Remove it" | Delete a resource. | Usually no | 026 |
| OPTIONS | "What are my choices?" | Ask which methods are allowed at this path. | No | 027 |

**PUT vs PATCH** - think of a profile with name and city:
- PUT `{"name":"Amit","city":"Zurich"}` = "this is the complete new profile"
- PATCH `{"city":"Bern"}` = "only change the city, keep the rest"

In practice teams sometimes use these loosely - don't worry too much.

**Safe to repeat? (the word is *idempotent*)**
Doing GET, HEAD, PUT or DELETE twice gives the same result as doing it once.
POST is different: sending it twice usually creates two things (two orders,
two comments). That's the real difference between POST and PUT.

---

### Level 4 - Files, folders and the response

#### 007_get_file_200_telnet_local

<!-- include: 1_telnet/007_get_file_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /testfile.txt HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** download an actual file: `/testfile.txt`.
- **What happens:** `200 OK`, `Content-Type: text/plain`, a `Content-Length`
  header with the file size in bytes, then the file's text as the body.
- **New concepts:** `Content-Type` (what kind of data) and `Content-Length`
  (how many bytes follow). Remember `Content-Length`: it's the star of
  Level 8.

#### 008_get_subFolderFile_200_telnet_local

<!-- include: 1_telnet/008_get_subFolderFile_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /testFolder/testSubfolderFile.txt HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** reach a file inside a sub-folder:
  `/testFolder/testSubfolderFile.txt`.
- **What happens:** `200 OK` with the file content.
- **Lesson:** the path works like folders on disk, separated by `/`.

#### 009_get_doubleSlash_200_telnet_local

<!-- include: 1_telnet/009_get_doubleSlash_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET // HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** see how the server handles a strange path: `//`.
- **What happens:** `200 OK`, the root listing again: the server tidies the
  path up.
- **Lesson:** servers *normalise* paths. Not every server does it the same
  way, which is why odd paths are a classic thing to test.

#### 033_head_file_headers_200_telnet_local

<!-- include: 1_telnet/033_head_file_headers_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
HEAD /testfile.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** study the response headers on their own, without a body in
  the way.
- **What happens:** `200 OK` and only headers. Read each one:

  | Header | Tells you |
  |---|---|
  | `Server` | which software answered (here: SimpleHTTP / Python) |
  | `Date` | when the server answered |
  | `Content-type` | what kind of file it is |
  | `Content-Length` | its size in bytes |
  | `Last-Modified` | when the file last changed |

- **Lesson:** compare with 007 - identical headers, only the body is
  missing. This is how programs check "has this file changed?" cheaply.

---

### Level 5 - Special characters and URL encoding

The test folder contains files with awkward names on purpose:
`testfile with space.txt` and `test_file%special@parm german_ä.txt`.
Background notes: `http_mini_server_root/Info_Encoding_Characters.txt`.

#### 010_get_fileNameSpaces_400_telnet_local

<!-- include: 1_telnet/010_get_fileNameSpaces_400_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /testfile with space.txt HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** ask for a file whose name contains spaces, typed as-is.
- **What happens:** `400 Bad Request`. The request line must be exactly
  *three* parts separated by spaces (method, path, version). The spaces in
  the name split it into five parts, and the server can't read it.
- **Lesson:** some characters can't appear raw in a path.

#### 011_get_fileNameQuotes_400_telnet_local

<!-- include: 1_telnet/011_get_fileNameQuotes_400_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /"testfile with space.txt" HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** try to "protect" the spaces with quotes.
- **What happens:** still `400 Bad Request`.
- **Lesson:** quotes mean nothing in HTTP; they are just more characters.
  There's a proper mechanism instead (next file).

#### 012_get_fileNameUrlEncoding_200_telnet_local

<!-- include: 1_telnet/012_get_fileNameUrlEncoding_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /testfile%20with%20space.txt HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** write each space as `%20`.
- **What happens:** `200 OK`, the file is found.
- **New concept: URL encoding (percent-encoding).** A forbidden character is
  replaced by `%` plus its code in hexadecimal. Space is code 32 = hex 20, so
  space becomes `%20`. The server decodes it back.

#### 013_get_fileNameSpecialCharUrlEncoding_200_telnet_local

<!-- include: 1_telnet/013_get_fileNameSpecialCharUrlEncoding_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET /test_file%25special%40parm%20german_%C3%A4.txt HTTP/1.1
Host: localhost
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** encode several special characters at once.
- **What happens:** `200 OK` for the file `test_file%special@parm german_ä.txt`.
- **Decoding table:**

  | Encoded | Character | Why it needs encoding |
  |---|---|---|
  | `%25` | `%` | `%` itself starts an encoding, so it must be encoded too |
  | `%40` | `@` | `@` has a special meaning in URLs (user@host) |
  | `%20` | space | splits the request line (see 010) |
  | `%C3%A4` | `ä` | non-English letters are sent as UTF-8 bytes: `ä` is **two** bytes, C3 and A4 |

- **Lesson:** libraries (browsers, curl, R's httr2) do this encoding for
  you. Here you did it by hand, so you know what's happening underneath.
- **Notice:** in the 001 listing this file's link is `german_a%CC%88`:
  macOS stores `ä` as `a` + `¨` (two characters). Both forms find the file.

---

### Level 6 - Real servers on the internet

From here on: `telnet httpbin.org 80` (or `telnet example.org 80` for 016).

#### 014_get_httpbin_get_200_telnet_internet

<!-- include: 1_telnet/014_get_httpbin_get_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET / HTTP/1.1
Host: httpbin.org
Connection: close
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** the same kind of request as 001, but to a real server.
- **New header:** `Connection: close`, asking the server to hang up after
  answering. Without it, HTTP/1.1 keeps the connection open for more
  requests, and telnet just sits there.
- **What happens:** `HTTP/1.1 200 OK` and httpbin's HTML home page.
- **Notice:** this server answers in HTTP/1.1, and sends more headers than
  the mini server (date, server type, security headers ...).

#### 015_get_httpbin_ip_200_telnet_internet

<!-- include: 1_telnet/015_get_httpbin_ip_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /ip HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** ask for `/ip`, an *API endpoint* rather than a web page.
- **What happens:** `200 OK` with `Content-Type: application/json` and a
  body like `{"origin": "<your public IP address>"}`.
- **New concept:** JSON, the data format most APIs answer in: made for
  programs, not people.

#### 016_get_example_200_telnet_internet

<!-- include: 1_telnet/016_get_example_200_telnet_internet.http -->
**Connect**

```bash
telnet example.org 80
```

**Request**

```http
GET / HTTP/1.1
Host: example.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** a different public server: `example.org`.
- **What happens:** `200 OK` with a small HTML page ("Example Domain").
- **Lesson:** the `Host` header must match the server you connected to.
  HTTP works the same everywhere.

#### 034_get_httpbin_missingHost_400_telnet_internet

<!-- include: 1_telnet/034_get_httpbin_missingHost_400_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get HTTP/1.1
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** leave out the `Host` header on a real server.
- **What happens:** `400 Bad Request`.
- **Lesson:** in HTTP/1.1, `Host` is **required**. One machine can host many
  websites, and `Host` says which one you mean.

#### 035_get_root_missingHost_200_telnet_local

<!-- include: 1_telnet/035_get_root_missingHost_200_telnet_local.http -->
**Connect**

```bash
telnet 127.0.0.1 8080
```

**Request**

```http
GET / HTTP/1.1

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** the same mistake on the local mini server.
- **What happens:** `200 OK` - it answers anyway.
- **Lesson:** not every server enforces every rule. A request that "works"
  on one server can fail on another, so test against the real target.

---

### Level 6b - More status codes

httpbin's `/status/NNN` answers with whatever code you ask for: a safe way to
see codes you rarely meet on purpose.

#### 036_get_httpbin_status201_201_telnet_internet

<!-- include: 1_telnet/036_get_httpbin_status201_201_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /status/201 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **What happens:** `201 CREATED`.
- **Lesson:** 201 is the typical answer to a successful POST that created
  something new (an issue, an order).

#### 037_get_httpbin_status204_204_telnet_internet

<!-- include: 1_telnet/037_get_httpbin_status204_204_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /status/204 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **What happens:** `204 NO CONTENT` and no body at all.
- **Lesson:** success doesn't always come with data. A DELETE often answers
  204: "done, nothing more to say".

#### 038_get_httpbin_status500_500_telnet_internet

<!-- include: 1_telnet/038_get_httpbin_status500_500_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /status/500 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **What happens:** `500 INTERNAL SERVER ERROR`.
- **Lesson:** the classic "the server broke" code. Your request was fine;
  retrying later may help.

#### 039_get_httpbin_redirectChain_302_telnet_internet

<!-- include: 1_telnet/039_get_httpbin_redirectChain_302_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /redirect/2 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** follow a chain of redirects by hand.
- **What happens:** `302 FOUND` with a `Location` header pointing to the next
  address. Send a new request to that address: another `302`. The next one
  finally gives `200`.
- **Lesson:** 301 = moved forever, 302 = "look over there for now". Browsers
  and libraries follow these silently; here you see each hop.

---

### Level 7 - Sending data (POST)

`GET` only *asks*. `POST` *sends data* to the server, in the **body** after
the empty line. httpbin's `/post` endpoint echoes back what it received.

#### 017_post_httpbinText_200_telnet_internet

<!-- include: 1_telnet/017_post_httpbinText_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 11
Connection: close

hello world
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** send the text `hello world`.
- **New concepts:**
  - `Content-Type: text/plain` tells the server what kind of data the body is
  - `Content-Length: 11` tells it how many bytes to read: `hello world` is
    exactly 11 characters (the space counts)
- **What happens:** `200 OK`, and the JSON reply contains
  `"data": "hello world"`: proof the server got it.

#### 018_post_httpbinJson_200_telnet_internet

<!-- include: 1_telnet/018_post_httpbinJson_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: application/json
Content-Length: 36

{"name":"Amit","city":"Switzerland"}
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** send JSON data: `{"name":"Amit","city":"Switzerland"}`.
- **What happens:** `200 OK`. Because `Content-Type` says
  `application/json`, httpbin also *understands* it, and shows it parsed
  under `"json": {"city": "Switzerland", "name": "Amit"}`.
- **Notice:** `Content-Length: 36` matches the JSON exactly (count it!).
- **Intentionally no `Connection: close`:** telnet stays connected after the
  answer, until the server times out or you quit. That's HTTP/1.1
  *keep-alive* - see 042 for what it's good for.

---

### Level 8 - Experiments: what if Content-Length is wrong?

The server reads the body **only by counting bytes**. These files break that
count on purpose to see what happens.

#### 019_post_httpbinText_shortLength_200_telnet_internet

<!-- include: 1_telnet/019_post_httpbinText_shortLength_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 8
Connection: close

hello world
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** say `Content-Length: 8`, but send 11 bytes.
- **What happens:** `200 OK`, but `"data": "hello wo"`. The server read
  exactly 8 bytes and ignored the rest (`rld`).
- **Lesson:** the server trusts `Content-Length`, not what you actually sent.

#### 020_post_httpbinText_longLength_timeout_telnet_internet

<!-- include: 1_telnet/020_post_httpbinText_longLength_timeout_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 25
Connection: close

hello world
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** say `Content-Length: 25`, but send only 11 bytes.
- **What happens:** **nothing, for a while.** The server waits for the 14
  missing bytes. After a timeout it gives up or closes the connection.
- **Lesson:** a too-large length makes the server hang. A classic cause of
  "my request is stuck".

#### 021_post_httpbinText_missingLengthNoData_telnet_internet

<!-- include: 1_telnet/021_post_httpbinText_missingLengthNoData_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Connection: close

hello world
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** leave `Content-Length` out completely.
- **What happens:** the server assumes the body is **empty**: the reply shows
  `"data": ""`. Your `hello world` is not treated as body (and may even be
  read as the start of a new, invalid request).
- **Lesson:** with a body, `Content-Length` is effectively required (or
  another way of marking the end, which libraries handle for you).

#### 022_post_httpbinText_missingBlankLine_400_telnet_internet

<!-- include: 1_telnet/022_post_httpbinText_missingBlankLine_400_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Connection: close
Content-Length: 11
hello world
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** forget the empty line between headers and body.
- **What happens:** `400 Bad Request`. Without the empty line the server
  thinks `hello world` is another header, and a header must look like
  `Name: value`.
- **Lesson:** the empty line is the only thing that separates headers from
  the body. It's small but essential.

---

### Level 9 - Headers: telling the server more

#### 023_get_httpbin_multipleHeaders_200_telnet_internet

<!-- include: 1_telnet/023_get_httpbin_multipleHeaders_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get HTTP/1.1
Host: httpbin.org
Accept: application/json
User-Agent: FileTest/1.0
Connection: close
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** send several headers and see them arrive.
- **New headers:**
  - `Accept`: which format you'd like back
  - `User-Agent`: who is calling (browsers send their name here; you can
    send anything)
- **What happens:** `200 OK`. httpbin's `/get` replies with JSON listing the
  headers it received, including your `"User-Agent": "FileTest/1.0"`.
- **Lesson:** headers are how client and server exchange extra information:
  what you want, who you are, what you send.

---

### Level 9b - Logging in and keeping the line open

#### 040_get_httpbin_bearerMissing_401_telnet_internet

<!-- include: 1_telnet/040_get_httpbin_bearerMissing_401_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /bearer HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** ask for something protected, without proving who you are.
- **What happens:** `401 UNAUTHORIZED`, usually with a `WWW-Authenticate`
  header saying how to log in.
- **Lesson:** 401 = "who are you?". (403 Forbidden would mean "I know who you
  are, and the answer is no".)

#### 041_get_httpbin_bearerToken_200_telnet_internet

<!-- include: 1_telnet/041_get_httpbin_bearerToken_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /bearer HTTP/1.1
Host: httpbin.org
Authorization: Bearer test123
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** send a token in the `Authorization` header.
- **What happens:** `200 OK`, JSON `{"authenticated": true, "token": "test123"}`.
- **Lesson:** this is exactly how APIs like GitHub work: your token travels
  in `Authorization: Bearer <token>` with every request. Never put a real
  token in a file you commit.

#### 042_get_httpbin_keepAliveTwoRequests_200_telnet_internet

<!-- include: 1_telnet/042_get_httpbin_keepAliveTwoRequests_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /get?request=1 HTTP/1.1
Host: httpbin.org

GET /get?request=2 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** send two requests over **one** connection.
- **What happens:** two complete responses, one after the other
  (`"request": "1"`, then `"request": "2"`), then the server hangs up.
- **Lesson:** this is *keep-alive*, what 018 left open. Opening a connection
  takes time, so reusing it makes many small requests much faster.
  `Connection: close` on the last request ends it cleanly.

---

### Level 10 - The other methods on a real server

httpbin has an endpoint for each method (`/put`, `/patch`, `/delete`) that
echoes back what it received. Same idea as Level 7, new methods.

#### 024_put_httpbinJson_200_telnet_internet

<!-- include: 1_telnet/024_put_httpbinJson_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
PUT /put HTTP/1.1
Host: httpbin.org
Content-Type: application/json
Content-Length: 31
Connection: close

{"name":"Amit","city":"Zurich"}
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** replace a whole resource with PUT: `{"name":"Amit","city":"Zurich"}`.
- **What happens:** `200 OK`, the reply shows your data under `"json"`.
- **Notice:** the request looks exactly like a POST - only the method word
  differs. The *meaning* (replace the whole thing) is a promise between
  client and server, not something the text enforces.

#### 025_patch_httpbinJson_200_telnet_internet

<!-- include: 1_telnet/025_patch_httpbinJson_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
PATCH /patch HTTP/1.1
Host: httpbin.org
Content-Type: application/json
Content-Length: 15
Connection: close

{"city":"Bern"}
```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** change only one field with PATCH: `{"city":"Bern"}`.
- **What happens:** `200 OK`, the reply echoes `"city": "Bern"`.
- **Lesson:** PATCH sends only the part that changes, PUT sends everything.

#### 026_delete_httpbin_200_telnet_internet

<!-- include: 1_telnet/026_delete_httpbin_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
DELETE /delete HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** send a DELETE request.
- **What happens:** `200 OK` with a JSON echo. (httpbin has nothing to
  really delete - on a real API this would remove the resource.)
- **Notice:** no body and no `Content-Length` needed: the path says what to
  delete.

#### 027_options_httpbin_200_telnet_internet

<!-- include: 1_telnet/027_options_httpbin_200_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
OPTIONS /get HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** ask the server which methods it accepts at `/get`.
- **What happens:** `200 OK` with an `Allow` header, e.g.
  `Allow: GET, HEAD, OPTIONS`, and no real body.
- **Lesson:** you can ask a server about its rules before using it.

#### 028_get_httpbin_wrongMethod_405_telnet_internet

<!-- include: 1_telnet/028_get_httpbin_wrongMethod_405_telnet_internet.http -->
**Connect**

```bash
telnet httpbin.org 80
```

**Request**

```http
GET /post HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from telnet here)
```

- **Objective:** use the wrong method: `GET` on `/post`, which only
  accepts POST.
- **What happens:** `405 Method Not Allowed`, usually with an `Allow` header
  saying which method would work.
- **Lesson:** compare with 006 (501). 501 = "I don't know this method at
  all". 405 = "I know it, but not here".

---

<br>
<br>
<br>


## 4. Bridge: from HTTP to HTTPS

Almost every real API (GitHub included) only speaks **HTTPS**. telnet can't
do that. This chapter shows that HTTPS is **the same HTTP you already know,
just inside an encrypted tunnel** - so everything from chapter 3 still applies.

### 4.1 The idea, in plain words

Think of HTTP as a **postcard**: anyone handling it on the way can read it.
HTTPS puts the very same postcard **inside a sealed envelope**:

```
HTTP:    your text  ------------------------------------>  server
HTTPS:   your text  --> [ encrypt ] ====tunnel====> [ decrypt ] -->  server
```

- The envelope is called **TLS** (you'll also hear the old name *SSL*).
- HTTPS uses port **443** instead of 80.
- The text inside is **unchanged**: same request line, headers, empty line.

### 4.2 The tool: openssl

`openssl s_client` builds the encrypted tunnel for you. After that it
behaves like telnet: what you paste goes through the tunnel. Commands are in
`2_openssl/000_run_openssl_connection.txt`:

```bash
openssl s_client -connect example.org:443 -quiet -crlf
```

- `-connect host:443` - which server, on the HTTPS port
- `-quiet` - hide the long certificate details
- `-crlf` - send line endings the way HTTP officially wants them
- quit with `Ctrl + C`

### 4.3 Warm-up: an old friend, encrypted

No new file needed. Connect to `example.org:443` as above, then paste
`1_telnet/016_get_example_200_telnet_internet.http` - exactly the same text you sent with telnet.

- **What happens:** the same `200 OK` and "Example Domain" page as in 016.
- **Lesson:** nothing in the request changed. Only the connection did.

### 4.4 043_get_httpbin_https_200_openssl

<!-- include: 2_openssl/043_get_httpbin_https_200_openssl.http -->
**Connect**

```bash
openssl s_client -connect httpbin.org:443 -quiet -crlf
```

**Request**

```http
GET /get HTTP/1.1
Host: httpbin.org
Accept: application/json
User-Agent: FileTest/1.0
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from openssl here)
```

- **What happens:** `200 OK`, and the JSON echo now says
  `"url": "https://httpbin.org/get"` - with an **s**.
- **Lesson:** the server knows the request came through the encrypted tunnel.

### 4.5 044_get_githubApi_zen_200_openssl

<!-- include: 2_openssl/044_get_githubApi_zen_200_openssl.http -->
**Connect**

```bash
openssl s_client -connect api.github.com:443 -quiet -crlf
```

**Request**

```http
GET /zen HTTP/1.1
Host: api.github.com
User-Agent: hello-http-learning (amitchaudhary82)
Accept: application/vnd.github+json
Connection: close

```
<!-- /include -->

**Response**

```http
(paste the response from openssl here)
```

- **What happens:** `200 OK` and one short sentence of GitHub's design
  philosophy (a different one each time).
- **Lesson:** this is your first raw request to the **GitHub API** - the same
  API the GitHub_HTTP repo uses with R. Try removing the `User-Agent` line:
  GitHub refuses requests without one (`403`).

### 4.6 What you now know

| | telnet (chapter 3) | openssl (chapter 4) |
|---|---|---|
| Port | 80 | 443 |
| Encrypted | no | yes |
| Request text | you type it | you type it - identical |
| Who builds the tunnel | nobody | openssl |

Next step: tools that write the request text for you too.

---

<br>
<br>
<br>


## 5. The same examples three ways: telnet, curl, RStudio

You've written every request by hand. Now let two tools write them, and
compare with what you know.

The runnable code lives in two folders, with one section per example
(same `NNN` as the raw file) and comments explaining what the tool does
for you:

| Folder | File | How to run |
|---|---|---|
| `3_curl/` | `curl_examples.sh` | VS Code: one line at a time with "Run Selected Text" (the script refuses a whole-file run on purpose) |
| `4_rstudio/` | `httr2_examples.R` | RStudio: open the repo as project, run section 0, then one example at a time (`Cmd + Enter`) |
| `4_rstudio/` | `send_http_file.R` | sends the raw files from `1_telnet/` unchanged - telnet inside R |

The tables below are the **comparison**: what each example looks like in
each tool, side by side.

| Tool | You write | It writes for you |
|---|---|---|
| telnet / openssl | everything | nothing |
| **curl** (Terminal) | URL + options | request line, Host, Content-Length, empty line, encryption |
| **httr2** (RStudio) | R code | the same as curl (httr2 uses curl inside) |

### 5.1 Easy start: one example, three ways

Take **001** and the local server (start it as in chapter 2).

**telnet** - you write everything:
```bash
telnet 127.0.0.1 8080
# paste 1_telnet/001_get_root_200_telnet_local.http
```

**curl** - you give the URL, `-v` (verbose) shows what it sends:
```bash
curl -v http://127.0.0.1:8080/
```
In the output, lines starting with `>` are the **request** curl wrote,
lines starting with `<` are the **response**. Compare the `>` lines with
your file 001: same request line, same `Host` - plus `User-Agent` and
`Accept`, which curl adds on its own.

**RStudio (httr2)** - you write R:
```r
library(httr2)

request("http://127.0.0.1:8080") |>
  req_perform(verbosity = 1)      # -> request lines, <- response lines
```
`verbosity = 1` is the R version of `curl -v`. To see the request without
sending it: `req_dry_run()`.

### 5.2 Bonus: telnet inside RStudio

R can open a raw connection too, so you can send your **unchanged** `.http`
files from RStudio (full script: `4_rstudio/send_http_file.R`). Open RStudio
in this repo folder, then:

```r
# Send a .http file as-is over a raw connection, like telnet.
# Only for plain HTTP (_local and _telnet files), not HTTPS.
send_http_file <- function(file, host, port = 80) {
  request_text <- readChar(file, file.size(file), useBytes = TRUE)
  request_text <- gsub("\r?\n", "\r\n", request_text)   # HTTP line endings
  con <- socketConnection(host = host, port = port,
                          open = "r+", blocking = TRUE, timeout = 10)
  on.exit(close(con))
  cat(request_text, file = con)
  readLines(con, warn = FALSE)                          # the raw response
}

send_http_file("1_telnet/001_get_root_200_telnet_local.http", "127.0.0.1", 8080)
send_http_file("1_telnet/015_get_httpbin_ip_200_telnet_internet.http", "httpbin.org")
```

Files without `Connection: close` (018, 020) make it wait up to 10 seconds
(the `timeout`), just like telnet hangs.

### 5.3 All levels side by side

Setup for the R lines:
```r
library(httr2)
local <- request("http://127.0.0.1:8080")
bin   <- request("https://httpbin.org")
never_error <- function(resp) FALSE    # keep 4xx/5xx responses to inspect
```
Add `|> req_error(is_error = never_error) |> req_perform(verbosity = 1)` to
any R line to send it and see the conversation.

**Level 1-2: paths and redirects**

| File | curl | httr2 |
|---|---|---|
| 001 | `curl -v http://127.0.0.1:8080/` | `local` |
| 002 | `curl -v http://127.0.0.1:8080/testFolder` | `local \|> req_url_path_append("testFolder") \|> req_options(followlocation = FALSE)` |
| 003 | `curl -v http://127.0.0.1:8080/testFolder/` | `local \|> req_url_path_append("testFolder/")` |
| 004 | `curl -v http://127.0.0.1:8080/missingFile.txt` | `local \|> req_url_path_append("missingFile.txt")` |

Note: curl and httr2 **follow redirects automatically**. 002 only shows the
301 when you switch that off (`followlocation = FALSE`); with curl, *not*
adding `-L` keeps the 301.

**Level 2b: query strings** - the tools encode for you

| File | curl | httr2 |
|---|---|---|
| 029 | `curl -G https://httpbin.org/get -d name=Amit -d city=Zurich` | `bin \|> req_url_path_append("get") \|> req_url_query(name = "Amit", city = "Zurich")` |
| 030 | `curl -G https://httpbin.org/get --data-urlencode "city=St Gallen"` | `... req_url_query(city = "St Gallen")` |
| 031 | `curl -G https://httpbin.org/get --data-urlencode "company=Johnson&Johnson"` | `... req_url_query(company = "Johnson&Johnson")` |
| 032 | `curl -G https://httpbin.org/get --data-urlencode "r=a+b"` | `... req_url_query(r = "a+b")` |

Exercise: run `req_dry_run()` and find how httr2 encoded the space, the `&`
and the `+`. Compare with your files 030 - 032.

**Level 3, 3b, 10: methods**

| File | curl | httr2 |
|---|---|---|
| 005 / 033 | `curl -I http://127.0.0.1:8080/testfile.txt` | `local \|> req_url_path_append("testfile.txt") \|> req_method("HEAD")` |
| 006 | `curl -v -X BADMETHOD http://127.0.0.1:8080/` | `local \|> req_method("BADMETHOD")` |
| 024 | `curl -X PUT -H "Content-Type: application/json" -d '{"name":"Amit","city":"Zurich"}' https://httpbin.org/put` | `bin \|> req_url_path_append("put") \|> req_method("PUT") \|> req_body_json(list(name = "Amit", city = "Zurich"))` |
| 025 | `curl -X PATCH -H "Content-Type: application/json" -d '{"city":"Bern"}' https://httpbin.org/patch` | `bin \|> req_url_path_append("patch") \|> req_method("PATCH") \|> req_body_json(list(city = "Bern"))` |
| 026 | `curl -X DELETE https://httpbin.org/delete` | `bin \|> req_url_path_append("delete") \|> req_method("DELETE")` |
| 027 | `curl -i -X OPTIONS https://httpbin.org/get` | `bin \|> req_url_path_append("get") \|> req_method("OPTIONS")`, then `resp_header(resp, "allow")` |
| 028 | `curl -i https://httpbin.org/post` | `bin \|> req_url_path_append("post")` (GET is the default) |

**Level 5: encoding in paths**

| File | curl | httr2 |
|---|---|---|
| 010 / 012 | `curl -v "http://127.0.0.1:8080/testfile%20with%20space.txt"` | `local \|> req_url_path_append("testfile with space.txt")` |
| 013 | `curl -v "http://127.0.0.1:8080/test_file%25special%40parm%20german_%C3%A4.txt"` | `local \|> req_url_path_append("test_file%special@parm german_ä.txt")` |

Exercise: curl expects you to give it an already encoded URL. Check with
`req_dry_run()` whether httr2 encodes the path for you - and if a character
isn't encoded, use `curl::curl_escape("ä")` to see what it should be.

**Level 6, 6b: servers, Host and status codes**

| File | curl | httr2 |
|---|---|---|
| 014 | `curl -v http://httpbin.org/` | `request("http://httpbin.org")` |
| 015 | `curl https://httpbin.org/ip` | `bin \|> req_url_path_append("ip")`, then `resp_body_json(resp)` |
| 016 | `curl https://example.org/` | `request("https://example.org")` |
| 034 | `curl -v -H "Host:" http://httpbin.org/get` | not possible: httr2 always sends `Host` |
| 036 - 038 | `curl -i https://httpbin.org/status/201` (204, 500) | `bin \|> req_url_path_append("status", "201")` |
| 039 | `curl -i https://httpbin.org/redirect/2` (add `-L` to follow) | `bin \|> req_url_path_append("redirect", "2") \|> req_options(followlocation = FALSE)` |

In curl, `-H "Host:"` (empty value) *removes* a header curl would normally
add - a handy trick to repeat 034.

**Level 7-8: sending data**

| File | curl | httr2 |
|---|---|---|
| 017 | `curl -H "Content-Type: text/plain" --data-binary "hello world" https://httpbin.org/post` | `bin \|> req_url_path_append("post") \|> req_body_raw("hello world", type = "text/plain")` |
| 018 | `curl -H "Content-Type: application/json" -d '{"name":"Amit","city":"Switzerland"}' https://httpbin.org/post` | `bin \|> req_url_path_append("post") \|> req_body_json(list(name = "Amit", city = "Switzerland"))` |
| 019 - 022 | (calculated for you) | (calculated for you) |

This is the clearest difference between the worlds: curl and httr2
**calculate `Content-Length` and insert the empty line themselves**, so the
mistakes of Level 8 simply can't happen. Look for `Content-Length` in the
`-v` / `verbosity = 1` output - you never typed it.

**Level 9, 9b: headers, tokens, connections**

| File | curl | httr2 |
|---|---|---|
| 023 | `curl -v -H "Accept: application/json" -A "FileTest/1.0" https://httpbin.org/get` | `bin \|> req_url_path_append("get") \|> req_headers(Accept = "application/json") \|> req_user_agent("FileTest/1.0")` |
| 040 | `curl -i https://httpbin.org/bearer` | `bin \|> req_url_path_append("bearer")` |
| 041 | `curl -H "Authorization: Bearer test123" https://httpbin.org/bearer` | `bin \|> req_url_path_append("bearer") \|> req_auth_bearer_token("test123")` |
| 042 | `curl -v "https://httpbin.org/get?request=1" "https://httpbin.org/get?request=2"` | two `req_perform()` calls in a row |

For 042, look for `Re-using existing connection` in curl's `-v` output: that
is keep-alive, done for you.

**Chapter 4: HTTPS**

| File | curl | httr2 |
|---|---|---|
| 043 | `curl -v -H "Accept: application/json" -A "FileTest/1.0" https://httpbin.org/get` | `bin \|> req_url_path_append("get") \|> req_user_agent("FileTest/1.0")` |
| 044 | `curl -A "hello-http-learning (amitchaudhary82)" https://api.github.com/zen` | `request("https://api.github.com") \|> req_url_path_append("zen") \|> req_user_agent("hello-http-learning (amitchaudhary82)")`, then `resp_body_string(resp)` |

With curl and httr2 the encryption is invisible: just write `https://`.
In `-v` output, the lines starting with `*` show the TLS tunnel being built
(certificate, protocol) - the work openssl did in chapter 4.

---

<br>
<br>
<br>


## 6. What you can do now

After these 44 experiments you have written every part of an HTTP request
yourself:

| Part | Learned in |
|---|---|
| Request line: method, path, version | 001, 005, 006 |
| All methods: GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS | 3b, 024 - 028 |
| Paths, folders, redirects | 002 - 004, 007 - 009, 039 |
| Query strings | 029 - 032 |
| URL encoding | 010 - 013, 030 - 032 |
| Headers, Host, tokens | 001, 014, 023, 034, 035, 040, 041 |
| Response headers | 033 |
| Body, Content-Type, Content-Length, the empty line | 017 - 022 |
| Connections: close and keep-alive | 014, 018, 042 |
| HTTPS | 043, 044 |
| Status codes 200, 201, 204, 301, 302, 400, 401, 404, 405, 500, 501 | all |

...and you can send the same requests with curl and with R's httr2, knowing
exactly what they write for you. Further httr2 practice lives in the
**GitHub_HTTP** repository.

<br>
<br>
<br>


## 7. Other files

| File | Content |
|---|---|
| `000_Syntax_NNN_method_scenario_status.txt` | file naming rule |
| `build_readme.sh` | copies the request files into this README |
| `1_telnet/000_run_python_mini_server.txt` | command to start the local server |
| `1_telnet/000_run_telnet_connection.txt` | commands to connect (local server, httpbin) |
| `2_openssl/000_run_openssl_connection.txt` | commands for HTTPS connections (chapter 4) |
| `3_curl/curl_examples.sh` | all examples with curl |
| `4_rstudio/httr2_examples.R` | all examples with httr2 |
| `4_rstudio/send_http_file.R` | raw files sent from R, like telnet |
| `http_mini_server_root/` | files served by the local server (incl. tricky names) |
| `http_mini_server_root/Info_Encoding_Characters.txt` | notes on URL structure and special characters |
