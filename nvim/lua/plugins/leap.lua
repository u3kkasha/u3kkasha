-- بسم الله الرحمن الرحيم

return {
    "ggandor/leap.nvim",
    config = function()
        vim.keymap.set({ 'n' }, '<leader>s', '<Plug>(leap-anywhere)')
    end
}
