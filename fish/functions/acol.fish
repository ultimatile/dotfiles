function acol
    if test (count $argv) -eq 0
        echo "Usage: f COLUMN_NUMBER"
        return 1
    end
    set col $argv[1]
    set prog (string join "" "{print \$" $col "}")
    awk $prog
end
