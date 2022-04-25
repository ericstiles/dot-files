
my_link=~/.bashrc

if [ -L ${my_link} ] && [ -e ${my_link} ]; then
 exit
fi

ln -s ${my_link} './.bashrc'

