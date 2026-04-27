# → dir (branch *) $
# $ turns red on non-zero exit. ANSI colors adapt to Modus light/dark theme.

_git_info() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    git diff --quiet --ignore-submodules HEAD 2>/dev/null \
        && echo " ($branch)" \
        || echo " ($branch *)"
}

if [ -n "$ZSH_VERSION" ]; then
    autoload -Uz add-zsh-hook
    setopt PROMPT_SUBST

    _prompt() { _GIT_INFO=$(_git_info); }
    add-zsh-hook precmd _prompt

    PROMPT='→ %F{blue}%c%f${_GIT_INFO} %(?:$ :%F{red}$%f )'

elif [ -n "$BASH_VERSION" ]; then
    _prompt() {
        local exit_code=$? dollar
        [ $exit_code -eq 0 ] \
            && dollar='$' \
            || dollar='\[\033[0;31m\]$\[\033[0m\]'
        PS1='→ \[\033[0;34m\]\W\[\033[0m\]'"$(_git_info) ${dollar} "
    }
    PROMPT_COMMAND='_prompt'
fi
