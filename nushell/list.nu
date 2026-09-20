def lsg [path: path = .] {
    ls $path | insert icon {|file|
        let extension = ($file.name | path parse | get extension | str lowercase)
        match $extension {
            "nu" => "🐚",
            "rs" => "🦀", 
            "py" => "🐍",
            "js" => "📜",
            "ts" => "📘",
            "md" => "📝",
            "txt" => "📄",
            "zip" => "📦",
            "pdf" => "📕",
            "toml" => "⚙️",
            "lock" => "🔒",
            _ => { if $file.type == "dir" { "📁" } else { "📄" } }
        }
    } | select icon name type size modified
}
