---
layout: post
title: Is this the last post for this blog?
date: '2024-11-13 09:51:38 +0000'
description: A reflection on Jekyll friction, Nix-based workflows, and whether this blog should stay on its current stack.
categories: [Blog/Comparison]
tags: [technology, risk, analysis]
image:
  path: https://envs.sh/uP8.jpg
  alt: nixos blogging away
---

Ever since switching to Nix, I've learned a lot about declarative workflow and I love Nix. The big trade-off has been that declarative functional programmign workflow is pretty hard and requires a lot of effort. But the benefits are that things just simply work when it comes to dependency management and state management.

But now when it comes to writing blog posts, there is a nitpicky hurdle and that is dependency amanagement with Ruby and Gem. I am not sure I want to convert everything over to nix to get a full declarative ephemeral workspace and system.

I'm alos a little careful about polluting my new current install of Asahi Linux because it is on Fedora and now I have to handle some system dependencies from an upstream distro that resolves some of the MacOS aarch64 bugs that are undoubtedly there.

In the spirit of experimenting with new software and a new workflow, the benefits of running Linux on Apple Silicon can be potentially quite big given energy efficiency and single core performance. I may even try Rust so I can compile and manage remotely my Raspberry Pi.

But all in all, this could be the last post for this blog as I may migrate over to Hugo and jsut relink everything. The idea behind this is documentation in hacking has been a universal pain point for developers. I am trying an approach where I can stream line notes from the upstream via obsidian into blog posts with the use of some menu tools that I coalesced together using yq and gum. I am hopeful that these experiments allows me come out of nowhere and build a really cool app with a successful workflow implementation.

We kind of live in a dotfile world now where the people on the frontiers of knowledge are the ones writing and the others are following along. Because things are happening so quickly, blogs might not be the best medium for things.

To just wrap up, I want to share a few things on getting Nix to work nicely with Asahi Fedora. I used determinate installer https://determinate.systems/posts/determinate-nix-installer/. For reasons as to why, the main one is that flakes comes unlocked out of the box along with some sensible defaults in the /etc/nix/nix.conf file. Next, I ran:

```bash
nix run home-manager/master -- init --switch
```

This will install home-manager but here I ran into a few problems. The next instance of shell that I opened didn't have any of the profiles loaded and I diagnosed the origin of the problem by looking into /etc/profile and /etc/bashrc. It seems like Fedora default bashrc and profiles do not like using nix as a default distro and it's probably one of the downsides to using determinate installer whereas the default [NixOS](https://nixos.org/) installer tries to append a line in /etc/bashrc that loads nix-profile. But maybe it was just because I didn't set a channel. Anywho, I wrote a few home environment variables to initialize the hm script and an extra bash config if statement for this particular machine. It's a really ugly implementation of this in my nixconfig but the idea is that I want this repo [My Nixconfig](https://github.com/shaoyanji/nixconfig) to kind of demo a personal, live multi-host config that is open-source, manages secrets and displays the shell.nix and tooling needed for fast navigation through 100k packages. I think a familiarity with the nix ecosystem is invaluable because it allows any architecture or system to overcome some of the limitations of their repos lack of packages, something I went through when trying to set up a desktop environment on my raspberry pi on Arch.

![nixos on a computer](https://envs.sh/uwE.jpg)
If you have any questions or comments, please feel free to reach out to me on Twitter or Discord.
