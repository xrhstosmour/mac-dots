-- Nerd Font glyphs (Fira Code Nerd Font is already provisioned by
-- `packages/Brewfile`), so no extra font cask is needed for icons. Codepoints
-- below are verified against a real published Nerd Font icons table, except
-- where noted as plain standard Unicode (no icon font needed for those).
return {
  apple = "",
  gear = "",
  calendar = "󰃭",
  cpu = "󰻠",
  memory = "󰍛",
  camera = "󰄀",

  -- Plain Unicode, always renders regardless of font.
  chevron_left = "‹",
  chevron_right = "›",
  reveal = ">",
  divider = "│",

  volume = {
    _100 = "",
    _66 = "",
    _33 = "",
    _10 = "",
    _0 = "",
  },
  mic = {
    on = "",
    off = "",
  },
  bluetooth = {
    on = "󰂱",
    off = "󰂲",
  },
  wifi = {
    connected = "󰖩",
    disconnected = "󰖪",
  },
  media = {
    back = "",
    play = "",
    pause = "",
    forward = "",
  },
}
