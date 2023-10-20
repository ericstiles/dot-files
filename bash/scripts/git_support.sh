#!/usr/bin/env bash

PREVIOUS_BRANCH_NAME=~/.previous_branch_name
CURRENT_BRANCH_NAME=~/.current_branch_name
PROJECT_KEY=ngpos

function help(){
  echo "USAGE $0 [argument>"
  echo ""
  echo "  -c                   : git add .; git commit -m \$1"
  echo "  -p                   : git add .; git commit -m \$1; git push origin <current branch>"
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

function create-branch(){
        #check for starting numbers
        if [[ "$2" =~ ^[0-9]{4,5} ]]; then
          branch_name="${1}/${PROJECT_KEY}-${2}"
        elif [[ -n "$1" ]]; then
          branch_name="nojira-${2}"
        else
          branch_name="nojira"
        fi

        #check if branch exists
        #if it exists just checkout

        #otherwise create and checkout branch
        set-current-branch-name
        echo "creating branch: $branch_name"
        git checkout -b "$branch_name"
        if [ $? -eq 0 ]; then
          set-previous-branch-name
          set-current-branch-name
        fi
}

function commit(){
        if [ $(git diff | wc -l) -ne 0 ] ||
        [ $(git ls-files -o --exclude-standard | wc -l) -ne 0 ]; then
          git add .
          git commit -m "${commit_message}"
          return $?
        fi
        return 1
}

if [ -z $1 ]; then
 help
 exit
fi

while getopts "hsqpnpcrfbuo:" opt; do
  case ${opt} in
    c)
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
