#!/usr/bin/env bash

HOME_DIRECTORY=~
BASHRC=${HOME_DIRECTORY}/.bashrc
BASHRC_BAK=${HOME_DIRECTORY}/.bashrc.bak
BASE_DIR=$(readlink -f $(dirname $0))
OTHER_DIR=${BASE_DIR}/other
DATE=$(date +"%Y%m%d.%H%m%S")
BAK=".bak.${DATE}"

#setup local files
for file in $( ls -a $OTHER_DIR | tail -n+3 ); do
  if [[ -L ~/${file} ]]; then
    echo "file exists and is symbolic: ~/${file}"
    echo "removing symbolic link: ~/${file}"
    rm ~/${file}
  elif [ -f ~/${file} ]; then
    echo "file exists and is not symbolic: ~/${file}"
    echo "creating backup file: ~/${file}${BAK}"
    mv ~/$file ~/${file}${BAK}
  else
    echo "file doesn't exist: ~/${file}"
  fi
  ln -s ${OTHER_DIR}/${file} ~/${file}
  echo "created symbolic link"
  ls -l ~/${file}
done

file=.bashrc
if [[ -L ~/${file} ]]; then
  echo "file exists and is symbolic: ~/${file}"
  echo "removing symbolic link: ~/${file}"
  rm ~/${file}
elif [ -f ~/${file} ]; then
  echo "file exists and is not symbolic: ~/${file}"
  echo "creating backup file: ~/${file}${BAK}"
  mv ~/$file ~/${file}${BAK}
else
  echo "file doesn't exist: ~/${file}"
fi
ln -s ${BASE_DIR}/bash/${file} ~/${file}
echo "created symbolic link"
ls -l ~/${file}

file=.bash_profile
if [[ -L ~/${file} ]]; then
  echo "file exists and is symbolic: ~/${file}"
  echo "removing symbolic link: ~/${file}"
  rm ~/${file}
elif [ -f ~/${file} ]; then
  echo "file exists and is not symbolic: ~/${file}"
  echo "creating backup file: ~/${file}${BAK}"
  mv ~/$file ~/${file}${BAK}
else
  echo "file doesn't exist: ~/${file}"
fi
ln -s ${BASE_DIR}/bash/${file} ~/${file}
echo "created symbolic link"
ls -l ~/${file}

#setup claude code notifier hooks (see claude/hooks/CLAUDE_NOTIFY.md)
mkdir -p ~/.claude/hooks
for file in notify-human.sh claude-focus-pane.sh claude-waiting.sh; do
  if [[ -L ~/.claude/hooks/${file} ]]; then
    echo "file exists and is symbolic: ~/.claude/hooks/${file}"
    echo "removing symbolic link: ~/.claude/hooks/${file}"
    rm ~/.claude/hooks/${file}
  elif [ -f ~/.claude/hooks/${file} ]; then
    echo "file exists and is not symbolic: ~/.claude/hooks/${file}"
    echo "creating backup file: ~/.claude/hooks/${file}${BAK}"
    mv ~/.claude/hooks/${file} ~/.claude/hooks/${file}${BAK}
  else
    echo "file doesn't exist: ~/.claude/hooks/${file}"
  fi
  ln -s ${BASE_DIR}/claude/hooks/${file} ~/.claude/hooks/${file}
  echo "created symbolic link"
  ls -l ~/.claude/hooks/${file}
done
