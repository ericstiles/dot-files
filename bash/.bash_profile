echo 'loading .bash_profile'

#non-interactive login scripts
if [ -n "$BASH" ] && [ -r ~/.bashrc ]; then
    echo 'loading .bashrc'
    . ~/.bashrc
else
  echo 'skipped loading .bashrc'
fi


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/THW9790/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
