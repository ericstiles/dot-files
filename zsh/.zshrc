

# if [[ -n $SSH_CONNECTION ]]; then
   set -o vi
# else
#   export EDITOR='mvim'
# fi

# REPOSITORY_DIR is exported by .zsh_env (sourced from .zshenv, which always
# runs before .zshrc)
if [ -r "${REPOSITORY_DIR}/common/.common_functions" ]; then
  . ${REPOSITORY_DIR}/common/.common_functions
fi

if [ -r "${REPOSITORY_DIR}/common/.common_aliases" ]; then
  . ${REPOSITORY_DIR}/common/.common_aliases
fi

if [ -r "${REPOSITORY_DIR}/zsh/.zsh_aliases" ]; then
  . ${REPOSITORY_DIR}/zsh/.zsh_aliases
fi

#Youtube DLP variables
#export YT_ID=UC53mbhibbibQCKq0nov5AlA

source /opt/homebrew/opt/git-extras/share/git-extras/git-extras-completion.zsh

#direnv
eval "$(direnv hook zsh)"

#function parse_git_branch() {
#    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
#}

#COLOR_DEF=$'%f'
#COLOR_USR=$'%F{243}'
#COLOR_DIR=$'%F{197}'
#COLOR_GIT=$'%F{39}'
#setopt PROMPT_SUBST
#export PROMPT='${COLOR_USR}%n ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF} $ '

source ~/.zsh_functions
setopt PROMPT_SUBST
RPROMPT=''
PROMPT='%~ $(parse_git_branch)
%(?.%F{green}.%F{red})$%f '
function keep (){
  mv ./data/tags/${1}.json ./data/keep/
}

function old () {
 mv ./data/tags/${1}.json ./data/old/
}


# terminal settings are vim. use bindkey -e for emacs
bindkey -v

# Disable the audible/visual bell (e.g. Esc with nothing to do, no tab-complete match)
unsetopt BEEP

# Cursor shape + color by vi keymap (WezTerm, Tokyo Night palette). Guarded
# behind an interactive+TTY check so these never get defined in a
# non-interactive shell — Claude Code's Bash tool captures a snapshot of
# this file's functions and replays it in short-lived subshells, and an
# unguarded `zshexit` would fire (and leak its escape codes into tool
# output) on every one of those subshells' exit, not just real terminal
# sessions.
if [[ -o interactive && -t 1 ]]; then
# `set -o vi` / `bindkey -v` above switch zsh's line editor into vi-style
# Normal/Insert keymaps but give no visual cue which one you're in. This
# mirrors the t_SI/t_SR/t_EI cursor settings in ~/.vimrc: zle-keymap-select
# fires whenever the keymap changes, so we send the same DECSCUSR (shape)
# and OSC 12 (color) escape codes zsh-side.
function zle-keymap-select {
  # zsh's vi-mode has no separate "Replace" keymap - pressing R for
  # overwrite stays in the viins keymap, so $ZLE_STATE (which reports
  # insert vs overwrite) is checked to tell the two apart. Visual mode
  # is handled separately below: $KEYMAP stays "vicmd" the whole time
  # you're selecting text, it never actually reports "visual" here.
  if [[ $KEYMAP == vicmd ]]; then
    print -n '\e[1 q\e]12;#7aa2f7\x07'          # Normal: blinking block, blue
  elif [[ $ZLE_STATE == *overwrite* ]]; then
    print -n '\e[1 q\e]12;#f7768e\x07'          # Replace: blinking block, red
  else
    print -n '\e[1 q\e]12;#a9b1d6\x07'          # Insert: blinking block, light gray
  fi
}
zle -N zle-keymap-select

# Visual mode: intercept v/V directly rather than relying on $KEYMAP (it
# never switches to "visual" for zle-keymap-select), paint purple, then
# hand off to the real widget. Exiting back to Normal via Esc still fires
# zle-keymap-select normally above, so the cursor returns to blue on its own.
function my-visual-mode {
  print -n '\e[1 q\e]12;#bb9af7\x07'            # Visual: blinking block, purple
  zle .visual-mode
}
zle -N my-visual-mode
bindkey -M vicmd 'v' my-visual-mode

function my-visual-line-mode {
  print -n '\e[1 q\e]12;#bb9af7\x07'            # Visual line: blinking block, purple
  zle .visual-line-mode
}
zle -N my-visual-line-mode
bindkey -M vicmd 'V' my-visual-line-mode

# New prompt line always starts in Insert keymap; match the cursor to it.
function zle-line-init {
  zle -K viins
  print -n '\e[1 q\e]12;#a9b1d6\x07'
}
zle -N zle-line-init

# Reset cursor to the default color when the shell exits.
zshexit() {
  print -n '\e[2 q\e]12;#c0caf5\x07'
}
fi


#NeoVim/nvim
alias lazy='nvim ~/.config/nvim/lua/config/lazy.lua'

alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias nk=nvim-kickstart

alias nvim-python='NVIM_APPNAME="nvim-python" nvim'
alias npy=nvim-python

alias nvim-python2='NVIM_APPNAME="nvim-python2" nvim'
alias np2=nvim-python2

# MCP/LM Studio/Antigravity/local-bin/ANDROID_HOME PATH additions live in
# .zsh_env now (sourced from .zshenv, always runs before .zshrc)
#export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
#export JAVA_HOME="/opt/homebrew/Cellar/openjdk@17/17.0.18/libexec/openjdk.jdk/Contents/Home"

# Conventional commit scripts
alias feat='/Users/wilder/repo/pre-commit-scripts/scripts/feat'
alias fix='/Users/wilder/repo/pre-commit-scripts/scripts/fix'
alias chore='/Users/wilder/repo/pre-commit-scripts/scripts/chore'
alias docs='/Users/wilder/repo/pre-commit-scripts/scripts/docs'
alias ci='/Users/wilder/repo/pre-commit-scripts/scripts/ci'
alias build='/Users/wilder/repo/pre-commit-scripts/scripts/build'
alias perf='/Users/wilder/repo/pre-commit-scripts/scripts/perf'
alias refactor='/Users/wilder/repo/pre-commit-scripts/scripts/refactor'
alias revert='/Users/wilder/repo/pre-commit-scripts/scripts/revert'
alias style='/Users/wilder/repo/pre-commit-scripts/scripts/style'
alias tst='/Users/wilder/repo/pre-commit-scripts/scripts/tst'
alias cc='/Users/wilder/repo/pre-commit-scripts/scripts/cc'

alias 1pass='cat ~/.1pass_secret | pbcopy'



alias da='direnv allow'
alias cl='claude'


# For tabbing commands 
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit

# OpenClaw Completion
source "/Users/wilder/.openclaw/completions/openclaw.zsh"

# Disable bracketed paste mode (prevents È...É wrapping around pasted text in tmux)
unset zle_bracketed_paste


alias g=git
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias gcl="git clone"
alias ww='cd /Users/wilder/repo/spec-kit/ww-app-claude'
alias main='git switch main'
alias master='git switch master'
alias back='git switch -'
alias gl1='git log -1'
alias gl2='git log -2'
alias gl3='git log -3'


alias goid='cat ~/.goid_secret | pbcopy'
alias nuid='cat ~/.nuid_secret | pbcopy'

alias t=tmux


function prt () {

  pandoc ${1} -s -H <(echo '<style>body{max-width:100%; padding:25px;} body>*:first-child{margin-top:0;}</style>') -o /tmp/${1}.html && open /tmp/${1}.html

}



[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
