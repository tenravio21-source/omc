#yazi
alias ys = ysearch
alias yr = yremove
alias yc = yclean

# Navigation
alias e = exit
alias . = cd ..
alias .. = cd ../.. 
alias ... = cd ../../..
alias p = pwd

#Editor
alias v = nvim
alias vi = nvims
alias nc = with-env { NVIM_APPNAME: "NvChad" } { ^nvim }
alias nvc = with-env { NVIM_APPNAME: "NvChad" } { neovide }

# Git (Enhanced)
alias gc = git commit -m
alias gp = git push
alias ga = git add .
alias gpl = git pull
alias gs = git status
alias gss = gss  # Use our custom git status
alias gcl = git clone
alias gr = git restore
alias gi = git init
alias gd = git diff 
alias gco = git checkout
alias gb = git branch
alias gl = git log --oneline --graph --all

# Misc Utilities
alias hist = history
alias cls = clear
alias c = clear
alias time = timeit 

# File Operations
alias l = lsd --color always --icon always
alias ll = lsd -l --color always --icon always
alias la = lsd -a --color always --icon always
alias lla = lsd -la --color always --icon always
alias lt = lsd --tree --color always --icon always
# alias cat = ^bat
alias rm-safe = rm -I

# Network
alias ip = ip -c a  # Colorized output
alias ping = ping -c 3
alias wget = wget -c  # Continue interrupted downloads

alias untar = tar -xvf
alias mktar = tar -cvf
