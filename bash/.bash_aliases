echo "Loading bash specific aliases"

#remove all existing aliases
unalias -a

alias reload='source ~/.bash_profile'

#########################
#                       #
#    Docker Commands    #
#                       #
#########################
alias dc='docker-compose'
alias d='docker'
alias di='docker images'
alias cu='~/repo/docker-utils/container-utils.sh'
alias iu='~/repo/docker-utils/images-utils.sh'
alias vu='docker volume'
alias drma='d rm $(d ps -a | sed ''s~\t~\ ~g;  s~\ \ ~\ ~g;'' | cut -d'' '' -f1 | sed 1d)'
alias ds='docker ps --format "{{ .ID }}\t{{.Image}}\t{{ .Names }}"'
alias jsonlogs="docker ps --format '{{ json .}}' | jq ."


##################
#                #
# Alias Commands #
#                #
##################
alias a='alias'
alias ag='alias  | grep -i'
alias c='clear'
alias cls='printf "\033c"'
alias e='exit'
alias env='env | sort'
alias eg='env | grep'

alias eject='drutil eject'                      # eject cd
alias h=history                                 # show the history of commands issued
alias hg='history | grep -E -i'
#alias idea='cd ~/IdeaProjects'
alias ji='jenv versions'
alias ks='echo "stopping running shaded app"; kill -9 `pgrep -f shaded`'           #Kill running shaded jar
alias list-java='ll /Library/Java/JavaVirtualMachines/'
alias np="ps -ef|wc -l"                         # np - number of processes running
alias nu="who|wc -l"                            # nu - number of users
alias p="ps -ef"
alias p3="python3"
#alias reload="exec $SHELL -l"
alias repo='cd ~/repo'
alias repo2='cd ~/repo2'
alias sqldeveloper='nohup /Applications/SQLDeveloper.app/Contents/MacOS/sqldeveloper.sh &'
alias sql='sqldeveloper'
alias va='vi ~/.bash_aliases'

alias ls='ls -Gi'                               # Colorize the ls output
alias ll='ls -la'                               # Use a long listing format
alias l.='ls -d .* -B'                          # Show hidden files
alias lc="ls -C"
alias lm="ls -al | more"
alias ll="ls -alhGpF"
alias ll="ls -alhGpF"

alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
alias cd.='cd ..'
alias cd..="cd ../.."
alias cd...="cd ../../.."
alias cd-="cd -"
alias dir="ls -al"
alias dirs="ls -al | grep '^d'"                 # show the dir's in the current dir

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias psd='pgrep -f shaded'

# mimick a few DOS commands with these aliases:
alias edit=vi
alias help=man
alias path="echo $PATH"

# remove all *.orig files recursively
alias orig='find . -name "*.orig" -type f -exec rm {} \;'

############################
#                          #
#   Terraform/Terragrunt   #
#                          #
############################
alias tf='terraform'
alias tfa='terraform apply'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfw='terraform workspace'
alias tftrace='export TF_LOG=TRACE'
alias agi='aws-vault heb-ecom-data-bld -- terragrunt info'
alias agp='aws-vault heb-ecom-data-bld -- terragrunt plan'
alias aga='aws-vault heb-ecom-data-bld -- terragrunt apply'
alias tgi='terragrunt info'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'
alias rmtgcache='find . -name .terragrunt-cache -type d -exec rm -rf {} \;'

alias tgss='/usr/local/bin/terragrunt state show'
alias tgsl='/usr/local/bin/terragrunt state list'
alias tgsm='/usr/local/bin/terragrunt state mv'
alias tgsmd='/usr/local/bin/terragrunt state mv -dry-run'
#alias tgp='/usr/local/bin/terragrunt state mv -dry-run'

alias local-materialize="set-local-vars && java -jar $JAVA_OPTS ./target/data-materialize-shaded.jar server ./data-materialize.localconfig.yml"

#########################
#                       #
#    Maven Commands     #
#                       #
#########################
alias new-maven-project='mvn archetype:generate -DarchetypeGroupId=org.apache.maven.archetypes -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4'
alias nmp='new-maven-project'
alias mci='mvn clean install'

##########################
#                        #
#    Gradle Commands     #
#                        #
##########################
alias b='./gradlew'

###############################
#                             #
#    git_support Commands     #
#                             #
###############################
alias git_support='git_support.sh'
alias feature='git_support -f'
alias f=feature
alias bug='git_support -b'
alias b=bug
alias prev='git_support -r'
alias r=prev
alias cap='git_support -p'
alias push='git_support -u'
alias acm='git_support -c'
alias pull='git_support -l'









#https://opensource.com/article/19/7/bash-aliases

#You can use the ls command to create an alias to help you find where you left off:
#The output is simple, although you can extend it with the --long option if you prefer.
alias left='ls -t -1'

#count files
alias count='find . -type f | wc -l'

#copy with a progress bar
alias cpv='rsync -ah --info=progress2'


alias cg='cd `git rev-parse --show-toplevel`'
alias startgit='cd `git rev-parse --show-toplevel` && git checkout master && git pull'



