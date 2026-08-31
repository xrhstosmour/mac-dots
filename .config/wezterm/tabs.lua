local wezterm = require 'wezterm'
local constants = require 'constants'

-- Nerd Font icons shown in place of the process name when a match exists.
-- WezTerm cannot resolve arbitrary process names to icons automatically, glyphs only exist for
-- tools Nerd Fonts has curated, so unmapped processes (e.g. `claude`, `htop`, `curl`) fall back
-- to plain text.
local process_icons = {
    ["git"] = wezterm.nerdfonts.dev_git,
    ["gh"] = wezterm.nerdfonts.dev_github,
    ["tmux"] = wezterm.nerdfonts.cod_terminal_tmux,
    ["vim"] = wezterm.nerdfonts.dev_vim,
    ["nvim"] = wezterm.nerdfonts.custom_neovim,
    ["node"] = wezterm.nerdfonts.dev_nodejs,
    ["python"] = wezterm.nerdfonts.dev_python,
    ["python3"] = wezterm.nerdfonts.dev_python,
    ["docker"] = wezterm.nerdfonts.dev_docker,
    ["docker-compose"] = wezterm.nerdfonts.dev_docker,
    ["cargo"] = wezterm.nerdfonts.dev_rust,
    ["rustc"] = wezterm.nerdfonts.dev_rust,
    ["go"] = wezterm.nerdfonts.dev_go,
    ["ruby"] = wezterm.nerdfonts.dev_ruby,
    ["ssh"] = wezterm.nerdfonts.dev_ssh,
    ["bash"] = wezterm.nerdfonts.dev_bash,
    ["zsh"] = wezterm.nerdfonts.dev_zsh,
    ["fish"] = wezterm.nerdfonts.dev_fish,
    ["java"] = wezterm.nerdfonts.dev_java,
    ["php"] = wezterm.nerdfonts.dev_php,
    ["npm"] = wezterm.nerdfonts.dev_npm,
    ["yarn"] = wezterm.nerdfonts.dev_yarn,
    ["kubectl"] = wezterm.nerdfonts.dev_kubernetes,
    ["terraform"] = wezterm.nerdfonts.dev_terraform,
    ["psql"] = wezterm.nerdfonts.dev_postgresql,
    ["mysql"] = wezterm.nerdfonts.dev_mysql,
    ["redis-cli"] = wezterm.nerdfonts.dev_redis,
    ["brew"] = wezterm.nerdfonts.dev_homebrew,
    ["code"] = wezterm.nerdfonts.dev_vscode,
    ["subl"] = wezterm.nerdfonts.dev_sublime,
    ["emacs"] = wezterm.nerdfonts.dev_emacs,
    ["nano"] = wezterm.nerdfonts.dev_nano,
    ["sqlite3"] = wezterm.nerdfonts.dev_sqlite,
    ["cmake"] = wezterm.nerdfonts.dev_cmake,
    ["aws"] = wezterm.nerdfonts.dev_aws,
    ["gcloud"] = wezterm.nerdfonts.dev_googlecloud,
    ["ansible"] = wezterm.nerdfonts.dev_ansible,
    ["ansible-playbook"] = wezterm.nerdfonts.dev_ansible,
    ["vagrant"] = wezterm.nerdfonts.dev_vagrant,
    ["helm"] = wezterm.nerdfonts.dev_helm,
    ["deno"] = wezterm.nerdfonts.dev_denojs,
    ["bun"] = wezterm.nerdfonts.dev_bun,
    ["perl"] = wezterm.nerdfonts.dev_perl,
    ["lua"] = wezterm.nerdfonts.dev_lua,
    ["zig"] = wezterm.nerdfonts.dev_zig,
    ["mvn"] = wezterm.nerdfonts.dev_maven,
    ["gradle"] = wezterm.nerdfonts.dev_gradle,
    ["composer"] = wezterm.nerdfonts.dev_composer,
    ["poetry"] = wezterm.nerdfonts.dev_poetry,
    ["conda"] = wezterm.nerdfonts.dev_anaconda,
    ["elixir"] = wezterm.nerdfonts.dev_elixir,
    ["iex"] = wezterm.nerdfonts.dev_elixir,
    ["erl"] = wezterm.nerdfonts.dev_erlang,
    ["swift"] = wezterm.nerdfonts.dev_swift,
    ["dart"] = wezterm.nerdfonts.dev_dart,
    ["dotnet"] = wezterm.nerdfonts.dev_dotnet,
    ["gcc"] = wezterm.nerdfonts.dev_c,
    ["clang"] = wezterm.nerdfonts.dev_c,
    ["cc"] = wezterm.nerdfonts.dev_c,
    ["g++"] = wezterm.nerdfonts.dev_cplusplus,
    ["c++"] = wezterm.nerdfonts.dev_cplusplus
}

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

            local title = process_icons[process_name] or process_name
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
