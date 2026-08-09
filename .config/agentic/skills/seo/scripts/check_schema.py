#!/usr/bin/env python3
"""Validate JSON-LD structured data extracted from an HTML file or stdin.

Usage:
    check_schema.py <path/to/page.html>
    curl -s "$URL" -o page.html && check_schema.py page.html

Makes no network calls. Reads already-fetched HTML and reports parse
errors, relative URLs, and deprecated/no-rich-result schema.org types.
Exit code is 0 always; check the printed report for issues.
"""

from __future__ import annotations

import json
import re
import sys
from typing import Any

DEPRECATED_TYPES = {
    "HowTo": "Rich results removed September 2023.",
    "SpecialAnnouncement": "Deprecated July 2025 (COVID-era schema).",
    "ClaimReview": "Retired from rich results June 2025.",
    "VehicleListing": "Retired from rich results June 2025.",
}

# Valid schema.org types with no Google rich result, info-level only, not invalid markup.
NO_RICH_RESULT_TYPES = {
    "FAQPage": "No Google rich result outside a small set of authoritative sites since August 2023; use QAPage for genuine user Q&A instead.",
}

URL_FIELDS = {"url", "logo", "image", "sameAs", "contentUrl", "thumbnailUrl"}

SCRIPT_PATTERN = re.compile(
    r'<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
    re.IGNORECASE | re.DOTALL,
)


def read_input() -> str | Any:
    if len(sys.argv) > 1:
        with open(sys.argv[1], "r", encoding="utf-8", errors="replace") as handle:
            return handle.read()
    return sys.stdin.read()


def find_relative_urls(value, path="") -> list[Any]:
    findings = []
    if isinstance(value, dict):
        for key, sub_value in value.items():
            findings.extend(find_relative_urls(sub_value, f"{path}.{key}" if path else key))
    elif isinstance(value, list):
        for index, item in enumerate(value):
            findings.extend(find_relative_urls(item, f"{path}[{index}]"))
    elif isinstance(value, str):
        field_name = path.rsplit(".", 1)[-1].split("[")[0]
        if field_name in URL_FIELDS and value and not re.match(r"^https?://", value):
            findings.append((path, value))
    return findings


def has_standard_context(context) -> bool:
    values = context if isinstance(context, list) else [context]
    for value in values:
        if isinstance(value, str) and value.rstrip("/") in ("https://schema.org", "http://schema.org"):
            return True
        if isinstance(value, dict) and value.get("@vocab", "").rstrip("/") in (
            "https://schema.org",
            "http://schema.org",
        ):
            return True
    return False


def check_entry(entry, index, issues, infos, inherited_context=None) -> None:
    if not isinstance(entry, dict):
        issues.append(f"Block {index}: top-level entry is not an object")
        return

    context = entry.get("@context", inherited_context)

    if "@graph" in entry:
        for sub_entry in entry["@graph"]:
            check_entry(sub_entry, index, issues, infos, inherited_context=context)
        return

    if not has_standard_context(context):
        issues.append(f"Block {index}: missing or non-standard @context ({context!r})")

    schema_type = entry.get("@type")
    if not schema_type:
        issues.append(f"Block {index}: missing @type")
    else:
        types = schema_type if isinstance(schema_type, list) else [schema_type]
        for type_name in types:
            if type_name in DEPRECATED_TYPES:
                issues.append(f"Block {index}: deprecated type {type_name!r} — {DEPRECATED_TYPES[type_name]}")
            elif type_name in NO_RICH_RESULT_TYPES:
                infos.append(f"Block {index}: {type_name!r} — {NO_RICH_RESULT_TYPES[type_name]}")

    for field_path, value in find_relative_urls(entry):
        issues.append(f"Block {index}: relative URL in {field_path!r}: {value!r}")


def check_block(raw_text, index) -> tuple[list[str], list[Any]] | tuple[list[Any], list[Any]]:
    try:
        data = json.loads(raw_text)
    except json.JSONDecodeError as error:
        return [f"Block {index}: invalid JSON — {error.msg} at line {error.lineno}, column {error.colno}"], []

    issues = []
    infos = []
    entries = data if isinstance(data, list) else [data]
    for entry in entries:
        check_entry(entry, index, issues, infos)

    return issues, infos


def main() -> None:
    html = read_input()
    blocks = SCRIPT_PATTERN.findall(html)

    if not blocks:
        print("No JSON-LD (<script type=\"application/ld+json\">) blocks found.")
        print("Check for Microdata (itemscope/itemprop) or RDFa as a fallback, "
              "and recommend migrating to JSON-LD if either is present.")
        return

    print(f"Found {len(blocks)} JSON-LD block(s).\n")
    total_issues = 0
    for index, raw_text in enumerate(blocks, start=1):
        issues, infos = check_block(raw_text.strip(), index)
        total_issues += len(issues)
        for issue in issues:
            print(f"  ISSUE: {issue}")
        for info in infos:
            print(f"  INFO: {info}")
        if not issues and not infos:
            print(f"  Block {index}: OK")

    print(f"\n{total_issues} issue(s) across {len(blocks)} block(s).")


if __name__ == "__main__":
    main()
