return {
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      {
        '<C-h>',
        '<cmd>TmuxNavigateLeft<CR>',
        desc = 'Go to left window',
        mode = { 'n', 't' }
      },
      {
        '<C-j>',
        '<cmd>TmuxNavigateDown<CR>',
        desc = 'Go to lower window',
        mode = { 'n', 't' }
      },
      {
        '<C-k>',
        '<cmd>TmuxNavigateUp<CR>',
        desc = 'Go to upper window',
        mode = { 'n', 't' }
      },
      {
        '<C-l>',
        '<cmd>TmuxNavigateRight<CR>',
        desc = 'Go to right window',
        mode = { 'n', 't' }
      },
      {
        '<C-\\>',
        '<cmd>TmuxNavigatePrevious<CR>',
        desc = 'Go to previous window',
        mode = { 'n', 't' }
      },
    },
  },
}
