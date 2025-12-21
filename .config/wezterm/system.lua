local wezterm = require 'wezterm'

-- Define the function that applies macOS configuration.
local function apply_configuration(configuration)
    -- Configure window blur for `macOS`.
    configuration.macos_window_background_blur = 20
end

return apply_configuration
