# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

alias lg='lazygit'

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Custom configurations
export REPOSITORY_DIR=~/repo/dot-files

if [[ -r "~/.secrets" ]]; then
  . ~/.secrets
fi

if [ -r "${REPOSITORY_DIR}/zsh/.zsh_aliases" ]; then
  . ${REPOSITORY_DIR}/zsh/.zsh_aliases
fi

if [ -r "${REPOSITORY_DIR}/zsh/.zsh_aliases" ]; then
  . ${REPOSITORY_DIR}/zsh/.zsh_aliases
fi

if [ -r "${REPOSITORY_DIR}/common/.common_functions" ]; then
  . ${REPOSITORY_DIR}/common/.common_functions
fi

if [ -r "${REPOSITORY_DIR}/common/.common_aliases" ]; then
  . ${REPOSITORY_DIR}/common/.common_aliases
fi

#brew
export PATH="/opt/homebrew/bin:$PATH"

#Youtube DLP variables
export YT_ID=UC53mbhibbibQCKq0nov5AlA
export YT_CC='--cookies-from-browser chrome'
export YT_WL_URL=https://www.youtube.com/playlist?list=WL

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



eval "$(starship init zsh)"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

function keep (){

  mv ./data/tags/${1}.json ./data/keep/

}

function old () {

 mv ./data/tags/${1}.json ./data/old/

}


# terminal settings are vim. use bindkey -e for emacs
bindkey -v


alias lazy='nvim ~/.config/nvim/lua/config/lazy.lua'

alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias nk=nvim-kickstart

PATH=~/repo/mcp/local-mcp-management:$PATH
