-- بسم الله الرحمن الرحيم
---@diagnostic disable: undefined-global

return {
    "ggandor/leap.nvim",
    config = function()
        vim.keymap.set({ 'n' }, 'S', '<Plug>(leap-anywhere)')
    end
}
