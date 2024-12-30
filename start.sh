#!/bin/sh
standartError="Please check before try to install again!\n"
gitError="\n[git] didnt found.\n$standartError"
pythonError="\n[python] didnt find or is with version minor than 3.x.x.\n$standartError"
httpClientsError="\n[curl] and [wget] dont exist on system.\n$standartError"

#git checker
if [ -z "$(git --version 2> /dev/null)" ]; then echo $gitError; exit; fi

#python checker
pythonVersion=$(python --version 2> /dev/null)
pythonRegexChecker="([3-9]\.?){1}([0-9]\.?){2}"
isValidVersion=$(echo $pythonVersion | grep -soP "$pythonRegexChecker")

if [ -z $isValidVersion ]; then echo $pythonError; exit; fi

#curl or wget checker
if [ -z "$(curl --version 2> /dev/null)" ] && [ -z "$(wget --version 2> /dev/null)" ] 
	then echo $httpClientsError; exit; 
fi

python ./installation/index.py

echo "\nNow you can delete this installation folder."
echo "Just type: rm -r ../udocker-wrapper"
