# shaoyanji.github.io

Source for a Jekyll blog built on the Chirpy theme.

## Workflow

The canonical local environment is `devenv`, loaded automatically through `direnv`.

```bash
direnv allow
task serve
```

If you do not use `direnv`, run `devenv shell` manually before using the task commands.

## Common Tasks

```bash
task serve
task build
task newpost
task post -- "My New Post"
task audit-external
```

`task post` creates a new file in `_posts/` with the repo's standard front matter.
`task newpost` uses `gum` for prompts and `tgpt --provider sky` to draft a scaffold from your topic.

## Structure

- `_config.yml`: site identity, Chirpy settings, defaults, archives
- `_posts/`: blog posts
- `_tabs/`: top-level navigation pages
- `_data/`: authors, contact links, sharing config
- `_plugins/`: local Jekyll hooks
- `.github/workflows/pages-deploy.yml`: GitHub Pages build and deploy

## Notes

- Post `last_modified_at` is populated from git history by `_plugins/posts-lastmod-hook.rb`.
- `shell.nix` is kept as a fallback shell. `devenv` is the primary workflow.
- Deploy CI intentionally skips external URL checks so publishing stays reliable. Use `task audit-external` or the external audit workflow to catch broken third-party links and image hosts.
- `task newpost` requires `tgpt` to be available on `PATH`.
