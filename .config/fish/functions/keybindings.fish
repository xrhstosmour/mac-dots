# Function to display all keybindings organized by category with descriptions.
# Usage:
#   keybindings_cheat_sheet
function keybindings_cheat_sheet --description "Display all keybindings with descriptions"
    echo ""
    echo "KEYBOARD MAPPING:"
    echo "  Internal:"
    echo "    GLOBE → CMD"
    echo "    OPT/ALT ↔ CTRL"
    echo "    Right SHIFT → DELETE"
    echo "    § → ~"
    echo ""
    echo "  External (Non-Apple):"
    echo "    CTRL → CMD"
    echo "    SUPER → OPT/ALT"
    echo "    ALT → CTRL"
    echo ""
    echo "KEYBINDINGS REFERENCES:"
    echo "  (Using external keyboard physical keys: CTRL, SUPER, ALT)"
    echo ""

    # Window Management.
    echo "🪟 WINDOW MANAGEMENT:"
    echo "  - ALT + SHIFT + T              Toggle floating/tiling"
    echo "  - ALT + SHIFT + F              Toggle fullscreen"
    echo "  - ALT + R                      Rotate layout"
    echo "  - ALT + H/J/K/L                Focus left/down/up/right"
    echo "  - ALT + SHIFT + H/J/K/L        Move window"
    echo "  - ALT + SHIFT + ↑↓←→           Join with window"
    echo "  - ALT + SHIFT + -/=            Resize window"
    echo ""

    # Workspace Management.
    echo "📦 WORKSPACE MANAGEMENT:"
    echo "  - ALT + 1-9                   Switch workspace 1-9"
    echo "  - ALT + 0                     Switch workspace 10"
    echo "  - ALT + ←/→                   Previous/next workspace"
    echo "  - ALT + SHIFT + 1-9           Move window to workspace 1-9"
    echo "  - ALT + SHIFT + 0             Move window to workspace 10"
    echo "  - ALT + SHIFT + Tab           Move workspace to next monitor"
    echo ""

    # Applications.
    echo "🚀 APPLICATIONS:"
    echo "  - SUPER + B                      Google Chrome"
    echo "  - SUPER + E                      Visual Studio Code"
    echo "  - SUPER + M                      Spotify"
    echo "  - SUPER + K                      Obsidian"
    echo "  - SUPER + /                      Perplexity"
    echo "  - SUPER + ;                      WezTerm"
    echo "  - SUPER + ~                      Finder"
    echo "  - SUPER + '                      System Settings"
    echo "  - SUPER + SHIFT + V              Maccy"
    echo ""

    # System Actions.
    echo "⚙️  SYSTEM ACTIONS"
    echo "  - CTRL + Space                  Switch input source"
    echo "  - CTRL + .                      Spotlight search"
    echo "  - CTRL + SHIFT + L              Lock screen"
    echo ""

    # Service Mode.
    echo "🔧 SERVICE MODE:"
    echo "     First, press ALT + ; to enter and then choose:"
    echo "  - L                             Reload Aerospace config"
    echo "  - R                             Flatten workspace tree"
    echo "  - W                             Configure workspaces"
    echo "  - Backspace                     Close all except current"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
end
