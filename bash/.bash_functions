echo "Loading functions"


function realsympath(){
  if [ -z $1 ]
  then
    echo "Requires executable name"
    exit 1
  fi

  dirname $(realpath $(which $1))

}


#function gorm(){
#  if [ -z $1 ]
#  then
#    echo "Requires jira 3 digit ticket number as argument"
#    exit 1
#  fi
#  hash="$(git log --pretty=format:"%h %s" | grep -i worm-$1 | cut -d ' ' -f 1)"
#  git show $hash
#}

# Why the below
function update_provider(){
  if [ $# -ne 2 ]; then
    echo 1>&2 "$0: expects two arguments: first is current version, second is new version"
    exit 1
  fi
}

function hclfind(){
  if [ -z ${1+x} ]; then 
    echo "Usage: hclfind [search variable] (in current directory and subs)"; 
  else 
    echo "search variable in hcl files set to '$1'";
    find . -iname "*.hcl" -not -path "*/\.terragrunt-cache/*" -exec grep -iHrn "$1" {} \; 
  fi
}

function mcd(){
  if [ -z "$1" ]; then
   echo "Usage: mcd [directory name] to make and cd into it"
   exit 1
  fi
  mkdir $1 && cd $1
}

function jto() {
  if [ -z "$JAVA_TOOL_OPTIONS" ]; then
    export JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"
    echo 'setting $JAVA_TOOL_OPTIONS:'$JAVA_TOOL_OPTIONS
  else
    echo 'unsetting $JAVA_TOOL_OPTIONS:'$JAVA_TOOL_OPTIONS
    unset JAVA_TOOL_OPTIONS
  fi
}


function cd-prd() {
    cd $(echo $PWD | sed 's/stg/prd/g')
}

function cd-stg() {
    cd $(echo $PWD | sed 's/prd/stg/g')
}

#function terragrunt() {
#    echo 'Running terragrunt function'
#    terragrunt.sh $*
#}

##############################
#                            #
#  check if commit deployed  #
#                            #
##############################
function deployed() {
    if [ "$#" -ne "4" ]; then
        echo "deployed <name> <deployed-versions> <jq-path> <git-sha>"
        return 1
    fi
    name=$1
    dvs=$2
    jqpath=$3
    gitsha=$4
    current=$(echo "$dvs" | jq -r "$jqpath")
    result=$(git until $gitsha | grep $current)
    if [ "$?" -ne "0" ]; then
        echo -e "\e[91mCommit $gitsha not deployed to $name\e[39m"
        return 1
    else
        echo -e "\e[92mCommit $gitsha is deployed to $name\e[39m - $result"
        return 0
    fi
}
function is-deployed() {
    if [ "$#" -ne "1" ]; then
        echo "is-deployed <git-sha>"
        return 1
    fi
    dvs=$(curl -s https://fnx8madbrf.execute-api.us-east-1.amazonaws.com/default/version)
    deployed "stg-api" "$dvs" '.stg.api["git-sha"]' "$1"
    deployed "stg-ingest" "$dvs" '.stg.ingest["git-sha"]' "$1"
    deployed "stg-materialize" "$dvs" '.stg.materialize["git-sha"]' "$1"
    deployed "prd-api" "$dvs" '.prd.api["git-sha"]' "$1"
    deployed "prd-ingest" "$dvs" '.prd.ingest["git-sha"]' "$1"
    deployed "prd-materialize" "$dvs" '.prd.materialize["git-sha"]' "$1"
}

#################
#               #
#      git      #
#               #
#################
function delete_local_branches(){
exit
git branch -lvv | awk '{if ($0 ~ /^(\*)/ ) {next;} ;print}' | awk '!/worm-348/{print }'  |  awk '{print $1}' | xargs git branch -D
}

function glg(){
if [[ -z "${1}" ]]; then
  echo "usage: glg [search string] <git log options: -p>"
  return 1
fi
git log --grep="${1}" "${@:2}"
}


function git-done() {
    curr_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$curr_branch" == "master" ]; then
      echo "Cannot delete branch master"
      git pull
      return 1
    fi
    git checkout master
    git branch -d $curr_branch
    if [ "$?" -ne "0" ]; then
      echo -n "Confirm delete branch $curr_branch? (y/N) "
      read confirm
      if [ "$confirm" == "y" ]; then
        git branch -D $curr_branch
      else
        echo "OK then..."
      fi
    fi
    git pull
}


#function change-notify() {
#  #TYPE=$1
#  ID=$1
#  DATA="{\"type\": \"product\",\"id\": "$ID",\"productId\": "$ID",\"timestamp\": \"1234567654\",\"bulkPath\": \"false\"}"
#  echo $DATA
# curl --verbose -H "Content-type:application/json" -d "${DATA}" "http://10.207.67.155:8080/change-notify/sns"
#}

#Set local vars to run api, ingest or materialize
function set-local-vars(){
localhost-ro.localdomain
 export UNIQUE_NAME_PREFIX=""
 export ENVIRONMENT_NAME=""
 export SENTRY_DSN=""
 export DDB_ERROR_QUEUE_NAME="local"
 export EMD_MIRROR_ENDPOINT="localhost"
 export REDIS_HOSTNAME="localhost"
 export KAFKA_CLUSTER_ARN="localhost:9092"
 export KAFKA_PROCESSING_ERROR_QUEUE_NAME="kafkaProcessingError"
 export TOPIC_BOOTSTRAP_CONFIG="{\"BootstrapConsumerConfiguration\": {\"clusterArn\": \"\${KAFKA_CLUSTER_ARN}\", \"autoOffsetReset\": \"earliest\", \"region\": \"us-east-1\", \"topic\": {\"groupId\": \"storeproduct-output-bootstrap\", \"topicName\": \"storeproduct-output\", \"numThreads\": 2, \"maxPollRecords\": 500, \"minBatchProcessingSize\": 100, \"maxAggregatedPollDurationMillis\": 30000}}, \"TopicOffsetConfiguration\": { \"startingOffset\": {\"0\": 0, \"1\": 0, \"2\": 0, \"3\": 0, \"4\": 0, \"5\": 0}, \"endingOffset\": {\"0\": 0, \"1\": 0, \"2\": 0, \"3\": 0, \"4\": 0, \"5\": 0}}}"

 echo "SENTRY_DSN=$SENTRY_DSN"
 echo "ENVIRONMENT_NAME=$ENVIRONMENT_NAME"
 echo "UNIQUE_NAME_PREFIX=$UNIQUE_NAME_PREFIX"
 echo "DDB_ERROR_QUEUE_NAME=$DDB_ERROR_QUEUE_NAME"
 echo "EMD_MIRROR_ENDPOINT=$EMD_MIRROR_ENDPOINT"
 echo "REDIS_HOSTNAME=$REDIS_HOSTNAME"
 echo "KAFKA_CLUSTER_ARN=$KAFKA_CLUSTER_ARN"
 echo "KAFKA_PROCESSING_ERROR_QUEUE_NAME=$KAFKA_PROCESSING_ERROR_QUEUE_NAME"
}

#extract a file checking multiple types
ex () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1                  ;;
            *.tar.gz)    tar xvzf $1                  ;;
            *.bz2)       bunzip2 $1                   ;;
            *.rar)       unrar x $1                   ;;
            *.gz)        gunzip $1                    ;;
            *.tar)       tar xvf $1                   ;;
            *.tbz2)      tar xvjf $1                  ;;
            *.tgz)       tar xvzf $1                  ;;
            *.zip)       unzip $1                     ;;
            *.Z)         uncompress $1                ;;
            *.7z)        7z x $1                      ;;
            *)           echo "can't extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

#youtube dl
ydi () {
    url="$1"

    export NEWT_COLORS='
        root=,red
        title=red,white
        textbox=,white
        window=,white
        border=black,white
        button=white,red
        listbox=,white
        actsellistbox=white,red
        compactbutton=,white
        actlistbox=white,red
    '

    array=()
    youtube-dl -F "$url" | grep '^[0-9]' | while read line; do e=$(sed 's/.*:"//;s/"//' <<<$line); array+=($e $e); done
    answer=$( whiptail --notags --title "Youtube-DL" --menu 'Select which one' 20 120 10 $array 3>&1 1>&2 2>&3)

    number=$(echo $answer | awk '{print $1}')
    audio=(249 250 140 251)

    if [ -z "$answer" ] ; then
        # cancel
        echo "canceled"
    elif [[ ! ${audio[*]} =~ "$number" ]]; then
        # not audio
        youtube-dl "$url" -f "$number"+bestaudio -ciw -o "%(title)s.%(ext)s" "$url"
    else
        # audio
        youtube-dl "$url" -f "$number" -ciw -o "%(title)s.%(ext)s" "$url"
    fi
}

# makes pressing C-xC-h combo display manpage for first command, without changing anything in current line.
#bind -x '"\C-x\C-h":__man'
# __man(){ man $(awk '{print $1}'<<<$READLINE_LINE);}

# Outputs the current epoch time or converts argument to human-readable date and time
epoch() {
  if [ $# -eq 0 ]; then
    date
    date +%s
  else
    date -d @"$@" -R
  fi
}

# show description of a http status
function httpstatus() {
  if [ -z $1 ]; then
    w3m -dump -no-graph https://httpstatuses.com
  else
    w3m -dump -no-graph https://httpstatuses.com/$1 | sed -n '/-----/q;p' | grep -v httpstatuses.com | grep --color -E "$1|"
  fi
}

# Get colors in manual pages
function man() {
       env \
                LESS_TERMCAP_mb="$(printf '\e[1;31m')" \
                LESS_TERMCAP_md="$(printf '\e[1;31m')" \
                LESS_TERMCAP_me="$(printf '\e[0m')" \
                LESS_TERMCAP_se="$(printf '\e[0m')" \
                LESS_TERMCAP_so="$(printf '\e[1;44;33m')" \
                LESS_TERMCAP_ue="$(printf '\e[0m')" \
                LESS_TERMCAP_us="$(printf '\e[1;32m')" \
                man "$@"
}

function mylanips() {
    if [[ "$ostype" == linux ]]; then
        ifaces=($(ifconfig | sed 's/[ \t].*//;/^$/d' | cut -d: -f1 | tr '\n' ' '))
    else
        ifaces=($(ifconfig -l))
    fi

    if [[ $(ifconfig | grep -c 'inet addr:') -eq 0 ]]; then
        ifsyntax='inet '
        ifsep=' '
    else
        ifsyntax='inet addr:'
        ifsep=':'
    fi

    i=0

    while [[ $i -lt ${#ifaces[*]} ]]; do
            printf "\t%-9s %s\n" "${ifaces[$i]}" "$(ifconfig "${ifaces[$i]}" | grep "$ifsyntax" | awk '{print $2}')"
        ((i++))
    done
}

function mywanip() {
    if [[ ! -f $(command -v curl) ]]; then
        printf '\t%-9s %s\n' "WAN" "$(wget -qO- https://ifconfig.co)"
    else
            printf '\t%-9s %s\n' "WAN" "$(curl -sL https://ifconfig.co)"
    fi
}

function myip() {
  mywanip
  mylanips
}


function venv() {
    if [[ "$1" == "" ]]; then
	echo "Usage: venv <environment-name>"
	echo -n "Found: "
	for i in $(ls ~/.virtualenvs/); do
	    echo -n "$i "
	done
	echo ""
	return 1
    fi
    source ~/.virtualenvs/$1/bin/activate
}


function mk-venv() {
    if [[ "$1" == "" ]]; then
	echo "Usage: mk-venv <environment-name>"
	return 1
    fi
    python3 -m venv ~/.virtualenvs/$1
}


function worm() {
    if [ $# -lt 1 ]; then
        echo 'Requires JIRA number'
        return 1
    fi
    gargs="-i"
    for i in $*; do
        gargs+=" --grep worm.${i}"
    done
    echo "issuing command: git lg $gargs"
    git lg $gargs
    return $?
}


function worm-sha() {
    if [ $# -ne 1 ]; then
        echo 'Must provide single JIRA number'
        return 1
    fi
    worm $1 | grep -v command | awk '{print $2}' | head -n 1 |sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'
}

function set-branch-name(){
      pattern="\[([^]]+)\]"
      input="$(git branch --show-current)"

      if [[ $input =~ $pattern ]]; then
        export CURRENT_BRANCH_NAME="${BASH_REMATCH[1]}"
        return 0
      fi
      unset $CURRENT_BRANCH_NAME
      return 1
}

#create feature branch or no jira branch
function gcf(){
  if [[ -z "$1" ]]; then
    if [[ ! -z "$PREVIOUS_BRANCH_NAME" ]]; then
        set-branch-name
        git checkout $PREVIOUS_BRANCH_NAME
        export PREVIOUS_BRANCH_NAME=$CURRENT_BRANCH_NAME
        set-branch-name
        return 0
    else
      echo "nothing to do, no known previous branch name"
      set-branch-name
    fi
    return 1
    #branch_name="nojira"
  elif [[ "$1" =~ ^[0-9]{5} ]]; then
    branch_name="feature/ngpos-$1"
  else
    branch_name="nojira-$1"
  fi
  echo "creating branch: ${branch_name}"
  set-branch-name
  echo "after set branch name"

  #check if branch already exists
  #if so then switch to it

  git checkout -b "$branch_name"
  echo "after gbc"
  if [[ $? -eq 0 ]]; then
    export PREVIOUS_BRANCH_NAME=$CURRENT_BRANCH_NAME
    set-branch-name
    return 0
  fi
  return 1
}

function gdel(){
  echo "git branch delete, automatically excludes current branch"
  git branch | grep -v "$1"


}

function docker () {
    if [[ "$@" == "ps -p" ]]; then
        command docker ps --all --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}" \
            | (echo -e "CONTAINER_ID\tNAMES\tIMAGE\tPORTS\tSTATUS" && cat) \
            | awk '{printf "\033[1;32m%s\t\033[01;38;5;95;38;5;196m%s\t\033[00m\033[1;34m%s\t\033[01;90m%s %s %s %s %s %s %s\033[00m\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10;}' \
            | column -s$'\t' -t \
            | awk 'NR<2{print $0;next}{print $0 | "sort --key=2"}'
    else
        command docker "$@"
    fi
}

