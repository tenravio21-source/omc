def ex [file: path] {
    let ext = ($file | path parse | get extension | str lowercase)
    match $ext {
        "tar" | "gz" | "bz2" | "xz" => { tar -xvf $file }
        "zip" => { unzip $file }
        "7z"  => { 7z x $file }
        "rar" => { unrar x $file }
        _ => { print $"📂 I don't know how to handle .($ext) files yet!" }
    }
}
