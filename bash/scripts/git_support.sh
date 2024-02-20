#!/usr/bin/env bash

PREVIOUS_BRANCH_NAME=~/.previous_branch_name
CURRENT_BRANCH_NAME=~/.current_branch_name
PROJECT_KEY=ngpos

function help(){
  echo "USAGE $0 [argument>"
  echo ""
  echo "  -a                   : show current branch"
  echo "  -c                   : git add .; git commit -m \$1"
  echo "  -p                   : git add .; git commit -m \$1; git push origin <current branch>"
  echo "  -l                   : pull origin current_branch_name"
  echo "  -q                   : set branch to previous branch history"
  echo "  -s                   : set current branch to history"
  echo "  -o                   : checkout branch. filter required"
  echo "  -r                   : checkout previous branch"
  echo "  -n                   : create nojira branch with optional \$1"
  echo "  -b                   : create bug/($PROJECT_KEY) branch with added \$1"
  echo "  -f                   : create feature/($PROJECT_KEY) branch with added \$1"
  echo "  -u                   : push current branch"
  echo "  -h                   : help"
  echo ""
}

function set-previous-branch-name(){
  cat $CURRENT_BRANCH_NAME > $PREVIOUS_BRANCH_NAME
}

function set-current-branch-name(){
  echo "$(git branch --show-current)" > $CURRENT_BRANCH_NAME
}

#Create or checkout a branch
# 1. check if branch exists locally, if so checkout
# 2. check if branch exists remotely, if so branch with that upstream and checkout
# 3. check if branch matches 4 or 5 digite number if so branch as a feature/bug, project key, number
# 4. check if an argument is pass, by this point would be a nonjira branch with argument
# 5. finally create a nojira branch
function create-branch(){
        remote_branch=''
        options='-b'
        list_remote_branches="$(git branch -a | grep -v HEAD | grep -v main | grep origin | grep ${2} | tr -d ' ')"
        list_local_branches="$(git branch | grep -v main | grep ${2} | tr -d ' ')"
        if [ $(echo ${list_local_branches} |  grep -c '.'  ) == 1 ]; then
          branch_name="${list_local_branches}"
          options=''
        elif [ $(echo ${list_remote_branches} |  grep -c '.'  ) == 1 ]; then
          remote_branch="${list_remote_branches#"remotes/"}"
          branch_name="${list_remote_branches#"remotes/origin/"}"
        elif [[ "$2" =~ ^[0-9]{4,5} ]]; then
          branch_name="${1}/${PROJECT_KEY}-${2}"
        elif [[ -n "$1" ]]; then
          branch_name="nojira-${2}"
        else
          branch_name="nojira"
        fi

        set-current-branch-name
        echo "creating branch: ${branch_name}"
        echo "git checkout ${options} ${branch_name} ${remote_branch}"
        git checkout ${options} ${branch_name} ${remote_branch}
        if [ $? -eq 0 ]; then
          git branch -vv | grep "${branch_name}"
          set-previous-branch-name
          set-current-branch-name
        fi
}

function commit(){
        echo "commit(): $1"
        if [ $(git diff | wc -l) -ne 0 ] || [ $(git diff --cached | wc -l) -ne 0 ] ||
        [ $(git ls-files -o --exclude-standard | wc -l) -ne 0 ]; then
          echo "Passed into commit"
          git add .
          git commit -m "${1}"
          echo "successful:$?"
          return $?
        else
          echo "Didn't pass into commit"
        fi
        return 1
}

function not_implemented(){
  echo "not implemented: ${*}"
}

if [ -z $1 ]; then
 help
 exit
fi

while getopts "ahsqpnpcrfbulo:" opt; do
  case ${opt} in
    a)
      git branch --show-current
      ;;
    c)
#     echo "-c option"
      # Check next positional parameter
      eval nextopt=\${$OPTIND}
      # existing or starting with dash?
      echo "nextopt: '$nextopt'"
      if [[ -n $nextopt && $nextopt != -* ]] ; then
        OPTIND=$((OPTIND + 1))
        commit_message=$nextopt
      else
        commit_message="cleanup: quick"
      fi
      echo "committing (message): ${commit_message}"
      commit "${commit_message}"
      set-current-branch-name
      ;;
    b)
      # Check next positional parameter
      eval nextopt=\${$OPTIND}
      # existing or starting with dash?
      if [[ -n $nextopt && $nextopt != -* ]] ; then
        OPTIND=$((OPTIND + 1))
        branch_extension=$nextopt
      else
        branch_extension=""
      fi
      create-branch "bug" ${branch_extension}
      ;;
    f)
      # Check next positional parameter
      eval nextopt=\${$OPTIND}
      # existing or starting with dash?
      if [[ -n $nextopt && $nextopt != -* ]] ; then
        OPTIND=$((OPTIND + 1))
        branch_extension=$nextopt
      else
        branch_extension=""
      fi
      create-branch "feature" ${branch_extension}
      ;;
    n)
      # Check next positional parameter
      eval nextopt=\${$OPTIND}
      # existing or starting with dash?
      if [[ -n $nextopt && $nextopt != -* ]] ; then
        OPTIND=$((OPTIND + 1))
        branch_extension="-"$nextopt
      else
        branch_extension=""
      fi
      set-current-branch-name
      echo "creating branch: nojira$branch_extension"
      git checkout -b "nojira$branch_extension"
      if [ $? -eq 0 ]; then
        set-previous-branch-name
        set-current-branch-name
      fi
      ;;
    r)
      if [[ -n "$PREVIOUS_BRANCH_NAME"  ]]; then
        git checkout $(cat $PREVIOUS_BRANCH_NAME)
        set-previous-branch-name
        set-current-branch-name
      else
        echo "No previous branch set"
      fi
    ;;
    q)
      set-current-branch-name
      set-previous-branch-name
      ;;
    p)
      # Check next positional parameter
      eval nextopt=\${$OPTIND}
      # existing or starting with dash?
      if [[ -n $nextopt && $nextopt != -* ]] ; then
        OPTIND=$((OPTIND + 1))
        commit_message=$nextopt
      else
        commit_message="cleanup: quick commit"
      fi
      commit $commit_message
      if [ "$?" -eq 0 ]; then
        git push origin "$(git branch --show-current)"
        if [ $? -eq 0 ]; then
          set-current-branch-name
        else
          echo "changes committed, can't push"
        fi
      else
        echo "nothing committed, skipping push"
      fi
      ;;
    o)
      branch_option=''
      branches=($(git branch | grep -v '*' | grep ${OPTARG} ))
      if [[ "${#branches[@]}" == 0 ]]; then
        echo "no local branches"
        #Check for remote branches
        branches=($(git branch -a | grep ${OPTARG} | grep 'remotes/origin' | grep -v 'main' | sed 's/remotes\/origin\///g'))
        if [[ "${#branches[@]}" == 0 ]]; then
          echo "no remote branches"
          git branch -a
          break
        elif [[ "${#branches[@]}" == 1 ]]; then
          git checkout -b "${branches[0]}"
          break
        fi
        branch_option='-b'
      fi
      if [[ "${#branches[@]}" == 1 ]]; then
        git checkout "${branches[0]}"
      else
        branches=( ${branches[@]} quit)
        select branch in "${branches[@]}"; do
            [[ $branch == quit ]] && break
            if [[ -z $branch ]]; then
              echo "Invalid input. Try again!"
            else
              git checkout $branch_option $branch
              break;
            fi
        done
      fi
      ;;
    s)
      set-current-branch-name
      cat $CURRENT_BRANCH_NAME
      ;;
    u)
      branch=$(git branch --show-current)
      git push origin ${branch}
      ;;
    l)
#      not_implemented "${*}"
      set-current-branch-name
      git pull origin $(git branch --show-current)
      ;;
    h)
     help
     exit
     ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      ;;
  esac
done
