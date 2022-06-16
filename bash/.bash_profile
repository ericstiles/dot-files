echo 'loading .bash_profile'

#non-interactive login scripts
if [ -n "$BASH" ] && [ -r ~/.bashrc ]; then
    . ~/.bashrc
fi

export JAVA_HOME=$(/usr/libexec/java_home)
