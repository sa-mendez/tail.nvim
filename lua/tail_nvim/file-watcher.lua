local m = {
  files = {},
}
local uv = vim.loop

--- Watch a file for updates
-- See https://github.com/luvit/luv/blob/master/docs.md#file-system-operations
-- @param filename The relative file path
-- @param callback The function to call on updates
-- @return self
function m:watch(filename, callback)
  local poller = uv.new_fs_poll()
  self.files[filename] = { timestamp = os.time() }

  local function on_change(err, _, events)
    if not err == nil then
      error("Error: ", err)
      self:unwatch(filename)
    end

    poller:stop()
    if self.files[filename] == nil then
      return
    end

    local timestamp = os.time()
    -- NOTE: This allows to discard duplicated events
    if self.files[filename].timestamp < timestamp then
      self.files[filename].timestamp = timestamp
      callback(filename, events)
      if self.files[filename] == nil then
        return
      end
    end
    self.files[filename].timestamp = timestamp

    poller:start(filename, 100, vim.schedule_wrap(on_change))
  end

  poller:start(filename, 100, vim.schedule_wrap(on_change))
  return self
end

--- Unwatch a file
-- @param filename The file to unwatch
-- @return self
function m:unwatch(filename)
  self.files[filename] = nil
  return self
end

return m
