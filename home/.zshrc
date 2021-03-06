# Set up the prompt

autoload -Uz promptinit
promptinit
prompt walters

export EDITOR=vim

# make words to be shell words (argv entries), ^W deletes whole arguments
autoload -U select-word-style
select-word-style shell

# Fedora might have vimx, fix the mess
if (( $+commands[vimx] ))
then
  alias vim=vimx
  export EDITOR=vimx
fi

add-zsh-hook precmd precmd_title

settitle() {
    printf "\033k$1\033\\"
}

precmd_title() {
    settitle $HOST
}


ssh() {
    if [ -n "$TMUX" ]; then
        tmux rename-window -t${TMUX_PANE} "${@: -1}"
    fi
    command ssh "$@"
}

# anonymous function to be executed on start and avoid polluting namespace
function () {
  # colourful less by emulating less in vim
  local VIMRUNTIME=`vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|quit' | tr -d '\015' `
  alias less=$VIMRUNTIME/macros/less.sh
}

# check for local OPAM installation
OPAM_LOCATION=~/ocaml/bin
if [ -d $OPAM_LOCATION ]
then
  PATH=$OPAM_LOCATION:$PATH
fi
# if OPAM is installed, load it.
. $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

CABAL_LOCATION=/home/luke/.local/bin/
if [ -d $CABAL_LOCATION ]
then
  PATH=$CABAL_LOCATION:$PATH
fi

# Fedora, https://bugzilla.redhat.com/show_bug.cgi?id=678934
command_not_found_handler () {
        local runcnf=1
        local retval=127
        [ ! -S /var/run/dbus/system_bus_socket ] && local runcnf=0
        [ ! -x /usr/libexec/packagekitd ] && local runcnf=0
        if [ $runcnf -eq 1 ]
        then
                /usr/libexec/pk-command-not-found $@
                local retval=$?
        fi
        return $retval
}

# Use emacs keybindings even if our EDITOR is set to vi
#bindkey -e
# nope
bindkey -v

# change directories using directory names only
unsetopt auto_cd
# push directory onto stack automatically on "cd"
setopt auto_pushd
# extended globbing
setopt extended_glob
# correct misspelled commands
setopt correct
# don't truncate files with redirection >
setopt noclobber
# report background jobs status immediatly
setopt notify
# always hash $PATH before doing completion
setopt hash_list_all
# don't just complete at word end
setopt complete_in_word
# don't kill background jobs at shell exit
setopt nohup
# always newline (avoids clobbering output that is not terminated by newline)
setopt prompt_sp

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# write history immediatly after commands
setopt inc_append_history
# share history between shells
setopt share_history
# write timestamps and duration of commands to history
setopt extended_history
# ignore duplicates
setopt hist_ignore_all_dups hist_save_no_dups hist_find_no_dups
# ignore all commands in history if they start with a space
setopt hist_ignore_space
# strip meaningless blanks from history entries
setopt hist_reduce_blanks
# don't store history commands
setopt hist_no_store

autoload -U is-at-least
if is-at-least 5.0.5; then
	# disable ^ in EXTENDED_GLOB
	disable -p '^'
fi

# magically quote urls when pasting
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# no spelling correction
alias cp='nocorrect cp'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias rm='nocorrect rm'

# colors
alias ls=' ls -a --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

# use ack for ack or ack-grep
(( $+commands[ack-grep] )) && alias ack='ack-grep'

# internet radio
alias somafm='read "?Which station: " && mplayer -quiet -playlist http://somafm.com/startstream=${REPLY}.pls'
alias di='read "?Which station: " && mplayer -quiet -playlist http://listen.di.fm/public3/${REPLY}.pls'

# Clojure standalone nREPL on port 33033 (see related .vimrc)
alias nrepl='lein repl :start :port 33033'

# https://wiki.archlinux.org/index.php/Home_and_End_keys_not_working#Zsh
# gnome-terminal doing strange stuff
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
# omg, gnome-terminal, why do you change these?
# thanks to Ctrl-V special key to figure out what the BOL/EOL code du jour is.
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
# the normal bindings, just for reference
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
# also, unbreak the delete key:
# http://pilif.github.com/2004/10/delete-key-in-zsh/
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char

# enable searching history with globs:
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward

# jump between words with ctrl-arrow
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# search in history prefix with PgUp/PgDown
[[ -n "${terminfo[kpp]}" ]] && bindkey "${terminfo[kpp]}" history-beginning-search-backward
[[ -n "${terminfo[knp]}" ]] && bindkey "${terminfo[knp]}" history-beginning-search-forward

# make ^Z in shell resume last suspended process
#foreground-last() {
#  fg %
#}
#zle -N foreground-last
#bindkey "^Z" foreground-last

fancy-ctrl-z () {
  emulate -LR zsh
  if [[ $#BUFFER -eq 0 ]]; then
    fg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N fancy-ctrl-z
bindkey "^Z" fancy-ctrl-z


# easy way to look up ZSH documentation
zman() {
  PAGER="less -g -s '+/^       "$1"'" man zshall
}

# more stuff? check this:
# http://chneukirchen.org/blog/archive/2008/02/10-zsh-tricks-you-may-not-know.html

# Use modern completion system
autoload -Uz compinit
compinit

# enable colors
autoload -U colors && colors

# complete mosh exactly like SSH
compdef mosh=ssh

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# gentoo prompt theme

source ~/.zsh-git-prompt/zshrc.sh

prompt_gentoo_help () {
  cat <<'EOF'
This prompt is color-scheme-able.  You can invoke it thus:

  prompt gentoo [<promptcolor> [<usercolor> [<rootcolor>]]]

EOF
}

prompt_gentoo_setup () {
  local prompt_gentoo_prompt=${1:-'blue'}
  local prompt_gentoo_user=${2:-'green'}
  local prompt_gentoo_root=${3:-'red'}

  if [ "$USER" = 'root' ]
  then
    local base_prompt="%B%F{$prompt_gentoo_root}%m%k "
  else
    local base_prompt="%B%F{$prompt_gentoo_user}%n@%m%k "
  fi
  local post_prompt="%b%f%k"

  #setopt noxtrace localoptions

  local path_prompt="%B%F{$prompt_gentoo_prompt}%1~%f"
  typeset -g PS1="$base_prompt$path_prompt %# $post_prompt"
  typeset -g PS2="$base_prompt$path_prompt %_> $post_prompt"
  typeset -g PS3="$base_prompt$path_prompt ?# $post_prompt"
  PROMPT=$base_prompt$path_prompt"%b"'$(git_super_status)'"%B%F{$prompt_gentoo_prompt} %# "$post_prompt
}

prompt_gentoo_setup "$@"

export SSH_ASKPASS=/usr/bin/ksshaskpass
alias rdesktop="rdesktop -a 16 -g 1920x1000"

echo "ssh-agent-thing checking ssh-add"
ssh-add -l > /dev/null </dev/null
if [[ $? != 0 ]]; then
	echo "ssh-agent-thing waiting for lock"
	sleep "$(echo "$RANDOM % 100 * 0.01" | bc -q)"
	while test -n "$(find $HOME -maxdepth 1 -name '.ssh-agent-lock*' -print -quit)" ; do
		sleep "$(echo "$RANDOM % 100 * 0.01" | bc -q)"
	done
	locknum=$RANDOM
	touch "$HOME/.ssh-agent-lock$locknum"
	echo "ssh-agent-thing acquired lock"
	pgrep ssh-agent > /dev/null
	ssh_return=$?
	echo "ssh-agent-thing checked pgrep, return: $ssh_return "
	if [[ $ssh_return != 0 ]]; then
		echo "ssh-agent-thing: Found no ssh-agent running"
		setopt clobber
		ssh-agent > $HOME/.ssh-agent-thing
		eval $(<$HOME/.ssh-agent-thing)
		setopt noclobber
	elif [ -f "$HOME/.ssh-agent-thing" ]; then
		echo "ssh-agent-thing: ssh-agent running, evaling ssh-agent-thing"
		eval $(<$HOME/.ssh-agent-thing)
	else
		echo "Cached SSH Agent PID: $SSH_AGENT_PID"
	fi
	rm "$HOME/.ssh-agent-lock$locknum"
fi
source "$HOME/.zshrc.local"
source "$HOME/.zshrc.special"

ssh-add -l >/dev/null </dev/null || alias ssh='ssh-add -l >/dev/null </dev/null || ssh-add </dev/null && unalias ssh; ssh'
ssh-add -l >/dev/null </dev/null || alias mosh='ssh-add -l >/dev/null </dev/null || ssh-add </dev/null && unalias ssh; mosh'

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

alias synon="/home/erlacher/.screenlayout/default.sh; sudo systemctl start synergys@erlacher"
#export PATH="$PATH:$HOME/bin/ApacheDirectoryStudio:$HOME/nasbackup/home/bin"
export LD_PRELOAD="/home/erlacher/scratch/build/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"
alias synoff="sudo systemctl stop synergys@erlacher"
alias synstat="sudo systemctl status synergys@erlacher"
alias pwssh="ssh -o 'PubkeyAuthentication no'"

alias youtube-dl="youtube-dl -f 'bestvideo+bestaudio'"

#npm
export PATH=~/.npm-global/bin:$PATH

# added by travis gem
[ -f /home/luke/.travis/travis.sh ] && source /home/luke/.travis/travis.sh
