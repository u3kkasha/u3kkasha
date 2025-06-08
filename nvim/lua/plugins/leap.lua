-- بسم الله الرحمن الرحيم

return {
    "ggandor/leap.nvim",
    config = function()
        vim.keymap.set({ 'n' }, 'S', '<Plug>(leap-anywhere)')
    end
}
