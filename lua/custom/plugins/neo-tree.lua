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
            local root = require("custom.root").get_for_buf(buf)
            require("neo-tree.command").execute({ dir = root })
          else
            vim.cmd("wincmd w")
          end
        end,
        desc = 'File Explorer',
      },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        -- As of 2023-10-30, [neo-tree]'s implementation of this is faulty - it does not
        -- seem to stay subscribed to [DirChanged] events while a panel is not showing
        -- and it does not refresh itself appropriately when re-opened.
        -- This furthermore means that the different sources are not kept in line.
        -- We will implement this functionality ourselves instead.
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
        },
        hijack_netrw_behavior = "open_current",
      },
      buffers = {
        bind_to_cwd = false,
      },
      git_status = {
        bind_to_cwd = false,
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

      -- Prevent neo-tree from opening when started in diff mode
      if load_on_startup and vim.api.nvim_get_option_value("diff", {}) then
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
        require("neo-tree.command").execute({ action = "show" })
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(event)
          local filetype_prev = vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "filetype")
          local filetype_next = vim.api.nvim_buf_get_option(event.buf, "filetype")
          if filetype_prev ~= "neo-tree" and filetype_next ~= "neo-tree" then
            local root = require("custom.root").get_for_buf(event.buf)
            local cwd = vim.fn.getcwd()
            if root ~= "." and root ~= cwd then
              vim.api.nvim_set_current_dir(root)

              for _, source in ipairs({ "filesystem", "buffers", "git_status" }) do
                require("neo-tree.sources.manager").dir_changed(source)
              end
            end
          end
        end,
      })
    end,
  },
}
