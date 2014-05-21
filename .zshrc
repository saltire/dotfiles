# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install

source ~/.zsh/completion.zsh


# prompt

autoload -U colors && colors # enable colours
setopt prompt_subst # allow functions in prompt

HOST_COLOR=white # override this in the below file
[[ -f ~/.zsh/hostcolor.zsh ]] && source ~/.zsh/hostcolor.zsh

source ~/.zsh/git.zsh

PS1="
%B%n%b@%{$fg_bold[$HOST_COLOR]%}%M%{$reset_color%} %~ %{$fg[red]%}\$(prompt_git_info)%{$fg[default]%}
%(!.#.>) "


# aliases

alias ls='ls -G'
alias ll='ls -al'
