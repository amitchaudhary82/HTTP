# HTTP from the ground up - learning by example

This repository teaches HTTP, the language browsers and apps use to talk to
web servers, by **typing raw requests by hand** and watching what the server
answers. No browser, no library: just text over a connection.

Each file is one small experiment. They are numbered so that every step builds
on the one before. Work through them in order.

---

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
| 2xx | Success | 200 OK |
| 3xx | Go somewhere else | 301 Moved Permanently |
| 4xx | **Your** request has a problem | 400 Bad Request, 404 Not Found, 405 Method Not Allowed |
| 5xx | The **server** can't do it | 501 Not Implemented |

---

## 2. Setup

### The two servers we talk to

| Server | What | Used in |
|---|---|---|
| Local mini server | Python's built-in web server, on your own Mac | 001 - 013 |
| httpbin.org / example.org | Real servers on the internet | 014 - 028 |

**httpbin.org** is a test server made for learning: it replies with a
description of the request it received, so you can see exactly what you sent.

### Start the local server

Open a Terminal, go into the server folder and start it
(command also in `000_run_python_mini_server.txt`):

```bash
cd http_mini_server_root
python3 -m http.server 8080 --bind 127.0.0.1
```

- `8080` is the **port**: like a door number on your computer
- `127.0.0.1` means "this computer only", so nobody else can connect
- leave this Terminal open; it shows every request it receives

### Connect with telnet

Open a **second** Terminal and connect (command for httpbin in
`000_run_telnet_connection.txt`):

```bash
telnet 127.0.0.1 8080       # local server
telnet httpbin.org 80       # internet server (port 80 = plain HTTP)
```

telnet opens a raw connection and sends whatever you type. Now **copy the
whole content of an `.http` file, including the empty line(s) at the end,
and paste it**. The server's response appears below.

Tips:
- The **empty line at the end is part of the request**. Without it the server
  keeps waiting for more headers.
- The local server answers once and closes the connection. Connect again for
  the next file.
- To quit a hanging telnet: press `Ctrl + ]`, then type `quit`.

### File naming rule

See `000_Syntax_NNN_method_scenario_status.http`:

```
NNN_method_scenario_status.http
001_get_root_200.http   ->  number 001, method GET, scenario "root", expect 200
```

The **last number is the status code you expect**. Comparing it with what you
actually get is the whole point of each experiment.

---

## 3. The experiments

### Level 1 - The first request

#### 001_get_root_200
```
GET / HTTP/1.1
Host: localhost
```
- **Objective:** send the smallest valid request and get an answer.
- **New concepts:** request line (`GET / HTTP/1.1`), the `Host` header
  (required in HTTP/1.1, it names the server you mean), the empty line.
- **What happens:** `200 OK` and an HTML page listing the files in
  `http_mini_server_root`. `/` means "the root", the top folder of the server.
- **Notice:** the server answers `HTTP/1.0` even though you asked in 1.1. The
  Python mini server only speaks 1.0, and that's allowed.

---

### Level 2 - Paths: asking for different things

#### 002_get_foldernoSlash_301
- **Objective:** ask for a folder **without** the trailing slash: `/testFolder`.
- **What happens:** `301 Moved Permanently` with a header
  `Location: /testFolder/`. The server says "the right address has a slash,
  ask there instead". A browser follows this automatically; telnet doesn't.
- **New concept:** redirects (3xx) and the `Location` header.

#### 003_get_folder_slash_200
- **Objective:** follow the redirect by hand: ask for `/testFolder/`.
- **What happens:** `200 OK` and a listing of the folder's content.
- **Lesson:** for a folder, `/testFolder` and `/testFolder/` are different
  requests.

#### 004_get_missingFile_404
- **Objective:** ask for a file that does not exist.
- **What happens:** `404 File not found`. The connection worked, the request
  was valid, there is just nothing at that path.
- **Lesson:** 4xx means "your request asked for something wrong", not "the
  server is broken".

---

### Level 3 - Methods: what you want to do

#### 005_head_root_200
- **Objective:** use the `HEAD` method instead of `GET`.
- **What happens:** `200 OK` with the same headers as 001, but **no body**.
- **Lesson:** the method says *what to do*. `HEAD` = "only tell me about it"
  (size, type, date), useful to check something without downloading it.

#### 006_get_badMethod_501
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
| GET | "Give me information" | Read data only. Should NOT change anything. The most common method. | No | 001 - 016, 023 |
| HEAD | "Give me info, but no body" | Like GET, but returns only status + headers. Check if something exists, its type, its date. Mostly used by systems. | No | 005 |
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

### Level 4 - Files and folders

#### 007_get_file_200
- **Objective:** download an actual file: `/testfile.txt`.
- **What happens:** `200 OK`, `Content-Type: text/plain`, a `Content-Length`
  header with the file size in bytes, then the file's text as the body.
- **New concepts:** `Content-Type` (what kind of data) and `Content-Length`
  (how many bytes follow). Remember `Content-Length`: it's the star of
  Level 8.

#### 008_get_subFolderFile_200
- **Objective:** reach a file inside a sub-folder:
  `/testFolder/testSubfolderFile.txt`.
- **What happens:** `200 OK` with the file content.
- **Lesson:** the path works like folders on disk, separated by `/`.

#### 009_get_doubleSlash_200
- **Objective:** see how the server handles a strange path: `//`.
- **What happens:** `200 OK`, the root listing again: the server tidies the
  path up.
- **Lesson:** servers *normalise* paths. Not every server does it the same
  way, which is why odd paths are a classic thing to test.

---

### Level 5 - Special characters and URL encoding

The test folder contains files with awkward names on purpose:
`testfile with space.txt` and `test_file%special@parm german_ä.txt`.
Background notes: `http_mini_server_root/Info_Encoding_Characters.txt`.

#### 010_get_fileNameSpaces_400
```
GET /testfile with space.txt HTTP/1.1
```
- **Objective:** ask for a file whose name contains spaces, typed as-is.
- **What happens:** `400 Bad Request`. The request line must be exactly
  *three* parts separated by spaces (method, path, version). The spaces in
  the name split it into five parts, and the server can't read it.
- **Lesson:** some characters can't appear raw in a path.

#### 011_get_fileNameQuotes_400
- **Objective:** try to "protect" the spaces with quotes.
- **What happens:** still `400 Bad Request`.
- **Lesson:** quotes mean nothing in HTTP; they are just more characters.
  There's a proper mechanism instead (next file).

#### 012_get_fileNameUrlEncoding_200
```
GET /testfile%20with%20space.txt HTTP/1.1
```
- **Objective:** write each space as `%20`.
- **What happens:** `200 OK`, the file is found.
- **New concept: URL encoding (percent-encoding).** A forbidden character is
  replaced by `%` plus its code in hexadecimal. Space is code 32 = hex 20, so
  space becomes `%20`. The server decodes it back.

#### 013_get_fileNameSpecialCharUrlEncoding_200
```
GET /test_file%25special%40parm%20german_%C3%A4.txt HTTP/1.1
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

---

### Level 6 - Real servers on the internet

From here on: `telnet httpbin.org 80` (or `telnet example.org 80` for 016).

#### 014_get_httpbin_get_200_telnet
- **Objective:** the same kind of request as 001, but to a real server.
- **New header:** `Connection: close`, asking the server to hang up after
  answering. Without it, HTTP/1.1 keeps the connection open for more
  requests, and telnet just sits there.
- **What happens:** `HTTP/1.1 200 OK` and httpbin's HTML home page.
- **Notice:** this server answers in HTTP/1.1, and sends more headers than
  the mini server (date, server type, security headers ...).
- **Tip:** the request line in this file has trailing spaces after
  `HTTP/1.1`. httpbin accepts them, but strict servers may reply 400. Keeping
  request lines free of trailing spaces is safer.

#### 015_get_httpbin_ip_200_telnet
- **Objective:** ask for `/ip`, an *API endpoint* rather than a web page.
- **What happens:** `200 OK` with `Content-Type: application/json` and a
  body like `{"origin": "<your public IP address>"}`.
- **New concept:** JSON, the data format most APIs answer in: made for
  programs, not people.

#### 016_get_example_200_telnet
- **Objective:** a different public server: `example.org`.
- **What happens:** `200 OK` with a small HTML page ("Example Domain").
- **Lesson:** the `Host` header must match the server you connected to.
  HTTP works the same everywhere.

---

### Level 7 - Sending data (POST)

`GET` only *asks*. `POST` *sends data* to the server, in the **body** after
the empty line. httpbin's `/post` endpoint echoes back what it received.

#### 017_post_httpbinText_200_telnet
```
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 11
Connection: close

hello world
```
- **Objective:** send the text `hello world`.
- **New concepts:**
  - `Content-Type: text/plain` tells the server what kind of data the body is
  - `Content-Length: 11` tells it how many bytes to read: `hello world` is
    exactly 11 characters (the space counts)
- **What happens:** `200 OK`, and the JSON reply contains
  `"data": "hello world"`: proof the server got it.

#### 018_post_httpbinJson_200_telnet
- **Objective:** send JSON data: `{"name":"Amit","city":"Switzerland"}`.
- **What happens:** `200 OK`. Because `Content-Type` says
  `application/json`, httpbin also *understands* it, and shows it parsed
  under `"json": {"city": "Switzerland", "name": "Amit"}`.
- **Notice:** `Content-Length: 36` matches the JSON exactly (count it!).
  This file has no `Connection: close`, so telnet stays connected after the
  answer, until the server times out or you quit.

---

### Level 8 - Experiments: what if Content-Length is wrong?

The server reads the body **only by counting bytes**. These files break that
count on purpose to see what happens.

#### 019_post_httpbinText_shortLength200_telnet
- **Objective:** say `Content-Length: 8`, but send 11 bytes.
- **What happens:** `200 OK`, but `"data": "hello wo"`. The server read
  exactly 8 bytes and ignored the rest (`rld`).
- **Lesson:** the server trusts `Content-Length`, not what you actually sent.

#### 020_post_httpbinText_LongLength_wait_telnet
- **Objective:** say `Content-Length: 25`, but send only 11 bytes.
- **What happens:** **nothing, for a while.** The server waits for the 14
  missing bytes. After a timeout it gives up or closes the connection.
- **Lesson:** a too-large length makes the server hang. A classic cause of
  "my request is stuck".

#### 021_post_httpbinText_missingLengthNoData_telnet
- **Objective:** leave `Content-Length` out completely.
- **What happens:** the server assumes the body is **empty**: the reply shows
  `"data": ""`. Your `hello world` is not treated as body (and may even be
  read as the start of a new, invalid request).
- **Lesson:** with a body, `Content-Length` is effectively required (or
  another way of marking the end, which libraries handle for you).

#### 022_post_httpbinText_missingBlankLine_400_telnet
- **Objective:** forget the empty line between headers and body.
- **What happens:** `400 Bad Request`. Without the empty line the server
  thinks `hello world` is another header, and a header must look like
  `Name: value`.
- **Lesson:** the empty line is the only thing that separates headers from
  the body. It's small but essential.

---

### Level 9 - Headers: telling the server more

#### 023_get_httpbin_multipleHeaders
```
GET /get HTTP/1.1
Host: httpbin.org
Accept: application/json
User-Agent: FileTest/1.0
Connection: close
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

### Level 10 - The other methods on a real server

httpbin has an endpoint for each method (`/put`, `/patch`, `/delete`) that
echoes back what it received. Same idea as Level 7, new methods.

#### 024_put_httpbinJson_200_telnet
- **Objective:** replace a whole resource with PUT: `{"name":"Amit","city":"Zurich"}`.
- **What happens:** `200 OK`, the reply shows your data under `"json"`.
- **Notice:** the request looks exactly like a POST - only the method word
  differs. The *meaning* (replace the whole thing) is a promise between
  client and server, not something the text enforces.

#### 025_patch_httpbinJson_200_telnet
- **Objective:** change only one field with PATCH: `{"city":"Bern"}`.
- **What happens:** `200 OK`, the reply echoes `"city": "Bern"`.
- **Lesson:** PATCH sends only the part that changes, PUT sends everything.

#### 026_delete_httpbin_200_telnet
- **Objective:** send a DELETE request.
- **What happens:** `200 OK` with a JSON echo. (httpbin has nothing to
  really delete - on a real API this would remove the resource.)
- **Notice:** no body and no `Content-Length` needed: the path says what to
  delete.

#### 027_options_httpbin_200_telnet
- **Objective:** ask the server which methods it accepts at `/get`.
- **What happens:** `200 OK` with an `Allow` header, e.g.
  `Allow: GET, HEAD, OPTIONS`, and no real body.
- **Lesson:** you can ask a server about its rules before using it.

#### 028_get_httpbin_wrongMethod_405_telnet
- **Objective:** use the wrong method: `GET` on `/post`, which only
  accepts POST.
- **What happens:** `405 Method Not Allowed`, usually with an `Allow` header
  saying which method would work.
- **Lesson:** compare with 006 (501). 501 = "I don't know this method at
  all". 405 = "I know it, but not here".

---

## 4. What you can do now

After these 28 experiments you have written every part of an HTTP request
yourself:

| Part | Learned in |
|---|---|
| Request line: method, path, version | 001, 005, 006 |
| All methods: GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS | 3b, 024 - 028 |
| Paths, folders, redirects | 002 - 004, 007 - 009 |
| URL encoding | 010 - 013 |
| Headers | 001, 014, 023 |
| Body, Content-Type, Content-Length, the empty line | 017 - 022 |
| Status codes 200, 301, 400, 404, 405, 501 | all |

## 5. Next step: letting a library write the requests

Tools like `curl` or R's **httr2** write exactly these text messages for
you, and add a few things automatically: they calculate `Content-Length`,
insert the empty line, URL-encode paths, follow redirects, and add
encryption (HTTPS, port 443, which telnet can't do).

Practice for that lives in the **hello_HTTP** repository. In httr2,
`req_dry_run()` prints the raw request it would send: it looks just like the
files in this repo.

## 6. Other files

| File | Content |
|---|---|
| `000_Syntax_NNN_method_scenario_status.http` | file naming rule |
| `000_run_python_mini_server.txt` | command to start the local server |
| `000_run_telnet_connection.txt` | command to connect to httpbin |
| `http_mini_server_root/` | files served by the local server (incl. tricky names) |
| `http_mini_server_root/Info_Encoding_Characters.txt` | notes on URL structure and special characters |
