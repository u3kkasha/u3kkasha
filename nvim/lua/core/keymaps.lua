-- بسم الله الرحمن الرحيم
---@diagnostic disable: undefined-global

if vim.g.vscode then
    local vscode = require('vscode')
    local function map(mode, keybinding, actionCommand)
        vim.keymap.set(mode, keybinding, function() vscode.call(actionCommand) end, { silent = true, noremap = true })
    end
    map('n', 'zC', 'editor.foldRecursively')
    map('n', 'zM', 'editor.foldAll')
    map('n', 'zO', 'editor.unfoldRecursively')
    map('n', 'zR', 'editor.unfoldAll')
    map('n', 'za', 'editor.toggleFold')
    map('n', 'zc', 'editor.fold')
    map('n', 'zo', 'editor.unfold')
    map('n', 'zj', 'editor.gotoNextFold')
    map('n', 'zk', 'editor.gotoPreviousFold')
    map('v', 'zf', 'editor.createFoldingRangeFromSelection')

    map({'n', 'v'}, '<leader>c', "workbench.action.openQuickChat")
    map('n', '<leader>z', 'workbench.action.toggleZenMode')
    map('n', '<leader>.', 'breadcrumbs.focusAndSelect')
    map('n', '<leader>o', 'outline.focus')
    map('n', '<leader>f', 'workbench.view.explorer')

    vim.keymap.set({ "n", "x" }, "<leader>r", function()
        vscode.with_insert(function()
            vscode.action("editor.action.refactor")
        end)
    end)

    map('n', ']h', "editor.action.dirtydiff.next")
    map('n', '[h', "editor.action.dirtydiff.previous")
    map('n', '[d', 'editor.action.marker.next')
    map('n', '[d', 'editor.action.marker.prev')
end
