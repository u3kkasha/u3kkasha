-- بسم الله الرحمن الرحيم
---@diagnostic disable: undefined-global
return {
    {
        'echasnovski/mini.surround',
        version = "*",
        opts = {}
    },
    {
        'echasnovski/mini.operators',
        version = "*",
        opts = {}
    },
    {
        'echasnovski/mini.splitjoin',
        version = "*",
        opts = {
            detect = {
                separator = '[,;]'
            }
        },
    },
    {
        'echasnovski/mini.align',
        version = '*',
        opts = {},
    },
    {
        'echasnovski/mini.move',
        version = false,
        opts = {
            mappings = {
                -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
                left       = '<leader>h',
                right      = '<leader>l',
                down       = '<leader>j',
                up         = '<leader>k',
                -- Move current line in Normal mode
                line_left  = '<leader>h',
                line_right = '<leader>l',
                line_down  = '<leader>j',
                line_up    = '<leader>k',
            },

            -- Options which control moving behavior
            options = {
                -- Automatically reindent selection during linewise vertical move
                reindent_linewise = true,
            },
        },
    }
}
