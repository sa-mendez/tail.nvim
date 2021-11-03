local M = {}

local uv = vim.loop
local config = require("tail_nvim.config")
local notifier = config.options.notifier
local tail_interval = config.options.tail_interval
local smart_tail = config.options.smart_tail

local tail_filename = nil
local tail_file_updated = false

local timer = nil
local watcher = require("tail_nvim.file-watcher")

local function get_current_buf_filename()
	return vim.api.nvim_buf_get_name(0)
end

--- Checks whether a given path exists and is a file.
--@param path (string) path to check
--@returns (bool)
local function is_file(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "file" or false
end

local function is_cursor_at_buffer_end()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
	return vim.api.nvim_buf_line_count(0) ~= cursor_row
end

local function end_tail_file(fname)
	notifier("Ending tail on " .. fname)
	watcher:unwatch(fname)
	timer:stop()
	timer:close()
	tail_filename = nil
	tail_file_updated = false
	timer = nil
end

local function tail_file()
	-- The current buffer file is no longer the one we we are tailing
	-- turn off the tailing of the file being tailed
	if get_current_buf_filename() ~= tail_filename then
		end_tail_file(tail_filename)
		return
	end

	if tail_file_updated then
		tail_file_updated = false
		local post_reload_action

		-- Smart tail logic: if the cursor is not at the last line (e.g was moved)
		-- do not go to the end of the buffer after reloading it.
		-- This will allow you to continue reloading a file, but stay focused
		-- on a line you are interested in. To got back to "tailing" just move the cursor
		-- to the last line.
		if smart_tail and is_cursor_at_buffer_end() then
			local curr_win_view = vim.fn.winsaveview()
			post_reload_action = function()
				vim.fn.winrestview(curr_win_view)
			end
		else
			post_reload_action = function()
				vim.cmd("normal G")
			end
		end

		vim.cmd("edit!")
		post_reload_action()
	end
end

function M.toggle_tail()
	local filename = get_current_buf_filename()

	if tail_filename ~= nil then
		local was_being_tailed = filename == tail_filename
		end_tail_file(tail_filename)
		-- in this case we are just toggling off the file we are already tailing
		-- just return
		if was_being_tailed then
			return
		end
	end

	if not is_file(filename) then
		return
	end

	tail_filename = filename
	tail_file_updated = false
	timer = uv.new_timer()
	watcher:watch(filename, function()
		tail_file_updated = true
	end)

	notifier("Starting tail on " .. filename)
	vim.cmd("normal G")
	timer:start(tail_interval, tail_interval, vim.schedule_wrap(tail_file))
end

return M
