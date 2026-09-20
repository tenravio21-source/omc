# Place this in your config.nu
def nvims [...args] {
    let items = ["default", "kickstart", "LazyVim", "NvChad", "AstroNvim"]
    
    # Generate the menu using fzf
    let selection = ($items | str join "\n" | ^fzf --prompt=" Neovim Config  " --height=50% --layout=reverse --border --exit-0 | str trim)

    # 1. Handle "Cancel" (ESC or Ctrl-C in fzf)
    if ($selection | is-empty) {
        print "Nothing selected"
        return
    }

    # 2. Logic Branching (This stops the "bat" error!)
    if $selection == "default" {
        # Run standard nvim without setting NVIM_APPNAME
        ^nvim ...$args
    } else {
        # Set the environment variable only for this specific run
        with-env { NVIM_APPNAME: $selection } {
            ^nvim ...$args
        }
    }
}

# Add your quick-launch aliases too (Nushell style)
alias nvim-lazy = with-env { NVIM_APPNAME: "LazyVim" } { ^nvim }
alias nvim-kick = with-env { NVIM_APPNAME: "kickstart" } { ^nvim }
alias nvim-chad = with-env { NVIM_APPNAME: "NvChad" } { ^nvim }
alias nvim-astro = with-env { NVIM_APPNAME: "AstroNvim" } { ^nvim }
