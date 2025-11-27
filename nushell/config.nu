#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.config.buffer_editor = "code"
$env.config.show_banner = false
$env.config.edit_mode = 'vi'
# argc-completions
$env.ARGC_COMPLETIONS_ROOT = 'C:\Users\USER\argc-completions'
$env.ARGC_COMPLETIONS_PATH = ($env.ARGC_COMPLETIONS_ROOT + '\completions\windows;' + $env.ARGC_COMPLETIONS_ROOT + '\completions')
$env.Path = ($env.Path | prepend ($env.ARGC_COMPLETIONS_ROOT + '\bin'))
argc --argc-completions nushell | save -f 'C:\Users\USER\argc-completions\tmp\argc-completions.nu'
source 'C:\Users\USER\argc-completions\tmp\argc-completions.nu'
# television
mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")

# Delete all git branches except the current one and those specified
#
# This command identifies all local branches and deletes them, preserving
# only the current branch and any additional branches provided as arguments.
def "git-delete-except" [
    ...keep: string # Branches to keep
]: nothing -> list<string> {
    let current: string = (git branch --show-current | str trim)
    let protected: list<string> = ($keep | append $current | uniq)
    
    git branch --format "%(refname:short)" 
    | lines 
    | str trim 
    | where ($it not-in $protected) 
    | each {|branch| 
        git branch -D $branch 
    }
}
