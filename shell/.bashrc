# Init order: homebrew -> path -> completions -> tool hooks -> prompt -> aliases/functions

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]] && ! type brew &>/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Completions
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# zoxide - smarter cd (z/zi commands)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# Prompt
source "$HOME/.local/bin/prompt.sh"

# Aliases
alias ll="ls -la"

# Yazi shell wrapper - changes CWD on exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
