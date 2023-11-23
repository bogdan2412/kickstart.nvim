local buffers_with_set_cursors = {}

-- Since we eagerly load buffers for all marks and there's no way to set
-- cursors for arbitrary buffers, we have to set the cursor once per buffer
-- when it is first loaded.
local function set_cursor_if_new_buf(buf_id)
  if buffers_with_set_cursors[buf_id] ~= nil then
    return
  end

  local harpoon = require("harpoon.mark")
  local buf_name = vim.api.nvim_buf_get_name(buf_id)
  local harpoon_mark_id = harpoon.get_index_of(buf_name)
  if harpoon_mark_id ~= nil then
    local mark = harpoon.get_marked_file(harpoon_mark_id)
    -- Unlike harpoon, we add 1 to [mark.col] since otherwise it seems like
    -- the cursor moves slowly to the left on each subsequent file open.
    vim.cmd(string.format(":call cursor(%d, %d)", mark.row, mark.col + 1))
    buffers_with_set_cursors[buf_id] = true
  end
end

local function install_set_cursor_hooks()
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(event)
      set_cursor_if_new_buf(event.buf)
    end
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    callback = function(event)
      table.remove(buffers_with_set_cursors, event.buf)
    end
  })
end

local function open_marks()
  local marks = require("harpoon").get_mark_config().marks
  for _, mark in ipairs(marks) do
    local filename = vim.fs.normalize(mark.filename)
    if vim.fn.filereadable(filename) == 1 then
      local buf_id = vim.fn.bufnr(filename)
      if buf_id == -1 then
        buf_id = vim.fn.bufadd(filename)
      end
      if not vim.api.nvim_buf_get_option(buf_id, "buflisted") then
        vim.api.nvim_buf_set_option(buf_id, "buflisted", true)
      end
    end
  end
end

local function install_open_marks_hooks()
  vim.api.nvim_create_autocmd("BufEnter", { callback = open_marks })
  require("harpoon.mark").on("changed", open_marks)
end

return {
  {
    "theprimeagen/harpoon",
    -- Mark [neo-tree] as a dependency so that it ends up defining its
    -- [BufEnter] AutoCmd that updates the current working directory before us
    -- and so that the sidebar gets loaded before we end up wanting to set the
    -- buffer's cursor (if the first buffer has a harpoon mark on it).
    dependencies = { "nvim-neo-tree/neo-tree.nvim" },
    lazy = false,
    keys = {
      { '<leader>a', function() require("harpoon.mark").add_file() end },
      {
        '<leader><space>',
        function() require("harpoon.ui").toggle_quick_menu() end,
        desc = '[ ] Find existing buffers'
      },
    },
    config = function(_, opts)
      local harpoon = require("harpoon")
      harpoon.setup(opts)

      local last_harpoon_buf_id
      vim.api.nvim_create_autocmd("BufModifiedSet", {
        callback = function(event)
          local buf_id = event.buf
          if last_harpoon_buf_id ~= buf_id then
            local filetype = vim.api.nvim_buf_get_option(buf_id, "filetype")
            if filetype == "harpoon" then
              last_harpoon_buf_id = buf_id
              -- Make it such that accidentally hitting undo on the newly
              -- created harpoon buffer does not clear its content.
              local undolevels = vim.api.nvim_buf_get_option(buf_id, "undolevels")
              vim.api.nvim_buf_set_option(buf_id, "undolevels", 0)
              vim.cmd.normal(vim.api.nvim_replace_termcodes("i <BS><ESC>", true, true, true))
              vim.api.nvim_buf_set_option(buf_id, "undolevels", undolevels)
            end
          end
        end,
      })

      install_set_cursor_hooks()
      install_open_marks_hooks()
    end
  },
}
