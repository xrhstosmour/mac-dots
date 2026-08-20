local M = {}

-- Wraps a value in single quotes for safe use inside a shell command string,
-- escaping any embedded single quotes. Use this whenever a dynamic value
-- (a device name, an address) is interpolated into a `click_script`.
function M.quote(value)
  value = tostring(value or "")
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

return M
