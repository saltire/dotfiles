
function update_current_git_vars() {
    unset __CURRENT_GIT_BRANCH
    unset __CURRENT_GIT_BRANCH_STATUS
    unset __CURRENT_GIT_BRANCH_IS_DIRTY
    unset __CURRENT_GIT_BRANCH_BEHIND
    unset __CURRENT_GIT_BRANCH_AHEAD
    unset __CURRENT_GIT_BRANCH_STAGED
    unset __CURRENT_GIT_BRANCH_UNSTAGED
    unset __CURRENT_GIT_BRANCH_UNTRACKED

    local st="$(git status 2>/dev/null)"
    if [[ -n "$st" ]]; then
        local -a arr
        arr=(${(f)st})

        # get current branch

        if [[ $arr[1] =~ 'Not currently on any branch.' ]]; then
            __CURRENT_GIT_BRANCH='no-branch'

        elif [[ $arr[1] =~ 'detached' ]]; then
            __CURRENT_GIT_BRANCH="${arr[1][(w)4]}";

        elif [[ $arr[1] =~ 'On branch' ]]; then
            __CURRENT_GIT_BRANCH="${arr[1][(w)3]}";
        fi

        # count commits current branch is ahead/behind tracked remote branch

        if [[ $arr[2] =~ 'Your branch' ]]; then
            if [[ $arr[2] =~ 'ahead' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='ahead'
                __CURRENT_GIT_BRANCH_AHEAD="${arr[2][(w)8]}"

            elif [[ $arr[2] =~ 'diverged' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='diverged'
                __CURRENT_GIT_BRANCH_AHEAD="${arr[3][(w)3]}"
                __CURRENT_GIT_BRANCH_BEHIND="${arr[3][(w)5]}"

            elif [[ $arr[2] =~ 'behind' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='behind'
                __CURRENT_GIT_BRANCH_BEHIND="${arr[2][(w)7]}"

            else
                __CURRENT_GIT_BRANCH_STATUS='uptodate'
            fi
        fi

        # check if current branch is dirty

        if [[ ! $st =~ 'nothing to commit' ]]; then
            __CURRENT_GIT_BRANCH_IS_DIRTY='1'

            local ch="$(git status -s 2>/dev/null)"

            # count files
            __CURRENT_GIT_BRANCH_STAGED="$(printf "%s\n" "${ch[@]}" | grep -c "^M ")"
            __CURRENT_GIT_BRANCH_UNSTAGED="$(printf "%s\n" "${ch[@]}" | grep -c "^ M")"
            __CURRENT_GIT_BRANCH_UNTRACKED="$(printf "%s\n" "${ch[@]}" | grep -c "^??")"
        fi
    fi
}

function preexec_update_git_vars() {
    case "$1" in
        git*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function prompt_git_info() {
    local colour="%{$fg[red]%}"
    local s=""

    if [ -n "$__CURRENT_GIT_BRANCH" ]; then
        s+="$colour($__CURRENT_GIT_BRANCH"

        case "$__CURRENT_GIT_BRANCH_STATUS" in
            ahead)
            s+=" %{$fg[blue]%}↑$__CURRENT_GIT_BRANCH_AHEAD$colour"
            ;;
            diverged)
            s+=" %{$fg[blue]%}↑$__CURRENT_GIT_BRANCH_AHEAD ↓$__CURRENT_GIT_BRANCH_BEHIND$colour"
            ;;
            behind)
            s+=" ↓$__CURRENT_GIT_BRANCH_BEHIND"
            ;;
        esac

        if [ -n "$__CURRENT_GIT_BRANCH_IS_DIRTY" ]; then
            #s+=" %{$fg[red]%}⚡"

            if [[ "$__CURRENT_GIT_BRANCH_STAGED" != "0" ]]; then
                s+=" %{$fg[green]%}⚡$__CURRENT_GIT_BRANCH_STAGED$colour"
            fi
            if [[ "$__CURRENT_GIT_BRANCH_UNSTAGED" != "0" ]]; then
                s+=" %{$fg[yellow]%}⚡$__CURRENT_GIT_BRANCH_UNSTAGED$colour"
            fi
            if [[ "$__CURRENT_GIT_BRANCH_UNTRACKED" != "0" ]]; then
                s+=" %{$fg[red]%}⚡$__CURRENT_GIT_BRANCH_UNTRACKED$colour"
            fi
        fi

        s+=")%{$fg[default]%}"

        echo "$s\n"
    fi
}

# add functions to zsh hooks
autoload -U add-zsh-hook
add-zsh-hook chpwd update_current_git_vars
add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

# run initial update
update_current_git_vars
