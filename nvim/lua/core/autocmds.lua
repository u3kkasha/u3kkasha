-- بسم الله الرحمن الرحيم

local augroup = vim.api.nvim_create_augroup('UserAutocmds', { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 500})
  end,
})

-- Set terminal background to transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "TermNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TermNormalNC", { bg = "none" })

-- Disable automatic comment insertion for all file types
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = '*',
  command = 'set formatoptions-=cro',
})

-- Auto update plugins on startup
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
     if require("lazy").update then
       require("lazy").update({ show = false })
     else
       require("lazy").sync({ show = false })
     end
  end,
})