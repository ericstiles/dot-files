echo 'loading .bash_profile'

#non-interactive login scripts
if [ -n "$BASH" ] && [ -r ~/.bashrc ]; then
    echo 'loading .bashrc'
    . ~/.bashrc
else
  echo 'skipped loading .bashrc'
fi
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
