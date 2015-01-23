# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install


# vars

export EDITOR=nano


# paths

export GEM_HOME=$(ruby -rubygems -e "puts Gem.user_dir")
export NPM_PACKAGES="${HOME}/.npm-packages"

export PATH="$PATH:$GEM_HOME/bin:$NPM_PACKAGES/bin"

unset MANPATH
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"


# aliases

alias ls='ls -F --color=auto --group-directories-first'
alias ll='ls -al'


# other source files

source ~/.zsh/completion.zsh
source ~/.zsh/keys.zsh


# prompt

autoload -U colors && colors # enable colours
setopt prompt_subst # allow functions in prompt

eval `dircolors ~/.dir_colors`

HOST_COLOR=white # override this in the below file
[[ -f ~/.zsh/hostcolor.zsh ]] && source ~/.zsh/hostcolor.zsh

source ~/.zsh/git.zsh

PS1="
%B%n%b@%{$fg_bold[$HOST_COLOR]%}%M%{$reset_color%} %~ \$(prompt_git_info)
%(!.#.>) "
