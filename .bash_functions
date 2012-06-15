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

function check_git
{
    local d="${1:-.}";
    local status=0;

    pushd "$d" &>/dev/null;

    if [ -d .git ]; then
        git status 2>&1 | grep -i 'working directory clean' &>/dev/null;

        if [ $? != 0 ]; then
            echo "$d: Working directory dirty!" 1>&2;
            (( status++ ));
        fi;
        
        git push --dry-run origin master 2>&1 1>/dev/null |
                grep -i 'everything up-to-date' &>/dev/null;

        if [ $? != 0 -a $? != 128 ]; then
            echo "$d: Unpushed changes!" 1>&2;
            (( status++ ));
        fi
    else
        status=128;
    fi;

    popd &>/dev/null;

    return $status;
}

function check_hg
{
    local d="${1:-.}";
    local status=0;

    pushd "$d" &>/dev/null;

    if [ -d .hg ]; then
        if [ ! -z "`hg status 2>/dev/null`" ]; then
            echo "$d: Working directory dirty!" 1>&2;
            (( status++ ));
        fi;

        if hg out origin &>/dev/null; then
            echo "$d: Unpushed changes!" 1>&2;
            (( status++ ));
        fi

        if hg out &>/dev/null; then
            echo "$d: Unpushed changes!" 1>&2;
            (( status++ ));
        fi
    else
        status=128;
    fi;

    popd &>/dev/null;

    return $status;
}

function check_svn
{
    local d="${1:-.}";
    local status=0;

    pushd "$d" &>/dev/null;

    if [ -d .svn ]; then
        if [ ! -z "`svn status`" ]; then
            echo "$d: Working directory dirty!" 1>&2;
            status=1;
        fi
    else
        status=128;
    fi;
        
    popd &>/dev/null;

    return $status;
}

function check_scms
{
    local i=0;
    local src="${1:-${HOME}/src}";
    local unhappy=0;

    for d in `find "$src" -maxdepth 1 -type d`; do
        local scms=0;
        
        echo "$d:";

        check_git "$d";

        if [ $? != 128 ]; then
            (( scms++ ));
        fi

        if [ $? != 0 -a $? != 128 ]; then
            (( unhappy++ ));
        fi;

        check_hg "$d";

        if [ $? != 128 ]; then
            (( scms++ ));
        fi

        if [ $? != 0 -a $? != 128 ]; then
            (( unhappy++ ));
        fi;

        check_svn "$d";

        if [ $? != 128 ]; then
            (( scms++ ));
        fi

        if [ $? != 0 -a $? != 128 ]; then
            (( unhappy++ ));
        fi;

        if [ $scms == 0 ]; then
            echo "$d: *WARNING*: No SCM in use!";
        else
            echo "$d: SCMS: $scms";
        fi

        echo -e '\n\n\n';

        (( i++ ));
    done;
    
    local happy=$(( i - unhappy ));

    echo ======;
    echo "Total directories checked: $i (Happy: $happy/Unhappy: $unhappy)";
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

function git-out
{
    local git_out_range="`git-out-range "$@"`";

    if [ -z "$git_out_range" ]; then
        return 1;
    fi;
    
    git log $git_out_range;
}

function git-out-range
{
    local remote="${1:-origin}";
    local branch="${2:-master}";

    if ! git remote | grep "^$remote\$" &>/dev/null; then
        echo "'$remote' does not appear to be a remote." 1>&2;
        return 1;
    fi;

    if ! git branch | grep "$branch\$" &>/dev/null; then
        echo "'$branch' does not appear to be a branch." 1>&2;
        return 1;
    fi;

    git push --dry-run "$remote" "$branch" 2>&1 | \
            perl -nE '/(\w+\.\.\w+)/ && say $1';
}

function killflash
{
    flashpids=`flashpids`;
    if [ "$flashpids" == "" ]; then
        echo "Can't get flash PIDs... :(" 1>&2;
        return 1;
    fi
    kill -KILL `flashpids`;
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
    local replace=n

    if [ "$1" == '-a' ]; then
        add=y
        shift;
    elif [ "$1" == '-r' ]; then
        replace=y
        shift;
    fi

    local name=$1;
    shift;
    local command="$*";

    if [ -z "$name" -o -z "$command" ]; then
        echo 'Usage: mkscreen [ -a | -r ] name command

    -a          Add to .bashrc.
    
    -r          Replace screen in .bashrc.' 1>&2;
        return 1;
    fi

    if [ $add == y ]; then
        echo "mkscreen $name $command" >> $HOME/.bash_screens;
    elif [ $replace == y ]; then
        sed -i -r "/mkscreen $name / s/mkscreen $name (.*)/\
mkscreen $name $command/" $HOME/.bash_screens;
    fi

    alias $name="/usr/bin/screen -d -RR -S $name -U $command";

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

function ssh-agent-setup
{
    local ssh_agent=/usr/bin/ssh-agent;
    local ssh_agent_args=(-s);
    local ssh_agent_env=~/.ssh_agent_env;

    eval set -- $(getopt \
            -l agent:,env:,help \
            -n ssh-agent-setup \
            -o A:E:h -- "$@");

    while true; do
        case "$1" in
            -A|--agent) ssh_agent="$2"; shift 2;;
            -E|--env) ssh_agent_env="$2"; shift 2;;
            -h|--help) cat <<EOF 1>&2; return 0;;
Usage:
    ssh-agent-setup { -h | --help }
    ssh-agent-setup [ -A | --agent=FILE ] [ -E | --env-file=FILE ] ARGS...

        -A, --agent=FILE    Specify ssh-agent executable
                            (default: /usr/bin/ssh-agent)

        -E, --env           Specify file with agent environment. This
                            file should be source-able by the shell
                            (i.e., bash) and should set the necessary
                            variables. The file should have its
                            permissions set to 0600. ssh-agent-env tries
                            to reset this each time the file is
                            created. (default: ~/.ssh_agent_env)

        -h, --help          Show this message and exit success.
EOF
            --) shift; break ;;
        esac;
    done;

    ssh_agent_args=("${ssh_agent_args[@]}" "$@");

    if [ -f "$ssh_agent_env" ]; then
        source "$ssh_agent_env";
    fi;
    if [ -z "$SSH_AGENT_PID" ] ||
            ! ps "$SSH_AGENT_PID" 2>/dev/null | \
            grep ssh-agent &>/dev/null; then
        if [ -x "$ssh_agent" ]; then
            "$ssh_agent" "${ssh_agent_args[@]}" |
                    sed -r 's/^echo/#echo/' 1> "$ssh_agent_env";
            chmod 600 "$ssh_agent_env";
            source "$ssh_agent_env";
            trap "kill $SSH_AGENT_PID" 0;
        fi;
    fi;
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

