function backup --description 'Copy each FILE to FILE.bak'
    if not set -q argv[1]
        echo 'usage: backup FILE...' >&2
        return 2
    end
    for file in $argv
        cp -- $file $file.bak; or return
    end
end
