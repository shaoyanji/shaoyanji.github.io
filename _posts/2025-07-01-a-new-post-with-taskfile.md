---
layout: post
title: A Taskfile-Powered Blog Engine
date: 2025-07-01
description: Many people look at the framework as the fulcrum of the blog. I believe that its the tooling that makes a blog both fun to read and write 
author: matt
categories: [Blogging]
tags: [energy, risk, cybersecurity, technology]
pin: false
toc: true
comments: false
math: false
mermaid: false
image:
  path: https://envs.sh/uLG.jpg
  alt: king arthur pulling the sword from the anvil
---

## A way to integrate Taskfile with Jekyll without dependencies on local system

## local developement jsut requires tooling

### Taskfile

Taskfile is a task runner / build tool that aims to be simpler to use than Make, Rake, or Gulp.

source: [taskfile.dev](https://taskfile.dev)

So far I have came up with two somewhat useful commands:

```console
task mdimg -- "the prompt for image generation"
task post -- "the prompt for a new post"
```

And so far I haven't made it a template AI generated blog yet, but something simple like generating the date in the filename and maybe later chain it and then move onto the editor.

```console
date +%Y-%m-%d
```

### Neovim
Normally vim doesn't do a graceful job at inserting stdout text and requires some macros to format the text from terminal stdout. I have discovered this little gem.

```console
  :redir @a
  :!task mdimg -- "the prompt for image generation" 
  :redir END
  :0put =@a
```
As discussed in my [previous post](https://shaoyanji.github.io/posts/scripts-for-ai-slop-blog-machine/), I have been using this to generate images for my blog posts as I write.

![vim blogging ultimate manual](https://envs.sh/uLL.jpg)

## To Do

- [ ] Add a template for AI generated blog posts
- [ ] Add a template for AI generated blog post images / Perhaps a gum TUI/form
- [ ] Add a yaml header to the blog post. Jekyll has a very nice way of doing this with front matter. But much of it can be streamlined without installing `ruby` `gem` `bundler` on a native mint system. a 17 MB `task` can handle pretty much all of this.
