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
    echo "  - SUPER + SHIFT + T              Toggle floating/tiling"
    echo "  - SUPER + SHIFT + F              Toggle fullscreen"
    echo "  - SUPER + R                      Rotate layout"
    echo "  - SUPER + H/J/K/L                Focus left/down/up/right"
    echo "  - SUPER + SHIFT + H/J/K/L        Move window"
    echo "  - SUPER + SHIFT + ↑↓←→           Join with window"
    echo "  - SUPER + SHIFT + -/=            Resize window"
    echo ""

    # Workspace Management.
    echo "📦 WORKSPACE MANAGEMENT:"
    echo "  - SUPER + 1-9                   Switch workspace 1-9"
    echo "  - SUPER + 0                     Switch workspace 10"
    echo "  - SUPER + ←/→                   Previous/next workspace"
    echo "  - SUPER + SHIFT + 1-9           Move window to workspace 1-9"
    echo "  - SUPER + SHIFT + 0             Move window to workspace 10"
    echo "  - SUPER + SHIFT + Tab           Move workspace to next monitor"
    echo ""

    # Applications.
    echo "🚀 APPLICATIONS:"
    echo "  - CTRL + B                      Google Chrome"
    echo "  - CTRL + E                      Visual Studio Code"
    echo "  - CTRL + T                      Sublime Text"
    echo "  - CTRL + M                      Spotify"
    echo "  - CTRL + K                      Obsidian"
    echo "  - CTRL + /                      Perplexity"
    echo "  - CTRL + ;                      WezTerm"
    echo "  - CTRL + ~                      Finder"
    echo "  - CTRL + '                      System Settings"
    echo "  - CTRL + SHIFT + V              Maccy"
    echo ""

    # System Actions.
    echo "⚙️  SYSTEM ACTIONS"
    echo "  - CTRL + Space                  Switch input source"
    echo "  - CTRL + .                      Spotlight search"
    echo "  - CTRL + -                      Lock screen"
    echo ""

    # Service Mode.
    echo "🔧 SERVICE MODE:"
    echo "     First, press SUPER + ; to enter and then choose:"
    echo "  - L                             Reload Aerospace config"
    echo "  - R                             Flatten workspace tree"
    echo "  - W                             Configure workspaces"
    echo "  - Backspace                     Close all except current"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
end
