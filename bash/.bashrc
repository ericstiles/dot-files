echo 'Loading .bashrc'

# shopt -q login_shell
# if [[ "$?" == "0" ]]; then
# echo "bash_secrets"
  if [[ -x /usr/libexec/path_helper ]]; then
    echo 'Nuking login shell path'
    PATH=""
    eval `/usr/libexec/path_helper -s`
  fi
# fi

if [[ -r ~/.bash_secrets ]]; then
  . ~/.bash_secrets
fi

echo "PATH"
echo $PATH

export SANDBOX_REPO=~/repo/sandbox/estiles
if [ -r "${SANDBOX_REPO}/bash/.bash_aliases" ]; then
  . ${SANDBOX_REPO}/bash/.bash_aliases
fi

if [ -r "${SANDBOX_REPO}/bash/.common_aliases" ]; then
  . ${SANDBOX_REPO}/bash/.common_aliases
fi

if [ -r "${SANDBOX_REPO}/bash/.bash_functions" ]; then
  . ${SANDBOX_REPO}/bash/.bash_functions
fi

if [ -r "${SANDBOX_REPO}/bash/.bash_tmp_functions" ]; then
  . ${SANDBOX_REPO}/bash/.bash_tmp_functions
fi

if [ -r "${SANDBOX_REPO}/bash/.bash_kafka" ]; then
  . ${SANDBOX_REPO}/bash/.bash_kafka
fi

if [ -r "${SANDBOX_REPO}/bash/.bash_aws" ]; then
  . ${SANDBOX_REPO}/bash/.bash_aws
fi

if [ -r "${SANDBOX_REPO}/bash/.bash_postgres" ]; then
  . ${SANDBOX_REPO}/bash/.bash_postgres
fi

if [[ "$(ssh-add -l)" == "The agent has no identities." ]]; then
  ssh-add ~/.ssh/prometheus_rsa_stg
  ssh-add ~/.ssh/prometheus_rsa_prd
fi

################################
#                              #
#    Environment Variables     #
#                              #
################################
export SELECT_UTILS_HOME=~/opt/select-utils

################################
#                              #
#            PATH              #
#                              #
################################
#export PATH=$PATH:~/repo/docker-utils
#Add path for docker utils github project
export PATH=${SELECT_UTILS_HOME}/bin:$PATH
export PATH="$(go env GOPATH)/bin:$PATH"

#Using requires attaching process before JVM will continue
export JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"

export JAVA_HOME="/usr/local/Cellar/openjdk@8/1.8.0+322/libexec/openjdk.jdk/Contents/Home"

#export PATH=$PATH:~/bin/select-utils/kinesis
export HISTTIMEFORMAT="%m/%d/%y %T "
export HISTSIZE=16000

#added for python3 fundamentals class
#export PATH=$PATH:~/anaconda3/condabin


################################
#                              #
# jenv switches java -versions #
#                              #
################################
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

#export PATH=~/java//jdk-11.0.8+10/Contents/Home/bin:$PATH

################################
#                              #
#            PS1               #
#                              #
################################
function git-branch-prompt() {
  curr_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "$?" == "0" ]; then
    echo -n " [$curr_branch]"
  else
    echo -n ''
  fi
}

function aws-vault-prompt() {
  if [ "$AWS_VAULT" == "" ]; then
    echo -n ''
  else
    echo -n " [${AWS_VAULT}]"
  fi
}

function pg-prompt() {
  if [ "$PG_ENV" == "" ]; then
    echo -n ''
  else
    echo -n " [$PG_ENV]"
  fi
}

function k-prompt() {
  if [ "$K_ENV" == "" ]; then
    echo -n ''
  else
    echo -n " [$K_ENV]"
  fi
}

function newline-prompt() {
    #working to add newline if PS1 is too long
    printf "\n$ "
}

source ~/.git-completion.bash
source ~/bin/.maven_bash_completion.bash

#Original PS1
#export PS1='\h:\W \u\$'
export PS1='\u: \[\033[38;5;13m\]\w\[\033[00m\]\[\033[0;33m\]$(git-branch-prompt)\[\033[38;5;182m\]$(aws-vault-prompt)\[\033[0;91m\]$(pg-prompt)\[\033[00m\]\[\033[38;5;33m\]$(k-prompt)\[\033[00m\]$(newline-prompt)'


export PATH="/usr/local/sbin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
