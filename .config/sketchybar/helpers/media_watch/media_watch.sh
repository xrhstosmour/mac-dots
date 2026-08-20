#!/bin/bash
# Bridges `media-control stream` (which only prints JSON lines) to
# SketchyBar's event system: fires a plain signal per change, and
# `items/sound.lua` fetches the fresh details with `media-control get`.
trap "exit" INT

pkill -f "media-control stream" 2>/dev/null

media-control stream --no-diff --no-artwork | while IFS= read -r _; do
  sketchybar --trigger now_playing_change
done
