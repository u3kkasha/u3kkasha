-- بسم الله الرحمن الرحيم

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Map CamelCaseMotion to leader key
vim.g.camelcasemotion_key = '<leader>'

if vim.g.vscode then
-- VSCode-specific keymaps

local vscode = require('vscode')

local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, function() vscode.call(rhs) end, { silent = true, noremap = true })
  end
  -- Remap folding keys
  map('n', 'zC', 'editor.foldRecursively')
  map('n', 'zM', 'editor.foldAll')
  map('n', 'zO', 'editor.unfoldRecursively')
  map('n', 'zR', 'editor.unfoldAll')
  map('n', 'za', 'editor.toggleFold')
  map('n', 'zc', 'editor.fold')
  map('n', 'zo', 'editor.unfold')

  -- Toggle zen mode
  map('n', '<leader>z', 'workbench.action.toggleZenMode')

  vim.keymap.set('n', '<leader><leader>w', ':HopWord<CR>', { silent = true })
  map('n', '<leader>.', 'breadcrumbs.focusAndSelect')
  map('n', '<leader>o', 'outline.focus')
end
-- setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      'vscode-neovim/vscode-multi-cursor.nvim',
      event = 'VeryLazy',
      cond = not not vim.g.vscode,
      opts = {},
    },
    {
      "chrisgrieser/nvim-spider",
      lazy = true,
      keys = {
        { "w", "<cmd>lua require('spider').motion('w', { skipInsignificantPunctuation = false })<CR>", mode = { "n", "o", "x" } },
        { "e", "<cmd>lua require('spider').motion('e')<CR>",                                           mode = { "n", "o", "x" } },
        { "b", "<cmd>lua require('spider').motion('b')<CR>",                                           mode = { "n", "o", "x" } },
      },
    },
    {
      'echasnovski/mini.surround',
      version = false,
      config = function()
        require('mini.surround').setup()
      end
    },
    {
      'smoka7/hop.nvim',
      version = "*",
      opts = {
        keys = 'etovxqpdygfblzhckisuran'
      }
    },
    {
      "ggandor/leap.nvim",
      config = function()
        vim.keymap.set({'n', 'x', 'o'}, 'S', '<Plug>(leap-anywhere)')
      end
    },
    {
      "tpope/vim-repeat",
      event = "VeryLazy",
    },
    {
      cond = not not vim.g.vscode, "xiyaowong/fast-cursor-move.nvim"
    },
    {
     'echasnovski/mini.operators',
      version = false,
      config = function()
        require("mini.operators").setup()
      end,
    },
    {
      'echasnovski/mini.ai',
      version = false,
      config = function()
        require('mini.ai').setup({
          custom_textobjects = {
            g = function()
              local from = { line = 1, col = 1 }
              local to = {
                line = vim.fn.line('$'),
                col = math.max(vim.fn.getline('$'):len(), 1)
              }
              return { from = from, to = to }
            end
          }
        })
      end
    },
    {
        'echasnovski/mini.splitjoin',
        version = false,
        config = function()
          require('mini.splitjoin').setup()
        end
    },
    {
      'echasnovski/mini.move', version = false ,
        config = function ()
        require('mini.move').setup({
          -- Module mappings. Use `''` (empty string) to disable one.
          mappings = {
            -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
            left = '<leader>h',
            right = '<leader>l',
            down = '<leader>j',
            up = '<leader>k',

            -- Move current line in Normal mode
            line_left = '<leader>h',
            line_right = '<leader>l',
            line_down = '<leader>j',
            line_up = '<leader>k',
          },

          -- Options which control moving behavior
          options = {
            -- Automatically reindent selection during linewise vertical move
            reindent_linewise = true,
          },
        })
        end
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
 install = {colorscheme = { "kanagawa" }},
  -- automatically chec for plugin updates
  checker = {
    enabled = true
  }
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 500})
  end,
})