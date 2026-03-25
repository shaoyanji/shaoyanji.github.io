---
layout: post
title: Psst, Nix and blogging
date: 2025-06-29
description: A mid-year check-in on Jekyll, Hugo, and lighter static site workflows after time away from blogging.
categories: [Blog/Comparison]
tags: [technology, risk, analysis]
image:
  path: https://envs.sh/uwm.jpg
  alt: wrestle match between the different blogging engines
---

This is my new draft.

It is written in markdown using the [Jekyll](https://jekyllrb.com/) static site generator.

The source code is a little bloaty for a blog because it isn't yet fully declarative in a nix file for a devenv.

I am considering moving my blog to [Hugo](https://gohugo.io/) but I'm not sure if I want to do that yet. The theme I am currently looking at is https://github.com/CaiJimmy/hugo-theme-stack-starter. It has a similar look and feel of chirpy.

My dotfiles for codespace and raspberry pi is located in my dotfiles git repo that I have privated. But I think I can open it up one day as it shows a method on making security work.

## Update: June 29, 2025

It's been half a year and this github blog hasn't inspired me to write. There's an overhead to remembering that set of commands to initiate the tooling and the static site generation. :

```bash
gem install bundle && bundle install && bundle && bundle exec jekyll serve --incremental
```

As much as I'd like to fight this nightmare, I have implemented a light touch to dependency management in the form of nix and nix shell. But I haven't gotten around to managing all of machines in the perfect combination of flakes/non-flake, Pi on NixOS to make this repo a seamless experience.

## Experimenting with a new static site generator stack

The more I look at this nasty Jekyll framework, the more I prefer minimalism and using cmark to generate the static site from markdown directly using some parlor tricks with taskrunner builds.

It's definitely not perfect, but I do believe that it would give me some control. But although, I would miss out on some functionality and niceties like Math Latex built-ins.

## Comparing the approaches

|            | Obsidian | Jekyll | Hugo | Raw |
| ---------- | -------- | ------ | ---- | --- |
| Markdown   | x        | x      | x    | x   |
| Math       | x        | x      |      |     |
| Speed      | x        |        | x    | x   |
| Aesthetics | x        | x      | x    |     |
| Publish    |          | x      | x    | x   |
| GH-integ   |          | x      |      |     |

## Jekyll is probably worth keeping for more high quality posts

But one probably has to design some kind of funnel system that let's high quality notes percolate upwards to even be recognized for a post of some merit.

This is why I am trying to integrate my stack to be close to the bone with the knowledge base so a steady stream of drafts can appear and inspire me to write and finish the idea.

## CITY STACK or [CMD STACK](https://github.com/shaoyanji/cmdstack)

The idea here is to use purely lightweight cli tools to compose the html and verify for publish in an extreme minimalism sort of way. That way it isn't necessary to install dependencies and writing can be more of aa fluid thing in markdown. I still need to look into obsidian-export from [cli.club](https://cli.club)

But that's all for now. I am posting this unfinished draft because I'm quite frustrated in waiting for another `gem install bundle` command.
