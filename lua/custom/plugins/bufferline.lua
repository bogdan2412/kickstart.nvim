-- @param num number
local function switch_tab(num)
  return function()
    require('bufferline').go_to(num, true)
  end
end

local function buffer_move(delta)
  return function()
    local bufferline = require('bufferline')
    local elements = bufferline.get_elements()["elements"]
    local current_buf = vim.api.nvim_get_current_buf()
    for index, element in ipairs(elements) do
      if element.id == current_buf then
        -- Pinned tab ordering is managed via [harpoon].
        if not bufferline.groups._is_pinned(element) then
          bufferline.move_to(index, index + delta)
        end
        return
      end
    end
  end
end

return {
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = { 'nvim-tree/nvim-web-devicons', 'echasnovski/mini.bufremove', },
    lazy = false,
    keys = {
      { '<C-A-PageUp>',     '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
      { '<C-A-PageDown>',   '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      { '<C-S-A-PageUp>',   buffer_move(-1),                desc = 'Move buffer left' },
      { '<C-S-A-PageDown>', buffer_move(1),                 desc = 'Move buffer right' },
      { '<leader>b',        '<cmd>BufferLinePick<cr>',      desc = 'Pick buffer' },
      { '<leader>`',        '<cmd>e #<cr>',                 desc = 'Switch to previously used buffer' },
      { '<leader>1',        switch_tab(1),                  desc = 'Switch to buffer in position 1' },
      { '<leader>2',        switch_tab(2),                  desc = 'Switch to buffer in position 2' },
      { '<leader>3',        switch_tab(3),                  desc = 'Switch to buffer in position 3' },
      { '<leader>4',        switch_tab(4),                  desc = 'Switch to buffer in position 4' },
      { '<leader>5',        switch_tab(5),                  desc = 'Switch to buffer in position 5' },
      { '<leader>6',        switch_tab(6),                  desc = 'Switch to buffer in position 6' },
      { '<leader>7',        switch_tab(7),                  desc = 'Switch to buffer in position 7' },
      { '<leader>8',        switch_tab(8),                  desc = 'Switch to buffer in position 8' },
      { '<leader>9',        switch_tab(-1),                 desc = 'Switch to buffer in last position' },
    },
    opts = {
      options = {
        close_command = function(buf) require("mini.bufremove").delete(buf) end,
        separator_style = "slant",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict, _)
          if diagnostics_dict["error"] then
            return " " .. diagnostics_dict["error"]
          elseif diagnostics_dict["warning"] then
            return " " .. diagnostics_dict["warning"]
          end
          return ""
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "center",
            padding = 1,
          },
        },
      },
    },
  },

  {
    'echasnovski/mini.bufremove',
    version = '*',
    keys = {
      {
        '<leader>q',
        function()
          require('mini.bufremove').delete()
        end,
        desc = '[Q]uit current buffer'
      }
    },
  },
}
