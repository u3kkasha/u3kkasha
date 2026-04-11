$env.config.buffer_editor = "nvim" 
$env.config.show_banner = false
$env.config.edit_mode = 'vi'

# Starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Television TUI
mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")

# Zoxide
source ~/.zoxide.nu
