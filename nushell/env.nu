# Cargo
$env.PATH = ($env.PATH | append ([ $env.HOME .cargo bin ] | path join))

# Zoxide
zoxide init nushell | save -f ~/.zoxide.nu

# Neovim
$env.PATH = ($env.PATH | append '/opt/nvim/bin')
