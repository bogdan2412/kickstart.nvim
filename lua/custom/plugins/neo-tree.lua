return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false,
    keys = {
      {
        '<leader>e',
        function()
          local buf = vim.api.nvim_get_current_buf()
          local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
          if filetype ~= "neo-tree" then
            require("neo-tree.command").execute({})
          else
            vim.cmd("wincmd w")
          end
        end,
        desc = 'File Explorer',
      },
    },
    opts = {
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        hijack_netrw_behavior = "open_current",
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      local load_on_startup = true
      -- Only open neo-tree on startup assuming the editor is wide enough.
      -- We need
      --   * 40 columnes for neo-tree
      --   * 1 for a separator
      --   * 2 for the sign column
      --   * 4 for line numbers
      --   * 80 for the file contents
      if vim.api.nvim_win_get_width(0) < 40 + 1 + 2 + 4 + 80 then
        load_on_startup = false
      end

      -- Prevent neo-tree from opening for git prompts
      if load_on_startup and vim.fn.argc(-1) == 1 then
        local arg = vim.fn.argv(0, -1)
        assert(type(arg) == "string")
        local file_name = vim.fs.basename(arg)
        if (file_name == "COMMIT_EDITMSG" or
              file_name == "git-rebase-todo" or
              file_name == "addp-hunk-edit.diff") then
          load_on_startup = false
        end
      end

      if load_on_startup then
        vim.defer_fn(function()
          require("neo-tree.command").execute({ action = "show" })
        end, 0)
      end
    end,
  },
}
