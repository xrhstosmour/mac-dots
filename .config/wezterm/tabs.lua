local wezterm = require 'wezterm'
local constants = require 'constants'

-- Define the function that applies tabs configuration.
local function apply_configuration(configuration)
    configuration.use_fancy_tab_bar = true
    configuration.tab_max_width = 100
    configuration.enable_tab_bar = true
    configuration.hide_tab_bar_if_only_one_tab = true
    configuration.show_tab_index_in_tab_bar = false
    configuration.window_frame = { font_size = configuration.font_size }
    configuration.colors.tab_bar = {
        new_tab = {
            bg_color = constants.palette.transparent,
            fg_color = constants.palette.dark_gray
        },
        new_tab_hover = {
            bg_color = constants.palette.transparent,
            fg_color = constants.palette.white
        },
        active_tab = {
            bg_color = constants.palette.gray,
            fg_color = constants.palette.white,
            intensity = "Bold"
        },
        inactive_tab = {
            bg_color = constants.palette.dark_gray,
            fg_color = constants.palette.light_gray
        },
        inactive_tab_hover = {
            bg_color = constants.palette.dark_gray,
            fg_color = constants.palette.light_gray
        }
    }

    wezterm.on(
        "format-tab-title",
        function(tab, tabs, panes, config, hover, max_width)
            local process = tab.active_pane.foreground_process_name or ""
            local process_name = process ~= "" and process:match("([^/]+)$") or "shell"

            local cwd = tab.active_pane.current_working_dir
            local path_name = nil
            if cwd then
                local full_path = cwd.file_path
                if full_path ~= "/" then
                    full_path = full_path:gsub("/$", "")
                end
                local home = wezterm.home_dir
                if full_path == home then
                    path_name = "~"
                elseif full_path:sub(1, #home + 1) == home .. "/" then
                    path_name = "~" .. full_path:sub(#home + 1)
                else
                    path_name = full_path
                end
            end

            local title = process_name
            if path_name then
                title = title .. " · " .. path_name
            end
            title = wezterm.truncate_right(title, max_width - 2)

            local background = config.colors.tab_bar.inactive_tab.bg_color
            local foreground = config.colors.tab_bar.inactive_tab.fg_color

            if tab.is_active then
                background = config.colors.tab_bar.active_tab.bg_color
                foreground = config.colors.tab_bar.active_tab.fg_color
            elseif hover then
                background = config.colors.tab_bar.inactive_tab_hover.bg_color
                foreground = config.colors.tab_bar.inactive_tab_hover.fg_color
            end

            local tab_color = tab.active_pane.user_vars.tab_color
            if tab_color then
                if tab_color == "red" then
                    background = constants.palette.red
                    foreground = constants.palette.black
                elseif tab_color == "yellow" then
                    background = constants.palette.yellow
                    foreground = constants.palette.black
                elseif tab_color == "green" then
                    background = constants.palette.green
                    foreground = constants.palette.black
                end
            end

            return {
                { Background = { Color = background } },
                { Foreground = { Color = foreground } },
                { Text = " " .. title .. " " },
            }
        end
    )
end

return apply_configuration
