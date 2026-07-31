---
name: implement-design-from-export
description: Use when the user hands off a design export, HTML/CSS, or screenshot from an AI design tool and asks to build or match it in the project.
---

# Implement Design from Export

## When to use

- User pastes/attaches a design export, HTML/CSS or screenshot, and asks to build matching UI.
- User saved a design export to a file and asks you to build from it.
- Not for writing a new design prompt before design, see the `craft-design-prompt` skill for that.

The user designs in an AI design tool themselves, then hands the result to the agent one of these ways:

- Pastes the exported HTML/CSS directly into the chat.
- Saves the exported HTML to a file in the repo and tells the agent which path to read.
- Attaches/pastes a screenshot of the design and asks the agent to build UI to match it visually.

Do not ask the user to authenticate, generate an API key, or set up any credential for this, there's nothing to configure.

Design exports are static layouts. Hover states, animations, validation, and state management are not part of the export and need to be implemented separately.

Design tool exports often use `Tailwind` utility classes by default. If the project doesn't already use `Tailwind`, translate the export to the project's actual styling approach, don't introduce `Tailwind` as a new dependency just because the pasted HTML happens to use it.
