#!/bin/sh
standartError="Please check before try to install again!\n"
gitError="\n[git] didnt found.\n$standartError"
pythonError="\n[python] didnt find or is with version minor than 3.x.x.\n$standartError"
pipPythonError="\n[pip] didnt find.\n$standartError"
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

# Declaring colors
PURPLE='\033[95m'
BLUE='\033[94m'
GREEN='\033[92m'
CYAN='\033[96m'
YELLOW='\033[93m'
RED='\033[91m'

# Declaring formmaters
ITALIC='\033[3m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
TABS='   '
ENDC='\033[0m'

responses=()
addResponses () {
	responses+=("$1")
}

question1 () { 
	$showErrorMessage="$1"
	echo "\n${BOLD}- What type plataform/os are you using?${ENDC}"
	echo "${TABS}${ITALIC}${CYAN}'Linux' can be any distribution${ENDC}"
	echo "\n${TABS}${UNDERLINE}Options:${ENDC}"
	echo "${TABS}${TABS}1° DESKTOP [distros linux]"
	echo "${TABS}${TABS}2° MOBILE [termux]"
	echo "\n${TABS}> ${ITALIC}Type below:${ENDC} ${BOLD}${BLUE}(default: 1)${ENDC}\n"
	
	if [ $showErrorMessage = 'true' ]; then 
		echo -e "${TABS}${RED}Unespected value, digit only above values.${ENDC}\n"
	fi

	read plataform

	if [ -z $plataform ]; then plataform="1"; fi

	case $plataform in
		1) addResponses 1; return 1;;
		2) addResponses 2; return 2;;
		*) return 0;;
	esac
}
question2 () {
	$showErrorMessage="$1"
	echo "\n${BOLD}- Where do you want install code source from?${ENDC}"
	echo "${TABS}${ITALIC}${CYAN}if you choose \"pip\", you need to have it${ENDC}"
	echo "\n${TABS}${UNDERLINE}Options:${ENDC}"
	echo "${TABS}${TABS}1° GITHUB CODE [curl or wget] ${BOLD}${PURPLE}(recommend)${ENDC}"
	echo "${TABS}${TABS}2° PIP [package manager]"
	echo "\n${TABS}> ${ITALIC}Type below:${ENDC} ${BOLD}${BLUE}(default: 1)${ENDC}\n"

	if [ $showErrorMessage = 'true' ]; then 
		echo -e "${TABS}${RED}Unespected value, digit only above values.${ENDC}\n"
	fi

	read sourceCode

	if [ -z $sourceCode ]; then sourceCode="1"; fi

	case $sourceCode in
		1) # curl or wget
			
			addResponses 1 
			return 1;;

		2) # pip	
			if [ -z "$(pip --version 2> /dev/null)" ]; then
				echo $pipPythonError
				exit
			fi

			addResponses 2 
			return 2;;

		*) return 0;;
	esac
}
question3 () {
	question2="${responses[2]}"

	case $question2 in 
		1)
			echo "\n${BOLD}- Where do you want to install project folder?${ENDC}"
			echo "${TABS}${ITALIC}${CYAN}If folder doesnt exist, it will be created${ENDC}"
			echo "\n${TABS}${UNDERLINE}Suggestions:${ENDC}"
			echo "${TABS}${TABS}- \$HOME/.udocker"
			echo "${TABS}${TABS}- /opt/udocker"
			echo "\n${TABS}> ${ITALIC}Type below:${ENDC} ${BOLD}${BLUE}(default: \$HOME/.udocker)${ENDC}\n"

			read typed

			if [ -z $typed ]; 
				then typed="$HOME/.udocker"
				else typed="$(eval echo $typed)"
			fi
			
			mkdir -p $typed
			echo "${TABS}installing..."
			git clone -q https://github.com/indigo-dc/udocker.git $typed
			ln -s $typed/udocker/maincmd.py $typed/udocker/udocker
			echo "${TABS}${GREEN}installed with success!${ENDC}\n"
			addResponses $typed
			sleep 1
			return 1
			;;
		2)
			echo "\n\n${TABS}installing..."
			pip install -q udocker
			echo "${TABS}${GREEN}installed with success!${ENDC}\n"
			addResponses 2
			sleep 1
			return 2
			;;

		*)  
			return 0
			;;
	esac
}

clear
echo "\n\n${BOLD}${YELLOW}Welcome to Udocker Installer :)${ENDC}"
echo "${BOLD}Let's start with some questions!${ENDC}\n"
echo "${ITALIC}\nPress [ENTER] to start this installer${ENDC}"
read -s

for (( i=1; i<=3; i++ ))
do
	local isInvalid="true"
	local showErrorMessage="false"

	while [ $isInvalid = "true" ];
	do
		clear
		eval "question${i}" $showErrorMessage 2> /dev/null
		local response="$?"
		
		#error code
		if [ $response = "127" ]; then 
			break;
		fi

		#invalid code
		if [ $response = "0" ]; then 
			isInvalid='true'
			showErrorMessage='true'
			continue
		fi

		isInvalid="false"
	done
done

echo ${responses[*]}
