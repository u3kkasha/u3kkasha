-- بسم الله الرحمن الرحيم
---@diagnostic disable: undefined-global

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            highlight = { enable = false },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection    = "gnn",
                    node_decremental  = "gnx",
                    node_incremental  = "gna",
                    scope_incremental = "gns",
                },
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    ["]m"] = "@function.outer",
                },
                goto_next_end = {
                    ["]M"] = "@function.outer",
                },
                goto_previous_start = {
                    ["[m"] = "@function.outer",
                },
                goto_previous_end = {
                    ["[M"] = "@function.outer",
                },
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects'
    },
    {
        'echasnovski/mini.ai',
        version = false,
        config = function()
            local spec_treesitter = require('mini.ai').gen_spec.treesitter
            require('mini.ai').setup({
                custom_textobjects = {
                    A = spec_treesitter({ a = '@attribute.outer', i = '@attribute.inner' }),
                    C = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
                    F = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
                    ["#"] = spec_treesitter({ a = '@number.inner', i = '@number.inner' }),
                    ["="] = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
                    ["~"] = spec_treesitter({ a = '@assignment.lhs', i = '@assignment.rhs' }),
                    ['@'] = spec_treesitter({ a = '@regex.outer', i = '@regex.innner' }),
                    c = spec_treesitter({ a = '@comment.outer', i = '@comment.inner' }),
                    f = spec_treesitter({ a = '@call.outer', i = '@call.inner' }),
                    i = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
                    l = spec_treesitter({ a = '@loop.outer', i = '@loop.inner' }),
                    p = spec_treesitter({ a = '@block.outer', i = '@block.inner' }),
                    r = spec_treesitter({ a = '@return.outer', i = '@return.inner' }),
                    s = spec_treesitter({ a = '@statement.outer', i = '@scopename.inner' }),
                    g = function()
                        local from = { line = 1, col = 1 }
                        local to = {
                            line = vim.fn.line('$'),
                            col  = math.max(vim.fn.getline('$'):len(), 1)
                        }
                        return { from = from, to = to }
                    end
                }
            })
        end
    }
}
