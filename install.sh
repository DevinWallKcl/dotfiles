#!/usr/bin/bash

function promptYesOrNo() {
	while true; do
		read -p "$1 (y/n) " response

		case $response in 
			[yY] ) return 0;;
			[nN] ) return 1;;
			* ) echo "invalid response";;
		esac
done
}

function trySymlinkFile() {
	if [ -L $2 ] 
	then
		echo "Skipping, file $2 is already linked."
	elif [ -f $2 ]
	then
		if promptYesOrNo "$2 already exists. would you like to overwrite it with a symlink?"
		then
			ln -sf $1 $2
			echo "Linked file $2."
		else
			echo "Skipping, file $2."
		fi
	else
		ln -s $1 $2
		echo "Linked file $2."
	fi
}


DOTFILES_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotFiles=(
	".zshrc"
	".zprofile"
	".gitconfig"
	".ssh/config"
)

# sym link dotfiles
echo "==== Linking dotfiles ====\n"

for dotFile in "${dotFiles[@]}"
do
	filePath=${DOTFILES_BASE_DIR}/${dotFile}

	if [ -f $filePath ]
	then
		trySymlinkFile $filePath ~/${dotFile}
	fi
done

echo "\n"

# make scripts available in the shell
BIN_PATH="$DOTFILES_BASE_DIR/bin"

if ! echo "$PATH" | grep -q "$BIN_PATH"
then
	export PATH="$BIN_PATH:$PATH" 
	echo "\n\n#added by a tool \nPATH=$BIN_PATH:$PATH" >> ~/.zprofile
	echo "Bin directory added to PATH.\n"
fi

# prerequisite for home-brew
if [ ! Command -v Xcode-select &> /dev/null ]
then
	echo "==== Installing xcode-select ====\n"
	xcode-select --install
fi

# install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]
then
	echo "==== Installing oh-my-zsh ====\n"
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# install homebrew package manager 
if ! Which brew > /dev/null 
then
	echo "==== Installing homebrew ====\n"
	
	if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
	then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
fi 

# install programs
echo "==== Installing brew bundle ====\n"
Brew bundle --file "$DOTFILES_BASE_DIR/Brewfile"

echo "\n"
if promptYesOrNo "would you like to clone git repositories?";
then
	sh git-clone.sh
fi

exec $SHELL -i