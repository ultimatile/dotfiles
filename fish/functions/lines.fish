function lines
    sed -n "$argv[2],$argv[3]p" $argv[1]
end
