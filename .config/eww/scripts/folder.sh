#!/bin/bash

export DIR="$HOME"/"$1"
setsid -f st -e zsh -ic "
files=(\$DIR/*(N.)) dirs=(\$DIR/*(N/))
echo \$DIR/ \${#files} files \${#dirs} directories; echo
ls -la \$DIR; cd \$DIR; exec zsh
"
