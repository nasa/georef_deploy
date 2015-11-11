
######################################################################
# puppet will append this code section to the default .bashrc of
# user 'vagrant' in the vagrant-managed VM.

# 'ls' is a pain to type in dvorak
alias e=ls

# set up environment for georef development
if [ -f $HOME/georef/sourceme.sh ]; then
  source $HOME/georef/sourceme.sh
fi
