-- بسم الله الرحمن الرحيم

return {
    {
        'nvim-mini/mini.surround',
        version = "*",
        opts = {}
    },
    {
        'nvim-mini/mini.operators',
        version = "*",
        opts = {}
    },
    {
        'nvim-mini/mini.splitjoin',
        version = "*",
        opts = {
            detect = {
                separator = '[,;]'
            }
        },
    },
    {
        'nvim-mini/mini.align',
        version = '*',
        opts = {},
    },
    {
        'nvim-mini/mini.move',
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
