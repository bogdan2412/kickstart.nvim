-- @param num number
local function switch_tab(num)
  return function()
    require('bufferline').go_to(num, true)
  end
end

return {
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    keys = {
      { '[b',           '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
      { ']b',           '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      { '<C-{><C-S-b>', '<cmd>BufferLineMovePrev<cr>',  desc = 'Move buffer left' },
      { '<C-}><C-S-b>', '<cmd>BufferLineMoveNext<cr>',  desc = 'Move buffer right' },
      { '<leader>b',    '<cmd>BufferLinePick<cr>',      desc = 'Pick buffer' },
      { '<leader>B',    '<cmd>BufferLineTogglePin<cr>', desc = 'Pin buffer' },
      { '<leader>`',    '<cmd>e #<cr>',                 desc = 'Switch to previously used buffer' },
      { '<leader>1',    switch_tab(1),                  desc = 'Switch to buffer in position 1' },
      { '<leader>2',    switch_tab(2),                  desc = 'Switch to buffer in position 2' },
      { '<leader>3',    switch_tab(3),                  desc = 'Switch to buffer in position 3' },
      { '<leader>4',    switch_tab(4),                  desc = 'Switch to buffer in position 4' },
      { '<leader>5',    switch_tab(5),                  desc = 'Switch to buffer in position 5' },
      { '<leader>6',    switch_tab(6),                  desc = 'Switch to buffer in position 6' },
      { '<leader>7',    switch_tab(7),                  desc = 'Switch to buffer in position 7' },
      { '<leader>8',    switch_tab(8),                  desc = 'Switch to buffer in position 8' },
      { '<leader>9',    switch_tab(-1),                 desc = 'Switch to buffer in last position' },
    },
    opts = {
      options = {
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
}
