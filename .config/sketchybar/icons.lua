-- SF Symbols, rendered by `SF Pro` (provisioned as `font-sf-pro` in
-- `packages/Brewfile`). These are the same glyphs macOS uses for its own
-- menu bar, so the bar reads as native rather than as a Nerd Font pastiche.
--
-- The only exception is Bluetooth: SF Symbols has no Bluetooth glyph, so that
-- one item falls back to a Nerd Font codepoint and sets its own icon font
-- (`FiraCode Nerd Font`, already provisioned).
return {
  apple = "􀣺",
  gear = "􀍟",
  calendar = "􀉉",
  cpu = "􀫥",
  memory = "􀫦",
  camera = "􀌞",
  chevron_left = "􀆉",
  chevron_right = "􀆊",
  ellipsis = "􀍠",
  reveal = "􀆊",

  -- Plain Unicode, always renders regardless of font.
  divider = "│",

  volume = {
    _100 = "􀊩",
    _66 = "􀊧",
    _33 = "􀊥",
    _10 = "􀊡",
    _0 = "􀊣",
  },
  mic = {
    on = "􀊰",
    off = "􀊲",
  },
  -- Nerd Font, see the note above.
  bluetooth = {
    on = "󰂱",
    off = "󰂲",
  },
  wifi = {
    connected = "􀙇",
    disconnected = "􀙈",
  },
  media = {
    back = "􀊊",
    play = "􀊄",
    pause = "􀊆",
    forward = "􀊌",
  },
}
