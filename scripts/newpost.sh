#!/usr/bin/env bash

set -euo pipefail

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

yaml_quote() {
  printf "%s" "$1" | sed "s/'/''/g"
}

slugify() {
  printf "%s" "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

write_yaml_list() {
  local key="$1"
  local raw="$2"
  local line

  printf "%s:\n" "$key"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf "  - '%s'\n" "$(yaml_quote "$line")"
  done < <(
    printf "%s" "$raw" \
      | tr ',' '\n' \
      | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
      | sed '/^$/d'
  )
}

bool_prompt() {
  local label="$1"
  local default="$2"
  local first second

  if [ "$default" = "true" ]; then
    first="true"
    second="false"
  else
    first="false"
    second="true"
  fi

  printf "%s" "$(gum choose --header "$label" "$first" "$second")"
}

build_query() {
  cat <<EOF
Create a markdown ${MODE} for a Jekyll blog post.

Title: ${TITLE}
Description: ${DESCRIPTION}
Categories: ${CATEGORIES}
Tags: ${TAGS}
What the post is about:
${TOPIC}

Return only markdown for the post body.
Do not include YAML front matter.
If mode is scaffold, provide a strong opening, a clear section structure, and starter paragraphs.
If mode is summary, provide a concise summary followed by a minimal outline.
Keep the style grounded and technically literate.
EOF
}

require_cmd gum
require_cmd tgpt

TITLE="$(gum input --prompt "Title> " --placeholder "A sharp working title")"
[ -n "$TITLE" ] || {
  echo "title is required" >&2
  exit 1
}

TOPIC="$(gum write --prompt "What is the post about? > " --placeholder "Describe the idea, angle, and anything you want the draft to emphasize.")"
[ -n "$TOPIC" ] || {
  echo "post topic is required" >&2
  exit 1
}

MODE="$(gum choose --header "AI output mode" "scaffold" "summary")"
DESCRIPTION="$(gum input --prompt "Description> " --placeholder "One-line SEO/social description")"
CATEGORIES="$(gum input --prompt "Categories> " --value "Blog" --placeholder "Comma-separated")"
TAGS="$(gum input --prompt "Tags> " --value "technology" --placeholder "Comma-separated")"
IMAGE_PATH="$(gum input --prompt "Image path> " --placeholder "https://... or /assets/...")"
IMAGE_ALT="$(gum input --prompt "Image alt> " --placeholder "Optional alt text")"
PIN="$(bool_prompt "Pin this post?" "false")"
TOC="$(bool_prompt "Show table of contents?" "true")"
COMMENTS="$(bool_prompt "Enable comments?" "false")"
MATH="$(bool_prompt "Enable math?" "false")"
MERMAID="$(bool_prompt "Enable mermaid?" "false")"

DATE_STAMP="$(date '+%Y-%m-%d')"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %z')"
SLUG="$(slugify "$TITLE")"
FILE="_posts/${DATE_STAMP}-${SLUG}.md"

if [ -e "$FILE" ]; then
  echo "$FILE already exists" >&2
  exit 1
fi

QUERY="$(build_query)"
BODY="$(tgpt --provider sky -q "$QUERY")"

{
  printf "%s\n" "---"
  printf "%s\n" "layout: post"
  printf "title: '%s'\n" "$(yaml_quote "$TITLE")"
  printf "%s\n" "date: ${TIMESTAMP}"
  printf "description: '%s'\n" "$(yaml_quote "$DESCRIPTION")"
  printf "%s\n" "author: matt"
  write_yaml_list "categories" "$CATEGORIES"
  write_yaml_list "tags" "$TAGS"
  printf "%s\n" "pin: ${PIN}"
  printf "%s\n" "toc: ${TOC}"
  printf "%s\n" "comments: ${COMMENTS}"
  printf "%s\n" "math: ${MATH}"
  printf "%s\n" "mermaid: ${MERMAID}"
  printf "%s\n" "image:"
  printf "  path: '%s'\n" "$(yaml_quote "$IMAGE_PATH")"
  printf "  alt: '%s'\n" "$(yaml_quote "$IMAGE_ALT")"
  printf "%s\n\n" "---"
  printf "<!-- Generated with task newpost (%s mode) -->\n\n" "$MODE"
  printf "%s\n" "$BODY"
} > "$FILE"

echo "Created $FILE"

if [ -n "${EDITOR:-}" ]; then
  if gum confirm "Open in \$EDITOR?"; then
    "$EDITOR" "$FILE"
  fi
fi
