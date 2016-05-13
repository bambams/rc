function source.d
{
    local name="";

    if [ ! -z "$1" ]; then
        name=".$1";
    fi;

    for f in `find -L "$HOME/.bash.d$name" -type f | sort`; do
        source "$f";
    done;
}
