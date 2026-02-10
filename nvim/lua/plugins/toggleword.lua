-- بسم الله الرحمن الرحيم

return {
    "iquzart/toggleword.nvim",
    opts = {
        key = "<leader>tt",
        toggle_groups = {
            -- Default boolean toggles
            { "true", "false" },
            { "True", "False" },  -- Python capitalized booleans
            { "on", "off" },
            { "enabled", "disabled" },
            { "yes", "no" },
            { "up", "down" },
            { "start", "stop" },
            { "open", "close" },
            { "allow", "deny" },
            { "accept", "reject" },
            { "read", "write" },
            { "push", "pull" },
            { "inbound", "outbound" },
            { "public", "private" },
            { "online", "offline" },
            { "local", "remote" },
            { "master", "slave" },
            { "primary", "replica" },
            { "active", "passive" },
            { "manual", "automatic" },
            
            -- TypeScript/JavaScript variable declarations (cyclical)
            { "const", "let", "var" },
            
            -- TypeScript/JavaScript/Python common types and keywords
            { "null", "undefined" },  -- JavaScript/TypeScript
            { "None", "null" },       -- Python ⇄ JavaScript
            { "async", "sync" },
            { "import", "export" },
            { "get", "set" },
            { "readonly", "mutable" },
            { "static", "dynamic" },
            
            -- Python specific
            { "and", "or" },
            { "is", "is not" },
            { "in", "not in" },
            
            -- Common programming terms
            { "class", "interface" },
            { "abstract", "concrete" },
            { "min", "max" },
            { "first", "last" },
            { "head", "tail" },
            { "before", "after" },
            { "left", "right" },
            { "top", "bottom" },
            { "input", "output" },
            { "source", "destination" },
            { "horizontal", "vertical" },
            
            -- Environment toggles
            { "prod", "dev" },
            { "production", "development" },
            { "test", "prod" },
        }
    }
}
