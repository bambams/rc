# .bash_aliases

# User specific aliases and functions
alias admin='/usr/bin/screen -d -RR -S admin /bin/bash'
alias aptitude='/usr/bin/aptitude -P'
alias cp='/bin/cp -i'
alias irc='/usr/bin/screen -d -RR -S irc /usr/bin/irssi'
alias flashpids="ps aux | grep npviewer.bin | grep -v grep | awk '{print \$2}' | xargs"
alias mv='/bin/mv -i'
alias rm='/bin/rm -i'
alias rot13='/home/bamccaig/bin/rot --13'
alias rot47='/home/bamccaig/bin/rot --47'
alias scheme='/usr/bin/guile'
alias sls='/usr/bin/screen -ls'

