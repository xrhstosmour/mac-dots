#!/usr/bin/env python3
"""Validate a sitemap XML file or stdin against Google's sitemap rules.

Usage:
    check_sitemap.py <path/to/sitemap.xml>
    curl -s "$URL/sitemap.xml" | check_sitemap.py

Makes no network calls. Reads already-fetched XML and reports URL/size
caps, invalid <lastmod> values, and informational-only deprecated tags.
Exit code is 0 always; check the printed report for issues.
"""

from __future__ import annotations

import sys
from datetime import datetime, timezone
from typing import Any
from xml.etree import ElementTree

URL_CAP = 50_000
NEWS_CAP = 1_000
SIZE_CAP_BYTES = 50 * 1024 * 1024


def read_input() -> bytes | Any:
    if len(sys.argv) > 1:
        with open(sys.argv[1], "rb") as handle:
            return handle.read()
    return sys.stdin.buffer.read()


def strip_namespace(tag) -> Any:
    return tag.rsplit("}", 1)[-1] if "}" in tag else tag


def is_valid_lastmod(value) -> bool:
    cleaned = value.strip()
    if cleaned.endswith("Z"):
        cleaned = cleaned[:-1] + "+00:00"
    try:
        datetime.fromisoformat(cleaned)
        return True
    except ValueError:
        pass
    for date_format in ("%Y-%m", "%Y"):
        try:
            datetime.strptime(cleaned, date_format).replace(tzinfo=timezone.utc)
            return True
        except ValueError:
            continue
    return False


def check_caps(count, size_bytes, cap, label) -> None:
    if count > cap:
        print(f"  ISSUE: {count} entries exceeds the {cap:,}-entry cap for a {label} — split with a sitemap index.")
    if size_bytes > SIZE_CAP_BYTES:
        print(f"  ISSUE: {size_bytes:,} bytes exceeds the 50MB uncompressed cap — split with a sitemap index.")


def main() -> None:
    raw = read_input()
    size_bytes = len(raw)

    if not raw.strip():
        print("ISSUE: empty input — the fetch that produced this likely failed before reaching the sitemap.")
        return

    try:
        root = ElementTree.fromstring(raw)
    except ElementTree.ParseError as error:
        print(f"ISSUE: invalid XML — {error}")
        return

    root_tag = strip_namespace(root.tag)
    children = list(root)
    has_news = any("news" in strip_namespace(child.tag) for child in root.iter())

    if root_tag == "sitemapindex":
        entries = [child for child in children if strip_namespace(child.tag) == "sitemap"]
        print(f"Type: sitemap index, {len(entries)} child sitemap(s) referenced, {size_bytes:,} bytes.")
        check_caps(len(entries), size_bytes, NEWS_CAP if has_news else URL_CAP, "sitemap index")
        for entry in entries:
            loc = entry.find("./{*}loc")
            lastmod = entry.find("./{*}lastmod")
            if loc is None:
                print("  ISSUE: <sitemap> entry missing required <loc>")
                continue
            if lastmod is not None and lastmod.text and not is_valid_lastmod(lastmod.text):
                print(f"  ISSUE: invalid <lastmod> {lastmod.text!r} for {loc.text}")
        return

    if root_tag != "urlset":
        print(f"ISSUE: unrecognized root element <{root_tag}> — expected <urlset> or <sitemapindex>.")
        return

    url_entries = [child for child in children if strip_namespace(child.tag) == "url"]
    cap = NEWS_CAP if has_news else URL_CAP
    label = "news sitemap" if has_news else "sitemap"

    print(f"Type: {label}, {len(url_entries)} <url> entries, {size_bytes:,} bytes.")
    check_caps(len(url_entries), size_bytes, cap, label)

    lastmod_values = []
    deprecated_tag_hits = set()
    for entry in url_entries:
        loc = entry.find("./{*}loc")
        if loc is None:
            print("  ISSUE: <url> entry missing required <loc>")
            continue
        for child in entry:
            tag = strip_namespace(child.tag)
            if tag == "lastmod" and child.text:
                lastmod_values.append(child.text)
                if not is_valid_lastmod(child.text):
                    print(f"  ISSUE: invalid <lastmod> {child.text!r} for {loc.text}")
            elif tag in ("priority", "changefreq"):
                deprecated_tag_hits.add(tag)

    if lastmod_values and len(set(lastmod_values)) == 1 and len(lastmod_values) > 1:
        print(f"  INFO: every <lastmod> is identical ({lastmod_values[0]!r}) — Google only trusts "
              "lastmod when it reflects real per-page content changes.")

    for tag in sorted(deprecated_tag_hits):
        print(f"  INFO: <{tag}> is present but ignored by Google — safe to remove, not worth fixing urgently.")


if __name__ == "__main__":
    main()
