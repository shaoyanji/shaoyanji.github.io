---
layout: post
title: How to get a free Go web server
date: 2025-06-30
description: Notes on using free hosting services to run a small Go web server and serve lightweight apps.
categories: [Blog/Comparison]
tags: [technology, analysis, Go]
image:
  path: https://envs.sh/ubd.jpg
  alt: A fantasy tree because tree rhymes with free
---

# Best things in life are free

I am a sucker for signing up for free things. Many lists of services that give me endless distraction. Here's one of the lists: [free-for.dev](https://free-for.dev/#/?id=web-hosting). I've checked out [Alwaysdata](https://www.alwaysdata.com/) and [Serv00.com](https://serv00.com/). Today, I'll be mostly talking about the latter.

## Serving Wasm where it couldn't be served

One of the things that I have been experimenting on is using static sites with wasm modules to do quite dynamic things with using `math.js`. My repo, [kelly-wasm](https://shaoyanji.github.io/kelly-wasm), for example, is a simple app that calculates the kelly fraction from probability and reward-risk ratio.

However, I've notice that not all php static servers treat the wasm MIME type equally. Only alwaysdata does this and it does so with octet stream on the wasm type.

Alright so here's where I looked to hack the server to do something other than `php` and `django`. In the terminal, you will find that there is a python cli program called `devil` that helps you manage the environment.

## netcat test

```console
$ which nc
```

This should work but if it doesn't you may need to activate binary execution using the `devil` cli tool.

```console
$ devil vhost port add tcp <random>
$ nc -l <random port>
```

Go to the browser or curl the address with the port number like this `http://<your username>.serv00.net:<random port>` and you get a connection.

If you give a proper HTTP respose header, something like this should give a `hello world` response:

```console
HTTP/1.1 200 OK
  MIME-Version: 1.0
  Server: Edited out
  Content-length: 13

hello world
```

Surely enough, if a simple netcat response works then we can implement a server running a light weight go http server for dev purposes.

## Go serving WASM

```console
git clone https://github.com/shaoyanji/kelly-wasm.git
cd kelly-wasm.git
make serve
```

![image of a hacker man](https://envs.sh/uPW.jpg)
If it doesn work, then editing the `server.go` and replacing the port to the opened port you have opened should do the trick.

And there you have it. Hacking a free server to run portable ephemeral dynamic server. I am not sure how well this would work unattended even a production grade web app because processes can be killed by a daemon. But since this server isn't some docker container, this capability to run customized server content can be a boon to whatever projects you are trying to hack up.

Granted, it's probably not that impressive since you can test locally. But when you are on the go and developing from an ipad or phone, it's not a terrible to ssh via termux or terminus/ish to the server to test in a semi-live prod environment.
