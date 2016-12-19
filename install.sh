#!/bin/bash
echo "TODO: update install.sh"

ALERT_COLOR="\033[38;5;087m"
DEFAULT_COLOR="\033[00m"
INFO="${ALERT_COLOR}[INFO]${DEFAULT_COLOR}"

# variablea--------------------------------
# bash
bashrc=".bashrc"
bashProfile=".bash_profile"
bashFiglet=".bash_figlet"
# git
gitconfig=".gitconfig"
gitIgnoreConf=".gitignore"
# vim
vimrc=".vimrc"
# atom
atomKeymap="keymap.cson"
atomInit="init.coffee"
atomConfig="config.cson"

# backup
backupBase="$HOME/.myenv"
backupDir="$backupBase/$(date +'%Y%m%d-%H%M%S')"

# logic ----------------------------------
# create base backup directory
if [ ! -d "$backupBase" ]; then
	echo -e "${INFO} create folder. ${backupBase}"
	mkdir -v $backupBase
fi

# backup current env file
echo -e "${INFO} BACKUP ENV/CONF: $backupDir"
mkdir -v $backupDir
mkdir -v $backupDir/bash
cp -v $HOME/$bashrc             $backupDir/bash/$bashrc
cp -v $HOME/$bashProfile        $backupDir/bash/$bashProfile
cp -v $HOME/$bashFiglet         $backupDir/bash/$bashFiglet
mkdir -v $backupDir/git
cp -v $HOME/$gitconfig		    $backupDir/git/$gitconfig
cp -v $HOME/$gitignore		    $backupDir/git/$gitignore
mkdir -v $backupDir/vim
cp -v $HOME/$vimrc              $backupDir/vim/$vimrc
mkdir -v $backupDir/atom
cp -v $HOME/.atom/$atomKeymap	$backupDir/atom/$atomKeymap
cp -v $HOME/.atom/$atomInit     $backupDir/atom/$atomInit
cp -v $HOME/.atom/$atomConfig	$backupDir/atom/$atomConfig

# copy to local
echo -e "${INFO} copy to local"
cp -v ./bash/$bashrc            $HOME/
cp -v ./bash/$bashProfile       $HOME/
cp -v ./bash/$bashFiglet        $HOME/
cp -v ./git/$gitconfig          $HOME/
cp -v ./git/$gitignore          $HOME/
cp -v ./vim/$vimrc              $HOME/
cp -v ./atom/$atomKeymap        $HOME/.atom/
cp -v ./atom/$atomInit          $HOME/.atom/
cp -v ./atom/$atomConfig        $HOME/.atom/

echo -e "${INFO} apply bash"
source ~/.bash_profile
