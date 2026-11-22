# HTTP from the ground up - learning by example

This repository teaches HTTP, the language browsers and apps use to talk to
web servers, by **typing raw requests by hand** and watching what the server
answers. No browser, no library: just text over a connection.

Each file is one small experiment. The chapters arrange them so that every
step builds on the one before. Work through them in order.

**Prerequisites**

**Required**

- **Terminal**: Terminal.app on macOS, or an equivalent terminal on Linux or Windows
- **Python 3**: to serve the local files in Chapters 2, 3 and 6
- **Telnet, nc or ncat**: The Carrier for the raw HTTP concepts in Chapters 3 to 5 and 7
- **OpenSSL** (or `ncat --ssl`): The Carrier for HTTPS in Chapter 8

**Optional**

- **curl**: for the practice chapters 6 and 9
- **R and RStudio**: for the practice chapters 6 and 9 (`httr2`)
- **Internet access**: for the real-server experiments in Chapters 4 to 9

Check the main tools from a terminal:

```bash
python3 --version
telnet -h
nc -h
openssl version
curl --version
```

**Quick Start**

Start with the local server. Open the repository in Terminal, then use two
terminal windows.

**Terminal 1 - start the server**

```bash
cd http_mini_server_root
python3 -m http.server 8080 --bind 127.0.0.1
```

**Terminal 2 - connect and send the first request**

```bash
telnet 127.0.0.1 8080
```

Alternatively, on macOS, use netcat with CRLF line endings:

```bash
nc -c 127.0.0.1 8080
```

Paste this request, including the empty line after `Host: localhost`:

```bash
GET / HTTP/1.1
Host: localhost

```

You should receive `HTTP/1.0 200 OK` and an HTML directory listing. In the
server terminal, the matching log entry should show `GET / HTTP/1.1` with
`200`.

Clone the repository, if needed, and enter it:

```bash
git clone https://github.com/amitchaudhary82/http.git
cd http
```

| Part | Chapter | What you learn | Carrier or tool | Messages |
|---|---|---|---|---|
| | 1 - 2 | What HTTP is; setup: The Message and The Carrier | - | - |
| **1** | 3 | Concepts: the local server | telnet, nc or ncat | E301 - E315 |
| **1** | 4 | Concepts: simple GET on the internet | telnet, nc or ncat | E401 - E414 |
| **1** | 5 | Concepts: sending data (POST and other methods) | telnet, nc or ncat | E501 - E511 |
| **1** | 6 | Practice: the same Messages with tools | RStudio (httr2), curl | E3xx - E5xx |
| **2** | 7 | Concepts: authentication | telnet, nc or ncat | E701 - E702 |
| **2** | 8 | Concepts: HTTPS | openssl or ncat --ssl | E801 - E802 |
| **2** | 9 | Practice: authentication and HTTPS with tools | RStudio (httr2), curl, openssl | E7xx - E8xx |

**Concepts** chapters use only a raw Carrier, so you see every byte.
**Practice** chapters send the same Message files with tools.

**Experiment IDs follow the chapters:** `ECNN` = **E**xperiment + chapter +
number, e.g. `E301` is the first experiment of chapter 3, `E502` the second of
chapter 5. The `E` keeps them apart from HTTP status codes: `E404` is an
experiment, `404` is "Not Found". The same ID appears in the README, in the
Message file `messages/E301_...http`, as section `# E301` in the curl and
RStudio scripts, and in pictures: `images/E301_browser.png`.

```
HTTP/
  README.md                                   this guide
  000_Syntax_NNN_method_scenario_status.txt   file naming rule
  000_run_python_mini_server.txt              command to start the local server
  build_readme.sh                             refreshes snippets, numbers and contents
  validate_readme.py                          checks includes, IDs and image links
  messages/        The Message: all 44 HTTP requests (Exxx_...http)
  carriers/        The Carrier: how to connect (telnet, nc, ncat, openssl)
  curl/            http_to_curl.sh + practice scripts (chapters 6, 9)
  rstudio/         http_helpers.R + practice scripts  (chapters 6, 9)
  images/          screenshots, named after the experiment (E301_browser.png)
  http_mini_server_root/   files served by the local server
```

---

<!-- toc -->
**Contents**

- [Chapter 1: The big idea in 60 seconds](#chapter-1-the-big-idea-in-60-seconds)
  - [1.1 Status codes: the server's short answer](#11-status-codes-the-servers-short-answer)
- [Chapter 2: Setup](#chapter-2-setup)
  - [2.1 The servers we talk to](#21-the-servers-we-talk-to)
  - [2.2 Start the local server](#22-start-the-local-server)
  - [2.3 The Message and the Carrier](#23-the-message-and-the-carrier)
  - [2.4 The Carrier: telnet](#24-the-carrier-telnet)
  - [2.5 The Carrier: nc (netcat)](#25-the-carrier-nc-netcat)
  - [2.6 The Carrier: ncat (Nmap)](#26-the-carrier-ncat-nmap)
  - [2.7 Tips for every Carrier](#27-tips-for-every-carrier)
- [Chapter 3: Concepts: The Local Server](#chapter-3-concepts-the-local-server)
  - [3.1 The first request](#31-the-first-request)
  - [3.2 Paths: asking for different things](#32-paths-asking-for-different-things)
  - [3.3 Methods: what you want to do](#33-methods-what-you-want-to-do)
  - [3.4 Files, folders and the response](#34-files-folders-and-the-response)
  - [3.5 Special characters and URL encoding](#35-special-characters-and-url-encoding)
  - [3.6 A rule the local server ignores](#36-a-rule-the-local-server-ignores)
- [Chapter 4: Concepts: Simple GET on the Internet](#chapter-4-concepts-simple-get-on-the-internet)
  - [4.1 Real servers on the internet](#41-real-servers-on-the-internet)
  - [4.2 Query strings: asking with options](#42-query-strings-asking-with-options)
  - [4.3 Headers: telling the server more](#43-headers-telling-the-server-more)
  - [4.4 More status codes](#44-more-status-codes)
  - [4.5 Keeping the line open](#45-keeping-the-line-open)
- [Chapter 5: Concepts: Sending Data](#chapter-5-concepts-sending-data)
  - [5.1 Sending data (POST)](#51-sending-data-post)
  - [5.2 What if Content-Length is wrong?](#52-what-if-content-length-is-wrong)
  - [5.3 The other methods](#53-the-other-methods)
- [Chapter 6: Practice: Part 1 with Tools](#chapter-6-practice-part-1-with-tools)
  - [6.1 With RStudio (httr2)](#61-with-rstudio-httr2)
  - [6.2 With curl](#62-with-curl)
  - [6.3 What the tools change](#63-what-the-tools-change)
- [Chapter 7: Concepts: Authentication](#chapter-7-concepts-authentication)
  - [7.1 Logging in with a token](#71-logging-in-with-a-token)
- [Chapter 8: Concepts: HTTPS](#chapter-8-concepts-https)
  - [8.1 The idea, in plain words](#81-the-idea-in-plain-words)
  - [8.2 The tool: openssl](#82-the-tool-openssl)
  - [8.3 Warm-up: an old friend, encrypted](#83-warm-up-an-old-friend-encrypted)
  - [8.4 E801_get_httpbin_200_https](#84-e801_get_httpbin_200_https)
  - [8.5 E802_get_githubApi_zen_200_https](#85-e802_get_githubapi_zen_200_https)
  - [8.6 What you now know](#86-what-you-now-know)
- [Chapter 9: Practice: Part 2 with Tools](#chapter-9-practice-part-2-with-tools)
  - [9.1 With RStudio (httr2)](#91-with-rstudio-httr2)
  - [9.2 With curl](#92-with-curl)
  - [9.3 openssl for troubleshooting](#93-openssl-for-troubleshooting)
  - [9.4 What the tools change](#94-what-the-tools-change)
- [Chapter 10: What you can do now](#chapter-10-what-you-can-do-now)
- [Chapter 11: Other files](#chapter-11-other-files)
  - [11.1 Maintaining this README](#111-maintaining-this-readme)
<!-- /toc -->

<br>
<br>
<br>


## Chapter 1: The big idea in 60 seconds

> Chapter navigation: [Next: Chapter 2](#chapter-2-setup)

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

### 1.1 Status codes: the server's short answer

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


## Chapter 2: Setup

> Chapter navigation: [Previous: Chapter 1](#chapter-1-the-big-idea-in-60-seconds)
> · [Next: Chapter 3](#chapter-3-concepts-the-local-server)

**Setup checklist**

- [ ] Python 3 is installed and available as `python3`
- [ ] A carrier is installed: telnet, nc or ncat (see 2.3)
- [ ] This repository is the current working directory
- [ ] Port `8080` is available
- [ ] The server terminal remains open while you complete Chapters 2 and 3

### 2.1 The servers we talk to

| Server | What | File suffix | Folder |
|---|---|---|---|
| Local mini server | Python's built-in web server, on your own Mac | `_local` | `messages/` |
| httpbin.org / example.org | Real test servers on the internet, plain HTTP | `_internet` | `messages/` |
| httpbin.org / api.github.com | The same, encrypted (HTTPS) - chapter 8 | `_https` | `messages/` |

The suffix names the **server**, not the tool: any Carrier can send any
Message to the server its suffix names.

**httpbin.org** is a test server made for learning: it replies with a
description of the request it received, so you can see exactly what you sent.

> **Internet note:** Chapters 4 to 9 contain experiments against live
> public servers. Internet access is required, and a remote service may
> temporarily change its response or become unavailable.

### 2.2 Start the local server

Open a Terminal, go into the server folder and start it

```bash
cd http_mini_server_root
python3 -m http.server 8080 --bind 127.0.0.1
```

The Terminal will act as a server and will be waiting for incoming requests
![ch2_local_server_ok](images/ch2_local_server_ok.png)



Additional Info:
- `8080` is the **port**: like a door number on your computer
- `127.0.0.1` means "this computer only", so nobody else can connect
- leave this Terminal open; it shows every request it receives


### 2.3 The Message and the Carrier

Every experiment in this repository is an HTTP request - **The Message**:
plain text with a request line, headers, an empty line and sometimes a body.
The files in `messages/` (`E301_...http`, `E302_...http` ...) contain exactly
that text and nothing else.

To reach the server, the text needs **The Carrier**: a program that opens a
connection to a host and port and passes your text through, unchanged.

```bash
The Message   (messages/Exxx files)  what you say
The Carrier   (telnet, nc, ncat)     how it travels
The Server    (local or internet)    who answers
```

The Message is the same whichever Carrier you use. Only the **connect line**
changes:

| The Carrier | Connect (local server) | Line endings | Included with |
|---|---|---|---|
| telnet | `telnet 127.0.0.1 8080` | CR LF automatically | Linux; install on macOS and Windows |
| nc (netcat) | `nc -c 127.0.0.1 8080` | CR LF with `-c` (macOS) or `-C` (Linux) | macOS, most Linux |
| ncat (Nmap) | `ncat -C 127.0.0.1 8080` | CR LF with `-C` | install on all systems |

The concept chapters use **telnet** (and openssl for HTTPS in chapter 8). Pick any Carrier below
that works on your machine; The Message stays the same. Connect commands for
each Carrier are in `carriers/`.

### 2.4 The Carrier: telnet

**Install** (if `telnet` is not found):
- macOS: `brew install telnet` (no longer part of macOS)
- Windows: *Turn Windows features on or off* > **Telnet Client** (needs admin rights)
- Linux: `sudo apt install telnet`

**Connect**, in a second terminal while the local server is running:

```bash
telnet 127.0.0.1 8080       # local server
telnet httpbin.org 80       # internet server (chapters 4, 5 and 7)
```

![ch2_telnet_connection_ok](images/ch2_telnet_connection_ok.png)

Then paste The Message of the experiment. The response appears below it.

- Enter sends CR LF (`0D 0A`) automatically. The empty line that ends the
  headers is a second `0D 0A`, so a request ends with `0D 0A 0D 0A`.
- Quit a hanging connection: `Ctrl + ]`, then type `quit`.

### 2.5 The Carrier: nc (netcat)

**Install**: nothing to do on macOS and most Linux systems. Not available on
Windows (use ncat instead).

**Connect** (macOS):

```bash
nc -c 127.0.0.1 8080        # local server
nc -c httpbin.org 80        # internet server
```

**Send a request file directly**, byte for byte, without copy-paste:

```bash
nc -c 127.0.0.1 8080 < messages/E301_get_root_200_local.http
```

- `-c` turns every line ending into CR LF, as HTTP expects. On Linux the
  option is a capital `-C`; check `man nc`.
- Without `-c`, nc sends only `0A` (LF). Most servers accept that, strict
  ones may not.
- Quit: `Ctrl + C`.
- More commands: `carriers/nc.txt`.

### 2.6 The Carrier: ncat (Nmap)

ncat is a modern netcat from the Nmap project. It works the same on macOS,
Windows and Linux, and can also do HTTPS.

**Install**:
- macOS: `brew install nmap` (ncat is included)
- Windows: the Nmap installer from nmap.org (includes ncat)
- Linux: `sudo apt install ncat`

**Connect**:

```bash
ncat -C 127.0.0.1 8080      # local server
ncat -C httpbin.org 80      # internet server
ncat -C --ssl httpbin.org 443   # HTTPS, like openssl in chapter 8
```

**Send a request file directly**:

```bash
ncat -C 127.0.0.1 8080 < messages/E301_get_root_200_local.http
```

- `-C` (or `--crlf`) turns line endings into CR LF.
- Quit: `Ctrl + C`.

### 2.7 Tips for every Carrier

- The **empty line at the end is part of the request**. Without it the
  server keeps waiting for more headers.
- The local server answers once and closes the connection. Connect again for
  the next experiment.
- The request files contain **only** the request, no comments, so copying or
  sending a whole file is always safe. All explanations live in this README.
- All Messages are stored as files in `messages/`; connect commands for
  every Carrier are in `carriers/`.

<br>
<br>
<br>


**Part 1 - The basics, without authentication** (chapters 3 to 6)

## Chapter 3: Concepts: The Local Server

> Chapter navigation: [Previous: Chapter 2](#chapter-2-setup)
> · [Next: Chapter 4](#chapter-4-concepts-simple-get-on-the-internet)

**The Carrier:** the exercises use **telnet**. Every Message is plain HTTP,
so any Carrier from chapter 2 works the same; only the connect line changes
(see 2.3).

For this experiment we have setup folder and files with simple and special characters and we will try few combinations which will return the file names back

![ch3_folder_structure](images/ch3_folder_structure.png)

<br>
<br>
<br>

### 3.1 The first request

#### E301_get_root_200_local

<!-- include: messages/E301_get_root_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET / HTTP/1.1
Host: localhost

```
<!-- /include -->

which should look like below
![E301_request](images/E301_request.png)

<br>

**Server Connection Confirmed**
```bash
MacBook-Pro-2:http_mini_server_root amitchaudhary$ python3 -m http.server 8080 --bind 127.0.0.1
Serving HTTP on 127.0.0.1 port 8080 (http://127.0.0.1:8080/) ...
127.0.0.1 - - [21/Nov/2026 22:39:55] "GET / HTTP/1.1" 200 -
```


![E301_server_confirmation](images/E301_server_confirmation.png)

<br>

**Response**

```bash
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

<br>
<br>

**Simulation via Browser**

This can also be simulated in browser via using
```bash
http://localhost:8080
```

![E301_browser](images/E301_browser.png)

<br>
<br>
<br>

### 3.2 Paths: asking for different things

#### E302_get_foldernoSlash_301_local

<!-- include: messages/E302_get_foldernoSlash_301_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /testFolder HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Server Connection Confirmed**
```bash
MacBook-Pro-2:http_mini_server_root amitchaudhary$ python3 -m http.server 8080 --bind 127.0.0.1
Serving HTTP on 127.0.0.1 port 8080 (http://127.0.0.1:8080/) ...
127.0.0.1 - - [21/Nov/2026 22:39:55] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [21/Nov/2026 22:44:27] "GET /testFolder HTTP/1.1" 301 -
```

<br>

**Response**

```bash
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

<br>
<br>
<br>

#### E303_get_folder_slash_200_local

<!-- include: messages/E303_get_folder_slash_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /testFolder/ HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
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


![E303_browser](images/E303_browser.png)

<br>
<br>
<br>

#### E304_get_missingFile_404_local

<!-- include: messages/E304_get_missingFile_404_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /missingFile.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
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

<br>
<br>
<br>

### 3.3 Methods: what you want to do

#### E305_head_root_200_local

<!-- include: messages/E305_head_root_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
HEAD / HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** use the `HEAD` method instead of `GET`.
- **What happens:** `200 OK` with the same headers as E301, but **no body**.
- **Lesson:** the method says *what to do*. `HEAD` = "only tell me about it"
  (size, type, date), useful to check something without downloading it.

<br>
<br>
<br>

#### E306_get_badMethod_501_local

<!-- include: messages/E306_get_badMethod_501_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
BADMETHOD / HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** invent a method the server doesn't know: `BADMETHOD`.
- **What happens:** `501 Unsupported method ('BADMETHOD')`.
- **Lesson:** a method is just a word; the server decides which ones it
  supports. 5xx because the *server* can't do it (it isn't "your path is
  wrong" like 404).

<br>
<br>

**All request methods at a glance**

The method is the first word of the request line. It tells the server
**what you want to do**. These are the ones you will meet most:

| Method | In plain words | Used for | Has a body? | Tried in |
|---|---|---|---|---|
| GET | "Give me information" | Read data only. Should NOT change anything. The most common method. | No | most files |
| HEAD | "Give me info, but no body" | Like GET, but returns only status + headers. Check if something exists, its type, its date. Mostly used by systems. | No | E305, E310 |
| POST | "I am sending you data" | Create something / send data to process. Usually changes something on the server. | Yes (often JSON) | E501 - E506 |
| PUT | "Replace it with this" | Replace a WHOLE resource: delete the old version, store the new one. | Yes | E507 |
| PATCH | "Change only this part" | Update PART of a resource. | Yes | E508 |
| DELETE | "Remove it" | Delete a resource. | Usually no | E509 |
| OPTIONS | "What are my choices?" | Ask which methods are allowed at this path. | No | E510 |

**PUT vs PATCH** - think of a profile with name and city:
- PUT `{"name":"Amit","city":"Zurich"}` = "this is the complete new profile"
- PATCH `{"city":"Bern"}` = "only change the city, keep the rest"

In practice teams sometimes use these loosely - don't worry too much.

**Safe to repeat? (the word is *idempotent*)**
Doing GET, HEAD, PUT or DELETE twice gives the same result as doing it once.
POST is different: sending it twice usually creates two things (two orders,
two comments). That's the real difference between POST and PUT.

<br>
<br>
<br>

### 3.4 Files, folders and the response

#### E307_get_file_200_local

<!-- include: messages/E307_get_file_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /testfile.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** download an actual file: `/testfile.txt`.
- **What happens:** `200 OK`, `Content-Type: text/plain`, a `Content-Length`
  header with the file size in bytes, then the file's text as the body.
- **New concepts:** `Content-Type` (what kind of data) and `Content-Length`
  (how many bytes follow). Remember `Content-Length`: it's the star of
  section 5.2.

<br>
<br>
<br>

#### E308_get_subFolderFile_200_local

<!-- include: messages/E308_get_subFolderFile_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /testFolder/testSubfolderFile.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** reach a file inside a sub-folder:
  `/testFolder/testSubfolderFile.txt`.
- **What happens:** `200 OK` with the file content.
- **Lesson:** the path works like folders on disk, separated by `/`.

<br>
<br>
<br>

#### E309_get_doubleSlash_200_local

<!-- include: messages/E309_get_doubleSlash_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET // HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** see how the server handles a strange path: `//`.
- **What happens:** `200 OK`, the root listing again: the server tidies the
  path up.
- **Lesson:** servers *normalise* paths. Not every server does it the same
  way, which is why odd paths are a classic thing to test.

<br>
<br>
<br>

#### E310_head_file_headers_200_local

<!-- include: messages/E310_head_file_headers_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
HEAD /testfile.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
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

- **Lesson:** compare with E307 - identical headers, only the body is
  missing. This is how programs check "has this file changed?" cheaply.

<br>
<br>
<br>

### 3.5 Special characters and URL encoding

The test folder contains files with awkward names on purpose:
`testfile with space.txt` and `test_file%special@parm german_ä.txt`.
Background notes: `http_mini_server_root/Info_Encoding_Characters.txt`.

<br>
<br>
<br>

#### E311_get_fileNameSpaces_400_local

<!-- include: messages/E311_get_fileNameSpaces_400_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /testfile with space.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** ask for a file whose name contains spaces, typed as-is.
- **What happens:** `400 Bad Request`. The request line must be exactly
  *three* parts separated by spaces (method, path, version). The spaces in
  the name split it into five parts, and the server can't read it.
- **Lesson:** some characters can't appear raw in a path.

<br>
<br>
<br>

#### E312_get_fileNameQuotes_400_local

<!-- include: messages/E312_get_fileNameQuotes_400_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /"testfile with space.txt" HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** try to "protect" the spaces with quotes.
- **What happens:** still `400 Bad Request`.
- **Lesson:** quotes mean nothing in HTTP; they are just more characters.
  There's a proper mechanism instead (next file).

<br>
<br>
<br>

#### E313_get_fileNameUrlEncoding_200_local

<!-- include: messages/E313_get_fileNameUrlEncoding_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /testfile%20with%20space.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** write each space as `%20`.
- **What happens:** `200 OK`, the file is found.
- **New concept: URL encoding (percent-encoding).** A forbidden character is
  replaced by `%` plus its code in hexadecimal. Space is code 32 = hex 20, so
  space becomes `%20`. The server decodes it back.

<br>
<br>
<br>

#### E314_get_fileNameSpecialCharUrlEncoding_200_local

<!-- include: messages/E314_get_fileNameSpecialCharUrlEncoding_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET /test_file%25special%40parm%20german_%C3%A4.txt HTTP/1.1
Host: localhost

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** encode several special characters at once.
- **What happens:** `200 OK` for the file `test_file%special@parm german_ä.txt`.
- **Decoding table:**

  | Encoded | Character | Why it needs encoding |
  |---|---|---|
  | `%25` | `%` | `%` itself starts an encoding, so it must be encoded too |
  | `%40` | `@` | `@` has a special meaning in URLs (user@host) |
  | `%20` | space | splits the request line (see E311) |
  | `%C3%A4` | `ä` | non-English letters are sent as UTF-8 bytes: `ä` is **two** bytes, C3 and A4 |

- **Lesson:** libraries (browsers, curl, R's httr2) do this encoding for
  you. Here you did it by hand, so you know what's happening underneath.
- **Notice:** in the E301 listing this file's link is `german_a%CC%88`:
  macOS stores `ä` as `a` + `¨` (two characters). Both forms find the file.

<br>
<br>
<br>

### 3.6 A rule the local server ignores

#### E315_get_root_missingHost_200_local

<!-- include: messages/E315_get_root_missingHost_200_local.http -->
**The Carrier**

```bash
telnet 127.0.0.1 8080
```

<br>

**The Message**

```bash
GET / HTTP/1.1

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** leave out the `Host` header on the local mini server.
- **What happens:** `200 OK` - it answers anyway.
- **Lesson:** not every server enforces every rule. A request that "works"
  on one server can fail on another, so test against the real target.
  Compare with E404 in chapter 4: the same request on a real server.

<br>
<br>
<br>

## Chapter 4: Concepts: Simple GET on the Internet

> Chapter navigation: [Previous: Chapter 3](#chapter-3-concepts-the-local-server)
> · [Next: Chapter 5](#chapter-5-concepts-sending-data)

These experiments require internet access and plain HTTP. Live server
responses can change; use the expected status code and response structure
from each experiment as a success check, not exact wording or formatting.

All experiments in this chapter go to real servers on the internet:
`telnet httpbin.org 80` (or `telnet example.org 80` for E403).

<br>
<br>
<br>

### 4.1 Real servers on the internet

#### E401_get_httpbin_get_200_internet

<!-- include: messages/E401_get_httpbin_get_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET / HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** the same kind of request as E301, but to a real server.
- **New header:** `Connection: close`, asking the server to hang up after
  answering. Without it, HTTP/1.1 keeps the connection open for more
  requests, and telnet just sits there.
- **What happens:** `HTTP/1.1 200 OK` and httpbin's HTML home page.
- **Notice:** this server answers in HTTP/1.1, and sends more headers than
  the mini server (date, server type, security headers ...).

<br>
<br>
<br>

#### E402_get_httpbin_ip_200_internet

<!-- include: messages/E402_get_httpbin_ip_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /ip HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** ask for `/ip`, an *API endpoint* rather than a web page.
- **What happens:** `200 OK` with `Content-Type: application/json` and a
  body like `{"origin": "<your public IP address>"}`.
- **New concept:** JSON, the data format most APIs answer in: made for
  programs, not people.

<br>
<br>
<br>

#### E403_get_example_200_internet

<!-- include: messages/E403_get_example_200_internet.http -->
**The Carrier**

```bash
telnet example.org 80
```

<br>

**The Message**

```bash
GET / HTTP/1.1
Host: example.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** a different public server: `example.org`.
- **What happens:** `200 OK` with a small HTML page ("Example Domain").
- **Lesson:** the `Host` header must match the server you connected to.
  HTTP works the same everywhere.

<br>
<br>
<br>

#### E404_get_httpbin_missingHost_400_internet

<!-- include: messages/E404_get_httpbin_missingHost_400_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get HTTP/1.1
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** leave out the `Host` header on a real server.
- **What happens:** `400 Bad Request`.
- **Lesson:** in HTTP/1.1, `Host` is **required**. One machine can host many
  websites, and `Host` says which one you mean. (The local server in E315
  didn't care - real servers do.)

<br>
<br>
<br>

### 4.2 Query strings: asking with options

The path says **what** you want. The **query**, everything after `?`, says
**how** you want it: `key=value` pairs joined by `&`. These go to httpbin
(`telnet httpbin.org 80`), whose `/get` replies with the pairs it understood
under `"args"`.

<br>
<br>
<br>

#### E405_get_httpbin_queryString_200_internet

<!-- include: messages/E405_get_httpbin_queryString_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get?name=Amit&city=Zurich HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
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
  you didn't type. (curl and httr2 add more, see chapter 6.)

<br>
<br>
<br>

#### E406_get_httpbin_querySpaceEncoded_200_internet

<!-- include: messages/E406_get_httpbin_querySpaceEncoded_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get?city=St%20Gallen HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
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
- **Lesson:** the same `%20` rule as in paths (3.5) applies in the query.

<br>
<br>
<br>

#### E407_get_httpbin_queryAmpersandEncoded_200_internet

<!-- include: messages/E407_get_httpbin_queryAmpersandEncoded_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get?company=Johnson%26Johnson&country=US HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
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

<br>
<br>
<br>

#### E408_get_httpbin_queryPlusSign_200_internet

<!-- include: messages/E408_get_httpbin_queryPlusSign_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get?q=a+b&r=a%2Bb HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
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

<br>
<br>
<br>

### 4.3 Headers: telling the server more

#### E409_get_httpbin_multipleHeaders_200_internet

<!-- include: messages/E409_get_httpbin_multipleHeaders_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get HTTP/1.1
Host: httpbin.org
Accept: application/json
User-Agent: FileTest/1.0
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
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

<br>
<br>
<br>

### 4.4 More status codes

httpbin's `/status/NNN` answers with whatever code you ask for: a safe way to
see codes you rarely meet on purpose.

<br>
<br>
<br>

#### E410_get_httpbin_status201_201_internet

<!-- include: messages/E410_get_httpbin_status201_201_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /status/201 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **What happens:** `201 CREATED`.
- **Lesson:** 201 is the typical answer to a successful POST that created
  something new (an issue, an order).

<br>
<br>
<br>

#### E411_get_httpbin_status204_204_internet

<!-- include: messages/E411_get_httpbin_status204_204_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /status/204 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **What happens:** `204 NO CONTENT` and no body at all.
- **Lesson:** success doesn't always come with data. A DELETE often answers
  204: "done, nothing more to say".

<br>
<br>
<br>

#### E412_get_httpbin_status500_500_internet

<!-- include: messages/E412_get_httpbin_status500_500_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /status/500 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **What happens:** `500 INTERNAL SERVER ERROR`.
- **Lesson:** the classic "the server broke" code. Your request was fine;
  retrying later may help.

<br>
<br>
<br>

#### E413_get_httpbin_redirectChain_302_internet

<!-- include: messages/E413_get_httpbin_redirectChain_302_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /redirect/2 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** follow a chain of redirects by hand.
- **What happens:** `302 FOUND` with a `Location` header pointing to the next
  address. Send a new request to that address: another `302`. The next one
  finally gives `200`.
- **Lesson:** 301 = moved forever, 302 = "look over there for now". Browsers
  and libraries follow these silently; here you see each hop.

<br>
<br>
<br>

### 4.5 Keeping the line open

#### E414_get_httpbin_keepAliveTwoRequests_200_internet

<!-- include: messages/E414_get_httpbin_keepAliveTwoRequests_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /get?request=1 HTTP/1.1
Host: httpbin.org

GET /get?request=2 HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** send two requests over **one** connection.
- **What happens:** two complete responses, one after the other
  (`"request": "1"`, then `"request": "2"`), then the server hangs up.
- **Lesson:** this is *keep-alive*, what E502 leaves open. Opening a connection
  takes time, so reusing it makes many small requests much faster.
  `Connection: close` on the last request ends it cleanly.

<br>
<br>
<br>

## Chapter 5: Concepts: Sending Data

> Chapter navigation: [Previous: Chapter 4](#chapter-4-concepts-simple-get-on-the-internet)
> · [Next: Chapter 6](#chapter-6-practice-part-1-with-tools)

### 5.1 Sending data (POST)

`GET` only *asks*. `POST` *sends data* to the server, in the **body** after
the empty line. httpbin's `/post` endpoint echoes back what it received.

<br>
<br>
<br>

#### E501_post_httpbinText_200_internet

<!-- include: messages/E501_post_httpbinText_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 11
Connection: close

hello world
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** send the text `hello world`.
- **New concepts:**
  - `Content-Type: text/plain` tells the server what kind of data the body is
  - `Content-Length: 11` tells it how many bytes to read: `hello world` is
    exactly 11 characters (the space counts)
- **What happens:** `200 OK`, and the JSON reply contains
  `"data": "hello world"`: proof the server got it.

<br>
<br>
<br>

#### E502_post_httpbinJson_200_internet

<!-- include: messages/E502_post_httpbinJson_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: application/json
Content-Length: 36

{"name":"Amit","city":"Switzerland"}
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** send JSON data: `{"name":"Amit","city":"Switzerland"}`.
- **What happens:** `200 OK`. Because `Content-Type` says
  `application/json`, httpbin also *understands* it, and shows it parsed
  under `"json": {"city": "Switzerland", "name": "Amit"}`.
- **Notice:** `Content-Length: 36` matches the JSON exactly (count it!).
- **Intentionally no `Connection: close`:** telnet stays connected after the
  answer, until the server times out or you quit. That's HTTP/1.1
  *keep-alive* - see E414 (chapter 4) for what it's good for.

<br>
<br>
<br>

### 5.2 What if Content-Length is wrong?

The server reads the body **only by counting bytes**. These files break that
count on purpose to see what happens.

<br>
<br>
<br>

#### E503_post_httpbinText_shortLength_200_internet

<!-- include: messages/E503_post_httpbinText_shortLength_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 8
Connection: close

hello world
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** say `Content-Length: 8`, but send 11 bytes.
- **What happens:** `200 OK`, but `"data": "hello wo"`. The server read
  exactly 8 bytes and ignored the rest (`rld`).
- **Lesson:** the server trusts `Content-Length`, not what you actually sent.

<br>
<br>
<br>

#### E504_post_httpbinText_longLength_timeout_internet

<!-- include: messages/E504_post_httpbinText_longLength_timeout_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Content-Length: 25
Connection: close

hello world
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** say `Content-Length: 25`, but send only 11 bytes.
- **What happens:** **nothing, for a while.** The server waits for the 14
  missing bytes. After a timeout it gives up or closes the connection.
- **Lesson:** a too-large length makes the server hang. A classic cause of
  "my request is stuck".

<br>
<br>
<br>

#### E505_post_httpbinText_missingLengthNoData_internet

<!-- include: messages/E505_post_httpbinText_missingLengthNoData_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Connection: close

hello world
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** leave `Content-Length` out completely.
- **What happens:** the server assumes the body is **empty**: the reply shows
  `"data": ""`. Your `hello world` is not treated as body (and may even be
  read as the start of a new, invalid request).
- **Lesson:** with a body, `Content-Length` is effectively required (or
  another way of marking the end, which libraries handle for you).

<br>
<br>
<br>

#### E506_post_httpbinText_missingBlankLine_400_internet

<!-- include: messages/E506_post_httpbinText_missingBlankLine_400_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
POST /post HTTP/1.1
Host: httpbin.org
Content-Type: text/plain
Connection: close
Content-Length: 11
hello world
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** forget the empty line between headers and body.
- **What happens:** `400 Bad Request`. Without the empty line the server
  thinks `hello world` is another header, and a header must look like
  `Name: value`.
- **Lesson:** the empty line is the only thing that separates headers from
  the body. It's small but essential.

<br>
<br>
<br>

### 5.3 The other methods

httpbin has an endpoint for each method (`/put`, `/patch`, `/delete`) that
echoes back what it received. Same idea as 5.1, new methods.

<br>
<br>
<br>

#### E507_put_httpbinJson_200_internet

<!-- include: messages/E507_put_httpbinJson_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
PUT /put HTTP/1.1
Host: httpbin.org
Content-Type: application/json
Content-Length: 31
Connection: close

{"name":"Amit","city":"Zurich"}
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** replace a whole resource with PUT: `{"name":"Amit","city":"Zurich"}`.
- **What happens:** `200 OK`, the reply shows your data under `"json"`.
- **Notice:** the request looks exactly like a POST - only the method word
  differs. The *meaning* (replace the whole thing) is a promise between
  client and server, not something the text enforces.

<br>
<br>
<br>

#### E508_patch_httpbinJson_200_internet

<!-- include: messages/E508_patch_httpbinJson_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
PATCH /patch HTTP/1.1
Host: httpbin.org
Content-Type: application/json
Content-Length: 15
Connection: close

{"city":"Bern"}
```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** change only one field with PATCH: `{"city":"Bern"}`.
- **What happens:** `200 OK`, the reply echoes `"city": "Bern"`.
- **Lesson:** PATCH sends only the part that changes, PUT sends everything.

<br>
<br>
<br>

#### E509_delete_httpbin_200_internet

<!-- include: messages/E509_delete_httpbin_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
DELETE /delete HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** send a DELETE request.
- **What happens:** `200 OK` with a JSON echo. (httpbin has nothing to
  really delete - on a real API this would remove the resource.)
- **Notice:** no body and no `Content-Length` needed: the path says what to
  delete.

<br>
<br>
<br>

#### E510_options_httpbin_200_internet

<!-- include: messages/E510_options_httpbin_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
OPTIONS /get HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** ask the server which methods it accepts at `/get`.
- **What happens:** `200 OK` with an `Allow` header, e.g.
  `Allow: GET, HEAD, OPTIONS`, and no real body.
- **Lesson:** you can ask a server about its rules before using it.

<br>
<br>
<br>

#### E511_get_httpbin_wrongMethod_405_internet

<!-- include: messages/E511_get_httpbin_wrongMethod_405_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /post HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** use the wrong method: `GET` on `/post`, which only
  accepts POST.
- **What happens:** `405 Method Not Allowed`, usually with an `Allow` header
  saying which method would work.
- **Lesson:** compare with E306 (status 501). 501 = "I don't know this method at
  all". 405 = "I know it, but not here".

<br>
<br>
<br>

## Chapter 6: Practice: Part 1 with Tools

> Chapter navigation: [Previous: Chapter 5](#chapter-5-concepts-sending-data)
> · [Next: Chapter 7](#chapter-7-concepts-authentication)

You know every part of a Message now. This chapter sends **the same Message
files** with tools - nothing is copied or retyped. A small helper reads a file
and builds the request from it; the server comes from the file name suffix
(`_local`, `_internet`) and the `Host:` line.

| The Carrier | You write | It writes for you |
|---|---|---|
| telnet / nc / ncat | everything | nothing |
| **httr2** (RStudio) | nothing - the helper reads The Message | Host, Content-Length, encoding |
| **curl** (Terminal) | nothing - the helper reads The Message | the same as httr2 (httr2 uses curl inside) |

More tools (for example Python) can be added later as new sections here; the
Message files stay the same.

<br>
<br>
<br>

### 6.1 With RStudio (httr2)

Open the repository folder in RStudio and load the shared helpers once:

```r
library(dplyr)                      # for the %>% pipe
source("rstudio/http_helpers.R")   # read_..., split_..., prepare_..., send_... (see the file header)
```

**One Message** - read the file, then say where it goes (the Carrier is
always given in the call, never taken from the file):

```r
req <-
  read_http_message_from_file("messages/E301_get_root_200_local.http") %>%
    prepare_request_from_http_message("127.0.0.1", 8080)

req_dry_run(req)                      # what httr2 would send - compare with the file
resp <- send_request_to_server(req)   # send it: "->" = sent, "<-" = received
```

**The raw Carrier in R** - `send_raw_http_message_to_server()` sends the
Message byte for byte, like telnet. Use it to compare wherever httr2 behaves
differently:

```r
read_http_message_from_file("messages/E503_post_httpbinText_shortLength_200_internet.http") %>%
  send_raw_http_message_to_server("httpbin.org", 80) %>%
  cat(sep = "\n")
```

**All Part 1 Messages at once** - a for loop sends every file of chapters 3
to 5 and collects the status in a tibble: `expected` (from the file name)
next to `received`. The rows where they differ are exactly the cases in 6.3.

Script with every experiment and the loop: `rstudio/practice_part1_basics.R`

<br>
<br>
<br>

### 6.2 With curl

```bash
source curl/http_to_curl.sh
http_to_curl messages/E301_get_root_200_local.http
HTTP_TO_CURL_DRY=1 http_to_curl messages/E301_get_root_200_local.http   # only show the command
```

Script with every experiment: `curl/practice_part1_basics.sh`

**Tip:** API documentation and the browser's developer tools ("Copy as cURL")
show requests as curl commands. You don't need to run them - httr2 can
translate them:

```r
httr2::curl_translate("curl -H 'Accept: application/json' https://httpbin.org/get")
```

<br>
<br>
<br>

### 6.3 What the tools change

| Experiments | Raw Carrier (telnet, nc, ncat) | httr2 / curl |
|---|---|---|
| E302, E413 redirects | you see the 301/302 | our helpers show it (strict; `follow_redirects = TRUE` lets httr2 follow); curl shows it (add `-L` to follow) |
| E311, E312 raw spaces | server answers 400 | the tool refuses or encodes the URL |
| E315, E404 missing Host | sent without Host | Host is always added (curl: remove with `-H "Host:"`) |
| E503 - E505 wrong or missing Content-Length | server reads the wrong number of bytes | the tool calculates the length, the whole body arrives |
| E506 missing empty line | body read as a header | the same: the line becomes a header |
| E414 two requests in one file | both answered on one connection | only the first is sent |

Everything else arrives with the same meaning: method, path, headers and
body. Look for `Content-Length` in the verbose output - it isn't in most
Message files, the tool added it.

<br>
<br>
<br>

**Part 2 - Authentication and HTTPS** (chapters 7 to 9)

## Chapter 7: Concepts: Authentication

> Chapter navigation: [Previous: Chapter 6](#chapter-6-practice-part-1-with-tools)
> · [Next: Chapter 8](#chapter-8-concepts-https)

### 7.1 Logging in with a token

#### E701_get_httpbin_bearerMissing_401_internet

<!-- include: messages/E701_get_httpbin_bearerMissing_401_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /bearer HTTP/1.1
Host: httpbin.org
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** ask for something protected, without proving who you are.
- **What happens:** `401 UNAUTHORIZED`, usually with a `WWW-Authenticate`
  header saying how to log in.
- **Lesson:** 401 = "who are you?". (403 Forbidden would mean "I know who you
  are, and the answer is no".)

<br>
<br>
<br>

#### E702_get_httpbin_bearerToken_200_internet

<!-- include: messages/E702_get_httpbin_bearerToken_200_internet.http -->
**The Carrier**

```bash
telnet httpbin.org 80
```

<br>

**The Message**

```bash
GET /bearer HTTP/1.1
Host: httpbin.org
Authorization: Bearer test123
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from telnet here)
```

- **Objective:** send a token in the `Authorization` header.
- **What happens:** `200 OK`, JSON `{"authenticated": true, "token": "test123"}`.
- **Test value only:** `test123` is not a real credential. Do not replace it
  with a real API token; public services and committed repositories can expose
  secrets.
- **Lesson:** `Authorization: Bearer <token>` is a common API auth format.
  `test123` is only a dummy token: this example uses plain HTTP, so a real
  token would be exposed. Real credentials require HTTPS and should never be
  committed to a file.

<br>
<br>
<br>

## Chapter 8: Concepts: HTTPS

> Chapter navigation: [Previous: Chapter 7](#chapter-7-concepts-authentication)
> · [Next: Chapter 9](#chapter-9-practice-part-2-with-tools)

OpenSSL and these HTTPS experiments require internet access. Confirm that
DNS and TLS connections are available before continuing.

Almost every real API (GitHub included) only speaks **HTTPS**. telnet can't
do that. This chapter shows that HTTPS is **the same HTTP you already know,
just inside an encrypted tunnel** - so everything from chapters 3 to 7 still applies.

<br>
<br>
<br>

### 8.1 The idea, in plain words

Think of HTTP as a **postcard**: anyone handling it on the way can read it.
HTTPS puts the very same postcard **inside a sealed envelope**:

```
HTTP:    your text  ------------------------------------>  server
HTTPS:   your text  --> [ encrypt ] ====tunnel====> [ decrypt ] -->  server
```

- The envelope is called **TLS** (you'll also hear the old name *SSL*).
- HTTPS uses port **443** instead of 80.
- The text inside is **unchanged**: same request line, headers, empty line.

<br>
<br>
<br>

### 8.2 The tool: openssl

`openssl s_client` builds the encrypted tunnel for you. After that it
behaves like telnet: what you paste goes through the tunnel. Commands are in
`carriers/openssl.txt` (ncat can do the same: `ncat -C --ssl host 443`):

```bash
openssl s_client -connect example.org:443 -quiet -crlf
```

- `-connect host:443` - which server, on the HTTPS port
- `-quiet` - hide the long certificate details
- `-crlf` - send line endings the way HTTP officially wants them
- quit with `Ctrl + C`

<br>
<br>
<br>

### 8.3 Warm-up: an old friend, encrypted

No new file needed. Connect to `example.org:443` as above, then paste
`messages/E403_get_example_200_internet.http` - exactly the same text you sent with telnet.

- **What happens:** the same `200 OK` and "Example Domain" page as in E403.
- **Lesson:** nothing in the request changed. Only the connection did.

<br>
<br>
<br>

### 8.4 E801_get_httpbin_200_https

<!-- include: messages/E801_get_httpbin_200_https.http -->
**The Carrier**

```bash
openssl s_client -connect httpbin.org:443 -quiet -crlf
```

<br>

**The Message**

```bash
GET /get HTTP/1.1
Host: httpbin.org
Accept: application/json
User-Agent: FileTest/1.0
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from openssl here)
```

- **What happens:** `200 OK`, and the JSON echo now says
  `"url": "https://httpbin.org/get"` - with an **s**.
- **Lesson:** the server knows the request came through the encrypted tunnel.

<br>
<br>
<br>

### 8.5 E802_get_githubApi_zen_200_https

<!-- include: messages/E802_get_githubApi_zen_200_https.http -->
**The Carrier**

```bash
openssl s_client -connect api.github.com:443 -quiet -crlf
```

<br>

**The Message**

```bash
GET /zen HTTP/1.1
Host: api.github.com
User-Agent: hello-http-learning (amitchaudhary82)
Accept: application/vnd.github+json
Connection: close

```
<!-- /include -->

<br>

**Response**

```bash
(paste the response from openssl here)
```

- **What happens:** `200 OK` and one short sentence of GitHub's design
  philosophy (a different one each time).
- **Lesson:** this is your first raw request to the **GitHub API** - the same
  API the GitHub_HTTP repo uses with R. Try removing the `User-Agent` line:
  GitHub refuses requests without one (`403`).

<br>
<br>
<br>

### 8.6 What you now know

| | telnet (chapters 3 to 7) | openssl (chapter 8) |
|---|---|---|
| Port | 80 | 443 |
| Encrypted | no | yes |
| Request text | you type it | you type it - identical |
| Who builds the tunnel | nobody | openssl |

Practice with tools: chapter 9.

<br>
<br>
<br>

## Chapter 9: Practice: Part 2 with Tools

> Chapter navigation: [Previous: Chapter 8](#chapter-8-concepts-https)
> · [Next: Chapter 10](#chapter-10-what-you-can-do-now)

The same idea as chapter 6, for the authentication and HTTPS Messages.

<br>
<br>
<br>

### 9.1 With RStudio (httr2)

```r
library(dplyr)                      # for the %>% pipe
source("rstudio/http_helpers.R")

req <-
  read_http_message_from_file("messages/E702_get_httpbin_bearerToken_200_internet.http") %>%
    prepare_request_from_http_message("httpbin.org", 80)

req_dry_run(req)
resp <- send_request_to_server(req)

req <-
  read_http_message_from_file("messages/E801_get_httpbin_200_https.http") %>%
    prepare_request_from_http_message("httpbin.org", 443, scheme = "https")

req_dry_run(req)
resp <- send_request_to_server(req)
```

- **Tokens:** E702 copies the dummy token from the file. For a real API, a
  token never goes into a file: store it once in `~/.Renviron`
  (`usethis::edit_r_environ()`, line `GITHUB_PAT=ghp_...`) and use
  `req_auth_bearer_token(Sys.getenv("GITHUB_PAT"))`.
- **HTTPS:** a `https://` URL is all it takes - httr2 builds the encrypted
  tunnel, nothing else changes.

Script with every experiment and a real GitHub call: `rstudio/practice_part2_auth_https.R`

<br>
<br>
<br>

### 9.2 With curl

```bash
source curl/http_to_curl.sh
http_to_curl messages/E801_get_httpbin_200_https.http
```

Script: `curl/practice_part2_auth_https.sh`

<br>
<br>
<br>

### 9.3 openssl for troubleshooting

You don't need openssl to use HTTPS - httr2 and curl handle it. It becomes
useful when HTTPS **fails**, typically at work, where networks inspect HTTPS
traffic. An error like

```bash
SSL certificate problem: unable to get local issuer certificate
```

means the encrypted tunnel failed - not your Message. Look at the
certificates the server (or the company proxy) presents:

```bash
openssl s_client -connect api.github.com:443 -showcerts
```

If the certificate comes from your company instead of the real server, ask
IT for the company certificate (CA) to trust. Never switch certificate
checks off.

<br>
<br>
<br>

### 9.4 What the tools change

| Experiments | Raw Carrier (openssl, ncat --ssl) | httr2 / curl |
|---|---|---|
| E701, E702 tokens | the token is typed into the Message | the token comes from the environment (`Sys.getenv`) |
| E801, E802 HTTPS | you open the encrypted tunnel yourself | just `https://` - encryption is invisible |

<br>
<br>
<br>


## Chapter 10: What you can do now

> Chapter navigation: [Previous: Chapter 9](#chapter-9-practice-part-2-with-tools)
> · [Next: Chapter 11](#chapter-11-other-files)

After these 44 experiments you have written every part of an HTTP request
yourself:

| Part | Learned in |
|---|---|
| Request line: method, path, version | E301, E305, E306 |
| All methods: GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS | 3.3, E507 - E511 |
| Paths, folders, redirects | E302 - E304, E307 - E309, E413 |
| Query strings | E405 - E408 |
| URL encoding | E311 - E314, E406 - E408 |
| Headers, Host, tokens | E301, E401, E409, E404, E315, E701, E702 |
| Response headers | E310 |
| Body, Content-Type, Content-Length, the empty line | E501 - E506 |
| Connections: close and keep-alive | E401, E502, E414 |
| HTTPS | E801, E802 |
| Status codes 200, 201, 204, 301, 302, 400, 401, 404, 405, 500, 501 | all |

**Success criteria**

- The status code matches the experiment name or table entry.
- The response type matches the lesson: a file, JSON data, a redirect,
  an error, or headers.
- The local server log shows the method and path you sent.
- For live-server experiments, differences in dates, headers, or body wording
  are acceptable when the status and HTTP behavior are correct.

...and you can send the same requests with curl and with R's httr2, knowing
exactly what they write for you. Further httr2 practice lives in the
[**GitHub_HTTP** repository](https://github.com/amitchaudhary82/GitHub_HTTP).


<br>
<br>
<br>


## Chapter 11: Other files

> Chapter navigation: [Previous: Chapter 10](#chapter-10-what-you-can-do-now)

| File | Content |
|---|---|
| `000_Syntax_NNN_method_scenario_status.txt` | file naming rule |
| `build_readme.sh` | copies the Message files into this README, numbers headings, builds the contents |
| `000_run_python_mini_server.txt` | command to start the local server |
| `messages/` | The Message: all 44 HTTP requests, the golden source |
| `carriers/telnet.txt`, `nc.txt`, `ncat.txt`, `openssl.txt` | The Carrier: connect commands |
| `rstudio/http_helpers.R` | shared R functions (defines only, sends nothing): `read_http_message_from_file()`, `split_http_message_into_parts()`, `send_raw_http_message_to_server()`, `prepare_request_from_parts()`, `prepare_request_from_http_message()`, `send_request_to_server()` |
| `rstudio/practice_part1_basics.R` | chapter 6: every Part 1 Message with httr2, plus a for loop over all |
| `rstudio/practice_part2_auth_https.R` | chapter 9: authentication and HTTPS Messages with httr2, plus a real GitHub call |
| `curl/http_to_curl.sh` | shared function: turns a Message file into a curl command |
| `curl/practice_part1_basics.sh` | chapter 6: every Part 1 Message with curl |
| `curl/practice_part2_auth_https.sh` | chapter 9: authentication and HTTPS Messages with curl |
| `validate_readme.py` | offline check for request includes, experiment IDs and image links |
| `http_mini_server_root/` | files served by the local server (incl. tricky names) |
| `http_mini_server_root/Info_Encoding_Characters.txt` | notes on URL structure and special characters |

### 11.1 Maintaining this README

The Message files in `messages/` are the source of truth for request
snippets. Do not edit those snippets directly in this README.

After changing a request file or heading, run the maintainer script from the
repository folder:

```bash
bash build_readme.sh
./validate_readme.py
git diff --stat README.md
git diff README.md
```

The script:

- Replaces the README snippets between `<!-- include: -->` markers with the
  current request files
- Rebuilds the table of contents
- Numbers Chapter and section headings consistently

The offline validator checks that request snippets and image references still
point to existing files, and that experiment IDs remain unique.
