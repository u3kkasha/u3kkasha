-- بسم الله الرحمن الرحيم

return {
    'stevearc/oil.nvim',
    cond = not vim.g.vscode,
    lazy = false,
    opts = {
        -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
        default_file_explorer = true,
        -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
        skip_confirm_for_simple_edits = true,
        view_options = {
            -- Show files and directories that start with "."
            show_hidden = true,
        },
    },
    config = function(_, opts)
        require('oil').setup(opts)
        vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
}
