---
layout: post
title: Scripts and Blogging Engines for an AI Slop Universe
date: 2025-06-30
description: blogging with the common observed energy stacks are about to be as outdated as 70s style terminals but there is some lessons to be learned about automation
author: matt
categories: [Blogging]
tags: [energy, cybersecurity, technology]
pin: true
toc: true
comments: false
math: true
mermaid: true
image:
  path: https://envs.sh/uw0.jpg
  alt: a sexy devil on a computer
---

## AI Slop Content Management

On the one hand, having more content than not is a wonderful problem to have. It means not having to pay for a division of labor artist or content creator. You can be responsible and gain technological leverage.

For many, a blog is a way to massage the brain tissue and get the wrinkles to work.

But often when writing we are faced with being inspired as well as writing inspiration on the page or typing onto a screen.
Often, images are a way to do both in the input ouput pipeline.

However, as soon as you stop writing and go the browser to google images you would like to put on this blurb section. BOOM! hours fly by and you find Yourself in an imgur rabbit-hole.
Perhaps AI slop can serve a purpose for writing drafts and later in post-production you can replace the cheap photos with something a little more tasteful...or not? It's a blog, you only get 2 or three visitors a year, and if lucky monthly?

I'll show you a few scripts I use to auto-generate images while in the terminal so you are never distracted from writing while at the same time carefully balancingbetween the pixels of text and visuals.

Dependencies: [`task`](https://taskfile.dev/) and [`tgpt`](https://github.com/aandrew-me/tgpt) and most importantly `curl` but it is assumed to be installed.

Step 1: Copy the following text and save it as a `Taskfile.yml` into any folder

```yaml
version: "3"
tasks:
  mdimg:
    cmds:
      - echo -n '![{{.CLI_ARGS}}]('$(task awkimg -- {{.CLI_ARGS}})')'
    silent: true
  awkimg:
    cmds:
      - curl --no-progress-meter -F"file=@$(tgpt --img --height 630 --width 1200 "{{.CLI_ARGS}}"| awk '{match($0, /Saved image as ([^ ]+\.jpg)/, arr);  if (arr[1] != "") {print arr[1]} }')" https://envs.sh
    silent: true
```

When you are at the folder you just need to write the command in terminal to transcribe a prompt into a markdown flavor of an image.

```sh
task mdimg -- "<your brilliantly crafted word soup to craft the perfect AI image here>"
```

## Great for Accessibility

And sure enough, you get the markdown with your prompt as alt text. Pretty neat and great for accessibility since most of the time web devs tend to slack on the alt text quite a bit.

## Great for ergonomics

We all have a our vibe coding copy and paste machines, but these tools are often not well integrated into our work flow. But surely enough, with vim/neovim, you can run terminal commands in the editor with `:!task mdimg -- <magic!>`

It certainly beats opening up a browser and copy and pasting manually. Whether you are writing in obsidian notes, or in the terminal, this workflow will help with how you process ideas and craft them in eyecandy to gouge out the minds of your readers.

What's more, this little task file or snippet can work near universally for your blog engine,your new html framework renderer,a website or a Github documentation.

The dependencies are even easily installabe on windows with `scoop install tgpt go-task`

And yes, this is still a distraction and slop:
![female devil lucifer sexy creating computers with a boulder witch lady](https://envs.sh/uwR.jpg)
But it is quite nifty. And believe it or not. This might be a blog post that I will come back to again and again to copy and paste this generator of pixels from pixels of txt.
