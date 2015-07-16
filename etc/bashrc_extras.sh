
######################################################################
# puppet will append this code section to the default .bashrc of
# user 'vagrant' in the vagrant-managed VM.

# 'ls' is a pain to type in dvorak
alias e=ls

# set up environment for xgds_basalt development
if [ -f $HOME/xgds_basalt/sourceme.sh ]; then
  source $HOME/xgds_basalt/sourceme.sh
fi
