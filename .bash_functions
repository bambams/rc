function abspath
{
    echo "$1" | sed -r 's,^([^/]),'"`pwd`"'/\1,'
}

function args
{
    cat <<-EOF 1>&2;
		Args:
		<<<<<<
		EOF

    local i=1;

    while /bin/true; do
        [ -z "$1" ] && break;
        echo "$i=$1"
        shift;
        /bin/true $(( i++ ))
    done

    cat <<-EOF 1>&2;
		>>>>>>
		EOF
}

function find-js-func
{
    egrep -inR 'function\s+\S*'"$1"'\S*\(' . | grep -v '^Binary';
}

function find-cs-class
{
    egrep -inR '(:?class|struct)\s+\S*'"$1" . | grep -v '^Binary';
}

function find-cs-func
{
    egrep -inR '(:?public|protected|private)\s+\S+\s+\S*'"$1"'\S*\s*\(' . | \
            grep -v '^Binary';
}

function killflash
{
    flashpids=`flashpids`;
    if [ "$flashpids" == "" ]; then
        echo "Can't get flash PIDs... :(" 1>&2;
        return 1;
    fi
    kill -KILL "`flashpids`";
    #killall -q nsplugin
}

function killall
{
    while [ "$1" ]; do
        process="$1"

        if [ "$process" == -f -o "$process" == --force ]; then
            force=1
            continue;
        fi

        psaux="`ps aux | grep "$process" | grep -v grep`";
        pids="`echo "$psaux" | awk '{print $2}' | xargs`";

        echo "$psaux";

        if [ ! "$force" ]; then
            echo "The following PIDs will be KILLed: $pids";
            read -p "Terminate these processes (Y/n) [n] " answer;
            if [ "$answer" == y -o "$answer" == Y ]; then
                echo "KILLing..."
                kill -KILL $pids
            else
                echo "Skipping /$process/";
            fi;
        fi
    done
}

function mkscreen
{
    local add=n

    if [ "$1" == '-a' ]; then
        add=y
        shift;
    fi

    local name=$1;
    shift;
    local command="$*";

    if [ -z "$name" -o -z "$command" ]; then
        echo 'Usage: mkscreen [ -a ] name command

    -a          Add to .bashrc.' 1>&2;
        return 1;
    fi

    if [ $add == y ]; then
        echo "mkscreen $name $command" >> $HOME/.bash_screens;
    fi

    alias $name="/usr/bin/screen -d -RR -S $name $command";

    return 0;
}

function rmscreen
{
    local delete=n

    if [ "$1" == '-d' ]; then
        delete=y
        shift;
    fi

    local name=$1;

    if [ -z "$name" ]; then
        echo 'Usage: rmscreen [ -d ] name

    -d          Delete from .bashrc.' 1>&2;
        return 1;
    fi

    if [ $delete == y ]; then
        sed -i -r "/^mkscreen $name .*/d" $HOME/.bash_screens;
    fi

    unalias $name;

    return 0;
}

function tryperl
{ 
    local answer=y;
    local args=();
    local editor="${TRYPERL_EDITOR:-${EDITOR:-/usr/bin/vim}}";
    local editorargs=(${TRYPERL_EDITORARGS[@]});
    local perl="${TRYPERL_PERL:-/usr/bin/perl}";
    local perlargs=(${TRYPERL_PERLARGS[@]});

    if [ ${#editorargs[@]} == 0 ]; then
        editorargs=(-O);
    fi

    if [ ${#perlargs[@]} == 0 ]; then
        perlargs=(-Mstrict -Mwarnings -MData::Dumper);
    fi

    if [ $1 == -- ]; then
        if grep '^# tryperl: ' "$2" 1>/dev/null; then
            args=(`sed -n -r '/^# tryperl: / s,^# tryperl: (.*),\1,p' "$2"`);
        fi
    fi

    while [ $# -gt 0 -a "$1" != -- ]; do
        args[${#args[@]}]="$1";
        shift;
    done

    if [ $# == 0 ]; then
        cat <<-EOF 1>&2;
			Usage: tryperl [ SCRIPT_ARGS ] -- PROGRAM_FILE [ MODULE_FILE... ]
			EOF
        return 255;
    fi

    shift;

    local program="$1";

    if grep '^# tryperl: ' "$program"; then
        sed -i -r 's,^(# tryperl: ).*,\1'"${args[*]}"',' "$program"
    else
        sed -i -r "2i\
# tryperl: ${args[*]}" "$program"
    fi

    while [ "$answer" == y -o "$answer" == Y ]; do
        "$editor" "${editorargs[@]}" "$@"

        if grep '^# tryperl: ' "$program" 1>/dev/null; then
            args=(`sed -n -r '/^# tryperl: / s,^# tryperl: (.*),\1,p' "$program"`);
        fi

        if [ "$?" == 0 ]; then
            "$perl" "${perlargs[@]}" "$program" "${args[@]}";
        fi

        result=$?;

        read -p 'Again? (Y/n) ' answer;
    done;

    return $result;
}

