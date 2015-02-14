bash.d() {
    case "$1" in
        complete)
            export BASH_D_INIT=1;
            ;;
        loaded)
            [[ $BASH_D_INIT == 1 ]];
            ;;
        *)
            echo 'Unknown command.' 1>&2;
            return 1;
            ;;
    esac;
};

# vim: ft=sh
