return {
  {
    "mbbill/undotree",
    keys = {
      { '<leader>u', ":UndotreeToggle<cr>:UndotreeFocus<cr>" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 4
    end
  },
}
