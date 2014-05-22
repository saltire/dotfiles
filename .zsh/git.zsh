
function update_current_git_vars() {
    unset __CURRENT_GIT_BRANCH
    unset __CURRENT_GIT_BRANCH_STATUS
    unset __CURRENT_GIT_BRANCH_IS_DIRTY
    unset __CURRENT_GIT_BRANCH_BEHIND
    unset __CURRENT_GIT_BRANCH_AHEAD

    local st="$(git status 2>/dev/null)"
    if [[ -n "$st" ]]; then
        local -a arr
        arr=(${(f)st})

	# need to check for detached HEAD state
        if [[ $arr[1] =~ 'Not currently on any branch.' ]]; then
            __CURRENT_GIT_BRANCH='no-branch'
        else
            __CURRENT_GIT_BRANCH="${arr[1][(w)3]}";
        fi

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

        if [[ ! $st =~ 'nothing to commit' ]]; then
            __CURRENT_GIT_BRANCH_IS_DIRTY='1'
        
        else
            local staged="$(git diff --staged --name-status 2>/dev/null)"
            local unstaged="$(git diff --name-status 2>/dev/null)"
            local untracked="$(git ls-files --others --exclude-standard 2>/dev/null)"
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
    local s=""
    if [ -n "$__CURRENT_GIT_BRANCH" ]; then
        s+="($__CURRENT_GIT_BRANCH"
        case "$__CURRENT_GIT_BRANCH_STATUS" in
            ahead)
            s+=" ↑$__CURRENT_GIT_BRANCH_AHEAD"
            ;;
            diverged)
            s+=" ↑$__CURRENT_GIT_BRANCH_AHEAD ↓$__CURRENT_GIT_BRANCH_BEHIND"
            ;;
            behind)
            s+=" ↓$__CURRENT_GIT_BRANCH_BEHIND"
            ;;
        esac
        if [ -n "$__CURRENT_GIT_BRANCH_IS_DIRTY" ]; then
            s+=" ⚡"
        fi
        s+=")"

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
