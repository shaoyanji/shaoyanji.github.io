#!/usr/bin/env python3

from __future__ import annotations

import argparse
import pathlib
import re
import socket
import sys
import urllib.error
import urllib.parse
import urllib.request


POSTS_DIR = pathlib.Path("_posts")
FRONT_MATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.S)
MARKDOWN_LINK_RE = re.compile(r"!\[[^\]]*\]\((https?://[^)\s]+)\)|\[[^\]]+\]\((https?://[^)\s]+)\)")
FRONT_MATTER_URL_RE = re.compile(r"^\s*(?:path|url):\s*(https?://\S+)\s*$", re.M)
DEFAULT_TIMEOUT = 10
USER_AGENT = "shaoyanji.github.io external ref audit"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit external links and image hosts referenced by blog posts."
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=DEFAULT_TIMEOUT,
        help=f"Request timeout in seconds (default: {DEFAULT_TIMEOUT})",
    )
    parser.add_argument(
        "--images-only",
        action="store_true",
        help="Only audit image references from front matter and markdown image syntax.",
    )
    return parser.parse_args()


def load_external_refs(images_only: bool) -> dict[str, set[str]]:
    refs: dict[str, set[str]] = {}

    for post in sorted(POSTS_DIR.glob("*.md")):
      text = post.read_text(encoding="utf-8")
      front_matter_match = FRONT_MATTER_RE.search(text)
      if front_matter_match:
          front_matter = front_matter_match.group(1)
          for url in FRONT_MATTER_URL_RE.findall(front_matter):
              refs.setdefault(url, set()).add(post.name)

      for image_url, link_url in MARKDOWN_LINK_RE.findall(text):
          url = image_url or link_url
          if images_only and not image_url:
              continue
          refs.setdefault(url, set()).add(post.name)

    return refs


def build_request(url: str, method: str) -> urllib.request.Request:
    return urllib.request.Request(
        url,
        headers={"User-Agent": USER_AGENT},
        method=method,
    )


def check_url(url: str, timeout: int) -> tuple[bool, str]:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme not in {"http", "https"}:
        return False, f"unsupported scheme: {parsed.scheme or '<missing>'}"

    try:
        with urllib.request.urlopen(build_request(url, "HEAD"), timeout=timeout) as response:
            status = getattr(response, "status", 200)
            if 200 <= status < 400:
                return True, f"HEAD {status}"
            return False, f"HEAD {status}"
    except urllib.error.HTTPError as exc:
        if exc.code in {405, 403}:
            try:
                with urllib.request.urlopen(build_request(url, "GET"), timeout=timeout) as response:
                    status = getattr(response, "status", 200)
                    if 200 <= status < 400:
                        return True, f"GET {status} after HEAD {exc.code}"
                    return False, f"GET {status} after HEAD {exc.code}"
            except Exception as get_exc:  # noqa: BLE001
                return False, f"HEAD {exc.code}, GET failed: {format_error(get_exc)}"

        return False, f"HTTP {exc.code}"
    except Exception as exc:  # noqa: BLE001
        return False, format_error(exc)


def format_error(exc: Exception) -> str:
    if isinstance(exc, urllib.error.URLError):
        reason = exc.reason
        if isinstance(reason, socket.timeout):
            return "timeout"
        return f"url error: {reason}"
    if isinstance(exc, socket.timeout):
        return "timeout"
    return exc.__class__.__name__


def main() -> int:
    args = parse_args()
    refs = load_external_refs(images_only=args.images_only)

    if not refs:
        print("No external references found.")
        return 0

    failures: list[tuple[str, str, list[str]]] = []
    successes = 0

    for url in sorted(refs):
        ok, status = check_url(url, timeout=args.timeout)
        sources = sorted(refs[url])
        if ok:
            successes += 1
            print(f"OK   {status:>18}  {url}")
        else:
            failures.append((url, status, sources))
            print(f"FAIL {status:>18}  {url}")

    print()
    print(f"Checked {len(refs)} external references: {successes} OK, {len(failures)} failed")

    if failures:
        print()
        print("Failures:")
        for url, status, sources in failures:
            print(f"- {url}")
            print(f"  status: {status}")
            print(f"  referenced by: {', '.join(sources)}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
