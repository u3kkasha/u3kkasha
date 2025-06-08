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
            -- ; moves to next one for g[] commands and , moves to previous one
            local miniai = require('mini.ai')

            local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
            local move_cursor = miniai.move_cursor
            miniai.move_cursor = function(side, ai_type, id, opts)
                local function repeatable_move_cursor(inopts)
                    local new_opts = vim.tbl_extend('force', opts, {
                        search_method = inopts.forward and 'next' or 'prev'
                    })
                    move_cursor(side, ai_type, id, new_opts)
                end
                ts_repeat_move.set_last_move(
                    repeatable_move_cursor,
                    { forward = opts.search_method ~= 'prev' and opts.search_method ~= 'cover_or_prev' }
                )
                move_cursor(side, ai_type, id, opts)
            end
            vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
            vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

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

            -- add n for next and p for previous for g[] commands
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
