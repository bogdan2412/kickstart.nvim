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

local function sync_bufferline_pins(refresh_buffers)
  local harpoon = require("harpoon.mark")
  local bufferline = require("bufferline")

  -- Update [bufferline] state
  if refresh_buffers then
    nvim_bufferline()
  end

  -- Synchronise set of pinned tabs with set of harpoon marks
  local bufferline_elements = bufferline.get_elements()["elements"]
  for _, element in ipairs(bufferline_elements) do
    local buf_name = vim.api.nvim_buf_get_name(element.id)
    local harpoon_mark = harpoon.get_index_of(buf_name)

    if harpoon_mark == nil then
      if bufferline.groups._is_pinned(element) then
        bufferline.groups.remove_element("pinned", element)
      end
    else
      if not bufferline.groups._is_pinned(element) then
        bufferline.groups.add_element("pinned", element)
      end
    end
  end

  -- Synchronise order of pinned tabs with harpoon marks
  local in_order = false
  bufferline_elements = bufferline.get_elements()["elements"]
  while not in_order do
    in_order = true
    for index, element in ipairs(bufferline_elements) do
      local buf_name = vim.api.nvim_buf_get_name(element.id)
      local harpoon_mark = harpoon.get_index_of(buf_name)

      if harpoon_mark ~= nil then
        if harpoon_mark ~= index then
          in_order = false
          bufferline.move_to(harpoon_mark, index)
          bufferline_elements[harpoon_mark], bufferline_elements[index] =
              bufferline_elements[index], bufferline_elements[harpoon_mark]
        end
      end
    end
  end
end

local function open_marks()
  local marks = require("harpoon").get_mark_config().marks

  local new_buffers = false
  for _, mark in ipairs(marks) do
    local filename = vim.fs.normalize(mark.filename)
    if vim.fn.filereadable(filename) == 1 then
      local buf_id = vim.fn.bufnr(filename)
      if buf_id == -1 then
        buf_id = vim.fn.bufadd(filename)
        new_buffers = true
      end
      if not vim.api.nvim_buf_get_option(buf_id, "buflisted") then
        vim.api.nvim_buf_set_option(buf_id, "buflisted", true)
      end
    end
  end

  sync_bufferline_pins(new_buffers)
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
