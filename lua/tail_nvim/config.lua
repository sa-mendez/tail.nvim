local M = {}

---@class ProjectOptions
local defaults = {

	-- File polling frequency(for changes) in milliseconds
	poll_frequency = 100,

	-- Notifier used to log mesages
	notifier = vim.notify,

	-- Tail interval in millseconds
	tail_interval = 2000,

	-- Smart tail logic: if the cursor is not at the last line (e.g was moved)
	-- do not go to the end of the buffer after reloading it.
	-- This will allow you to continue reloading a file, but stay focused
	-- on a line you are interested in. To got back to "tailing" just move the cursor
	-- to the last line.
	smart_tail = false,
}

---@type ProjectOptions
M.options = {}

M.setup = function(options)
	M.options = vim.tbl_extend("force", defaults, options or {})
	vim.cmd([[ command! ToggleTailBuffer lua require('tail_nvim.tailfile'):toggle_tail() ]])
end

return M
