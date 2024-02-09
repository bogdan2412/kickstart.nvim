local function move_cursor_left() require('smart-splits').move_cursor_left() end
local function move_cursor_down() require('smart-splits').move_cursor_down() end
local function move_cursor_up() require('smart-splits').move_cursor_up() end
local function move_cursor_right() require('smart-splits').move_cursor_right() end
local function resize_left() require('smart-splits').resize_left() end
local function resize_down() require('smart-splits').resize_down() end
local function resize_up() require('smart-splits').resize_up() end
local function resize_right() require('smart-splits').resize_right() end
local function swap_buf_left() require('smart-splits').swap_buf_left() end
local function swap_buf_down() require('smart-splits').swap_buf_down() end
local function swap_buf_up() require('smart-splits').swap_buf_up() end
local function swap_buf_right() require('smart-splits').swap_buf_right() end

return {
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    keys = {
      { '<C-h>',   move_cursor_left,  desc = 'Go to left window',            mode = { 'n', 't' } },
      { '<C-j>',   move_cursor_down,  desc = 'Go to lower window',           mode = { 'n', 't' } },
      { '<C-k>',   move_cursor_up,    desc = 'Go to upper window',           mode = { 'n', 't' } },
      { '<C-l>',   move_cursor_right, desc = 'Go to right window',           mode = { 'n', 't' } },
      { '<C-A-h>', resize_left,       desc = 'Resize window towards left',   mode = { 'n', 't' } },
      { '<C-A-j>', resize_down,       desc = 'Resize window towards bottom', mode = { 'n', 't' } },
      { '<C-A-k>', resize_up,         desc = 'Resize window towards up',     mode = { 'n', 't' } },
      { '<C-A-l>', resize_right,      desc = 'Resize window towards right',  mode = { 'n', 't' } },
      { '<A-h>',   swap_buf_left,     desc = 'Swap with left window',        mode = { 'n', 't' } },
      { '<A-j>',   swap_buf_down,     desc = 'Swap with lower window',       mode = { 'n', 't' } },
      { '<A-k>',   swap_buf_up,       desc = 'Swap with upper window',       mode = { 'n', 't' } },
      { '<A-l>',   swap_buf_right,    desc = 'Swap with right right',        mode = { 'n', 't' } },
    },
    opts = {
      default_amount = 2,
      at_edge = 'stop',
      cursor_follows_swapped_bufs = true,
    },
  },
}
