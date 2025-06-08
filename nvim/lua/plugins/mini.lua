-- بسم الله الرحمن الرحيم

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
                down       = ']e',
                up         = '[e',
                -- Move current line in Normal mode
                line_down  = ']e',
                line_up    = '[e',
            },

            -- Options which control moving behavior
            options = {
                -- Automatically reindent selection during linewise vertical move
                reindent_linewise = true,
            },
        },
    }
}
