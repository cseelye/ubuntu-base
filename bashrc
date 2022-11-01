# --------------------------------------------------------------
# History options
# --------------------------------------------------------------
# append to the history file, don't overwrite it
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%m-%d %T  "
HISTCONTOL=ignoredups


# --------------------------------------------------------------
# Shell/window options
# --------------------------------------------------------------
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# Turn off Ctrl + s XOFF (XON is Ctrl + q)
stty ixany
stty ixoff -ixon
stty stop undef
stty start undef

# Tab size in the terminal
tabs -4

# --------------------------------------------------------------
# Aliases
# --------------------------------------------------------------
alias ll='ls -lF'
alias ls='ls --color=auto'
alias less='less -R'

# --------------------------------------------------------------
# virtualenvwrapper
# --------------------------------------------------------------
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=/root/.local/bin/virtualenv
source /root/.local/bin/virtualenvwrapper.sh 2>/dev/null || true

# --------------------------------------------------------------
# Prompt configuration
# --------------------------------------------------------------
# Color Variables
COLOR_ESC="\033["
COLOR_OFF="${COLOR_ESC}0m"
COLOR_BOLD="${COLOR_ESC}1m"
COLOR_FAINT="${COLOR_ESC}2m"
RESET="\033[39;49;00m"
BLACK="${COLOR_ESC}30m$COLOR_BOLD"
RED="${COLOR_ESC}31m$COLOR_BOLD"
GREEN="${COLOR_ESC}32m$COLOR_BOLD"
YELLOW="${COLOR_ESC}33m$COLOR_BOLD"
BLUE="${COLOR_ESC}34m$COLOR_BOLD"
MAGENTA="${COLOR_ESC}35m$COLOR_BOLD"
CYAN="${COLOR_ESC}36m$COLOR_BOLD"
WHITE="${COLOR_ESC}37m$COLOR_BOLD"

PS1="${YELLOW}devcontainer $COLOR_OFF\h \[$WHITE\]\w"
export PROMPT_COMMAND="
_RES=\${PIPESTATUS[*]};
_RES_RC=0;
for res in \$_RES; do
    if [[ ( \$res > 0 ) ]]; then
    _RES_RC=1;
        break;
    fi;
done;
"
export PS1="$PS1\`if [ \$_RES_RC = 0 ]; then echo \[$GREEN\] ; else echo \[$RED\] [\$_RES_RC]; fi\` # \[$COLOR_OFF\]"
