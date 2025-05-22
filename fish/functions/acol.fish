function acol
    if test (count $argv) -eq 0
        echo "Usage: acol COLUMN_NUMBER [COLUMN_NUMBER...]"
        return 1
    end
    
    set print_cols
    for col in $argv
        set -a print_cols "\$$col"
    end
    
    set prog (string join "" "{print " (string join "," $print_cols) "}")
    awk $prog
end
