# tail.nvim
Neovim plugin to tail the file loaded by the current buffer

## Options
The following are the options(default shown) that can be specified:

  ```lua  
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
  ```
  
## Example Usage (packer.nvim)
  ```
  use {
    "sa-mendez/tail.nvim",
    after = "nvim-notify",
    config = function()
      require("tail_nvim").setup {
        smart_tail = true,
        notifier = require "notify",
      }
    end,
    event = "BufRead",
  },
  ```
Note that the ```setup``` method must be called even if you are not overriding any defaults.

## Toggle command
The plugin creates the following command ```ToggleTailBuffer``` which you use to toggle on/off the tailing on the current buffer.
  
