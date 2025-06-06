-- بسم الله الرحمن الرحيم
return {
    'smoka7/hop.nvim',
    version = "v2.7.2",
    lazy = false,
    keys = {
        { '<leader><leader>w', '<CMD>HopWord<CR>', desc = 'Jump to any word', mode = 'n' },
        { '<leader><leader>y', '<CMD>HopYankChar1<CR>', desc = 'Yank the text between two hinted position without jumping', mode = 'n' },
        { '<leader><leader>n', '<CMD>HopNodes<CR>', desc = 'Jump to any node', mode = 'n' },
    },
    opts = {
        keys = 'etovxqpdygfblzhckisuran'
    }
}
