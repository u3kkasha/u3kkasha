-- بسم الله الرحمن الرحيم

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'main',
        lazy = false,
        build = ":TSUpdate",
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
    },
    {
        'nvim-mini/mini.ai',
        version = false,
        config = function()
            local miniai = require('mini.ai')

            -- define treesitter textobjects
            local spec_treesitter = miniai.gen_spec.treesitter
            miniai.setup({
                custom_textobjects = {
                    A = spec_treesitter({ a = '@attribute.outer', i = '@attribute.inner' }),
                    C = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
                    F = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
                    ["#"] = spec_treesitter({ a = '@number.inner', i = '@number.inner' }),
                    ["="] = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
                    ["~"] = spec_treesitter({ a = '@assignment.lhs', i = '@assignment.rhs' }),
                    ['@'] = spec_treesitter({ a = '@regex.outer', i = '@regex.innner' }),
                    a = miniai.gen_spec.argument({ separator = '[,;]' }),
                    c = spec_treesitter({ a = '@comment.outer', i = '@comment.inner' }),
                    f = spec_treesitter({ a = '@call.outer', i = '@call.inner' }),
                    i = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
                    l = spec_treesitter({ a = '@loop.outer', i = '@loop.inner' }),
                    p = spec_treesitter({ a = '@block.outer', i = '@block.inner' }),
                    r = spec_treesitter({ a = '@return.outer', i = '@return.inner' }),
                    s = spec_treesitter({ a = '@statement.outer', i = '@scopename.inner' }),
                    e = {
                         {
                            "%f[%a]%l+%d*",
                            "%f[%w]%d+",
                            "%f[%u]%u%f[%A]%d*",
                            "%f[%u]%u%l+%d*",
                            "%f[%u]%u%u+%d*",
                          },
                    },
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

            -- add n for next and l for previous for g[] commands
            local map_nextlast_motion = function(lhs, side, search_method)
                local rhs = function()
                    miniai.move_cursor(side, 'a', vim.fn.getcharstr(),
                        { search_method = search_method, n_times = vim.v.count1 })
                end
                local desc = 'Go to ' .. side .. ' side of ' .. search_method .. ' textobject'
                vim.keymap.set({ 'n', 'x', 'o' }, lhs, rhs, { desc = desc })
            end

            map_nextlast_motion('g[n', 'left', 'next')
            map_nextlast_motion('g]n', 'right', 'next')
            map_nextlast_motion('g[l', 'left', 'prev')
            map_nextlast_motion('g]l', 'right', 'prev')
        end
    }
}
