# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/marcus/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U colors && colors

source ~/.zsh/git.zsh

PROMPT_COLOR=yellow
PS1="
$fg_bold[$PROMPT_COLOR]%n$reset_color@$fg_bold[$PROMPT_COLOR]%M $reset_color%~ $fg[red]\$(prompt_git_info)$reset_color
%(!.#.>) "

alias ls='ls -G'
alias ll='ls -al'
