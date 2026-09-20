# custom search
def ysearch [] {
    let selection = (
        yay -Slq 
        | fzf --multi --ansi --preview-window=right:60% 
          --header "TAB: select, ENTER: install" 
          --preview "yay -Si {1} | bat --language=yaml --color=always"
    )
    
    if ($selection | is-not-empty) {
        let targets = ($selection | lines)
        yay -S ...$targets
    }
}

def yremove [] {
    let selection = (
        # -Qq lists only installed packages (Quietly)
        pacman -Qq 
        | fzf --multi --ansi 
          --header "TAB: select, ENTER: remove, ESC: cancel" 
          --preview "pacman -Qi {1} | bat --language=yaml --color=always"
    )
    
    if ($selection | is-not-empty) {
        let targets = ($selection | lines)
        # -Rs removes the package and its unused dependencies
        sudo pacman -Rs ...$targets
    }
}

def yclean [] {
    print "🧹 Starting system cleanup..."
    
    # 1. Remove all but the last 3 versions of installed packages
    # This keeps you safe in case you need to downgrade.
    print "-> Cleaning package cache (keeping last 3)..."
    sudo paccache -r

    # 2. Remove all cached versions of UNINSTALLED packages
    print "-> Removing cache of uninstalled packages..."
    sudo paccache -ruk0

    # 3. Optional: Clean yay's build cache
    print "-> Cleaning yay build cache..."
    yay -Sc --noconfirm

    print "✅ System cleaned!"
}
