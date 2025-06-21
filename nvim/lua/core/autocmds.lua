-- بسم الله الرحمن الرحيم

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 500})
  end,
})

-- Set terminal background to transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "TermNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TermNormalNC", { bg = "none" })
-- Set fillchars for a cleaner look
vim.opt.fillchars:append({ eob = " " })