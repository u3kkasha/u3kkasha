-- بسم الله الرحمن الرحيم

return {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
        vim.keymap.set({ 'n' }, '<leader>s', '<Plug>(leap-anywhere)')
    end
}
