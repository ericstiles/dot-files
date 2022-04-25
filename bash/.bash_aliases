echo "Loading bash specific aliases"

alias reload='source ~/.bash_profile'

alias cdd='repo; cd ./data88'
alias cdm='repo; cd ./data-model'
alias cdtg='repo; cd ./select-terragrunt'
alias cdtf='repo; cd ./select-terraform'
alias cds='repo; cd ./sandbox/estiles'
alias cdpc='repo; cd ./heb-ecom-product-catalog'
alias cdpt='repo; cd ./heb-ecom-product-catalog-terraform'
alias cdg='repo; cd ./graphql'

alias stg-external='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-stg/environments/stg/wormhole/data-external'
alias stg-ingest='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-stg/environments/stg/wormhole/data-ingest'
alias stg-kinesis='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-stg/environments/stg/wormhole/kinesis'
alias stg-dynamodb='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-stg/environments/stg/wormhole/dynamodb'
alias stg-emd='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-stg/environments/stg/wormhole/emd-mirror'

alias prd-external='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-prd/environments/prd/wormhole/data-external'
alias prd-ingest='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-prd/environments/prd/wormhole/data-ingest'
alias prd-kinesis='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-prd/environments/prd/wormhole/kinesis'
alias prd-dynamodb='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-prd/environments/prd/wormhole/dynamodb'
alias prd-emd='cd  ~/repo/heb-ecom-data-terraform/accounts/heb-ecom-data-prd/environments/prd/wormhole/emd-mirror'

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
alias eject='drutil eject'                      # eject cd
alias h=history                                 # show the history of commands issued
alias hg='history | grep'
alias idea='cd ~/IdeaProjects'
alias ji='jenv versions'
alias ks='echo "stopping running shaded app"; kill -9 `pgrep -f shaded`'           #Kill running shaded jar
alias list-java='ll /Library/Java/JavaVirtualMachines/'
alias np="ps -ef|wc -l"                         # np - number of processes running
alias nu="who|wc -l"                            # nu - number of users
alias p="ps -ef"
alias p3="python3"
#alias reload="exec $SHELL -l"
alias repo='cd ~/repo'
alias sqldeveloper='nohup /Applications/SQLDeveloper.app/Contents/MacOS/sqldeveloper.sh &'
alias sql='sqldeveloper'
alias slv='source ~/.virtualenvs/select_lambdas_venv/bin/activate'
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
alias tgsapi='repo; cd ./select-terragrunt/accounts/heb-ecom-data-stg/environments/stg/wormhole/data-api/'


## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias psd='pgrep -f shaded'

# mimick a few DOS commands with these aliases:
alias edit=vi
alias help=man
alias path="echo $PATH"

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
alias tg='~/repo/select-terragrunt/scripts/terragrunt.sh'
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