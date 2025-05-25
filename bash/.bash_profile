echo 'Loading .bash_profile'

#non-interactive login scripts
if [ -n "$BASH" ] && [ -r ~/.bashrc ]; then
    . ~/.bashrc
else
  echo 'skipped Loading .bashrc'
fi
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ericstiles/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
