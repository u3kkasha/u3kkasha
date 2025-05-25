-- بسم الله الرحمن الرحيم
---@diagnostic disable: undefined-global

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 500})
  end,
})