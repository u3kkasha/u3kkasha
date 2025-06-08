-- بسم الله الرحمن الرحيم

return {
    {
        'vscode-neovim/vscode-multi-cursor.nvim',
        event = 'VeryLazy',
        cond = not not vim.g.vscode,
        opts = {},
    },
    {
        cond = not not vim.g.vscode, "xiyaowong/fast-cursor-move.nvim"
    }
}
