def gss [] {
    git status -s 
    | lines 
    | each {|line|
        # Git status -s uses exactly 2 characters for status
        let status = ($line | str substring 0..1 | str trim)
        let file = ($line | str substring 3..)
        
        match $status {
            "M"  => { $"(ansi green_bold)modified:(ansi reset) ($file)" }
            "A"  => { $"(ansi yellow_bold)   added:(ansi reset) ($file)" }
            "D"  => { $"(ansi red_bold) deleted:(ansi reset) ($file)" }
            "??" => { $"(ansi blue_bold)     new:(ansi reset) ($file)" }
            _    => { $line }
        }
    }
}
