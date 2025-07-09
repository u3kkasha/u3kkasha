-- بسم الله الرحمن الرحيم

if vim.g.vscode then
    local vscode = require('vscode')
    local function map(mode, keybinding, actionCommand)
        vim.keymap.set(mode, keybinding, function() vscode.call(actionCommand) end, { silent = true, noremap = true })
    end

    local openOil = vscode.to_op(function(ctx)
    vscode.eval_async(
        [[
            return await vscode.window.createTerminal({
            name: `yazi`,
            shellPath: `powershell`,
            shellArgs: ['yazi', args.path],
            location: { viewColumn: -2 }
            })
        ]],
        { args = { path = vscode.eval('return vscode.window.activeTextEditor.document.fileName') .. '\\..' } }
    )
    end)
    vim.keymap.set("n", "-", openOil, { expr = true })

    -- Folding
    map('n', '[z', 'editor.gotoParentFold')
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

    -- Actions
    map('n', '<leader>m', "bookmarks.toggleLabeled")
    map('n', "<leader>'", 'bookmarks.listFromAllFiles')
    map('n', '<leader>c', "workbench.action.openQuickChat")
    map('n', 'g?', 'editor.action.inlineSuggest.trigger')
    map('n', '<tab>', 'editor.action.inlineSuggest.commit')
    map({'n', 'v'}, '<leader>i', "inlineChat.start")
    map('n', '<leader>.', 'breadcrumbs.focusAndSelect')
    map('n', '<leader>o', 'outline.focus')
    map('n', '<leader>f', 'workbench.view.explorer')
    vim.keymap.set({ "n", "x" }, "<leader>r", function()
        vscode.with_insert(function()
            vscode.action("editor.action.refactor")
        end)
    end)
    map({'n', 'v'}, '<leader>ss', 'git.stageSelectedRanges')

    -- Navigation
    map('n', '[h', "editor.action.dirtydiff.previous")
    map('n', ']h', "editor.action.dirtydiff.next")
    map('n', '[H', 'chatEditor.action.navigatePrevious')
    map('n', ']H', 'chatEditor.action.navigateNext')
    map('n', '[d', 'editor.action.marker.prev')
    map('n', ']d', 'editor.action.marker.next')
end
