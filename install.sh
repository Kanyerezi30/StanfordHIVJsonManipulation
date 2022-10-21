#!/usr/bin/env bash

# install the program

# bash install.sh

chmod +x $HOME/StanfordHIVJsonManipulation/bin/*
echo "export PATH="$HOME/StanfordHIVJsonManipulation/bin:$PATH"" >> $HOME/.bashrc

source $HOME/.bashrc
