#!/bin/bash

decript=""
key=""
debug='0'
shift=42

replace_hex() {
    local input="$1"
    echo "$input" | sed -E 's/<_([0-9A-Fa-f]{4})_>/\\u\1/g'
}


decrypt_func() {
  local string="$1"

  for (( j=0; j<${#string}; j++ )); do
    char="${string:$j:1}"
    pos=$(echo "$key" | grep -obF "$char" | cut -d: -f1)

    if [[ -n "$pos" ]]; then
      dynamic_shift=$(( -(shift + j + 1) ))
      new_pos=$(( (pos + dynamic_shift) % ${#key} ))
			if [[ $new_pos -lt 0 ]] ; then
				new_pos=$((${#key} + $new_pos))
      fi
      decript+="${key:$new_pos:1}"
    else
      decript+="$char"
    fi
  done
  
}

normal() {
	if [[ $runt == '0' ]] ; then
		echo "Enter the encrypted text: "
		read -r text
	fi
	if [[ $runk == '0' ]] ; then
		echo "Enter the encryption key: "
		read -r key
	fi
}

usage() {
    echo -e "Usage: $0 [-t 'TEXT' | --text 'TEXT'] [-k 'KEY' | --key 'KEY'] [-d | --debug] [-v | --version] [-h | --help]\n"
    
}

runt='0'
runk='0'
while [[ "$#" -gt 0 ]]; do 
  case $1 in
		-t | --text )
			text="$2"
			runt='1'
			shift
			;;
		-k | --key )
			key="$2"
			runk='1'
			shift
			;;
		-d | --debug )
			debug='1'
			;;
		-v | --version )
			echo -e "CC-Dynamic-decryptor version 2.4.7_bash\nCC Dynamic Implementation: S-std\nCC Dynamic Implementation version: 1.0\n┼────>  CC-Dynamic-engine version: S-1.2\n┼────>  CC-Dynamic-encoder version S-3.8\n╰────>  Metadata model: lltn/llt\n\t╰────>  Metadata model version: S-2.5"
			exit 0
			;;
		-h | --help )
			usage
			echo -e "CC Dynamic - Help\n"
			echo -e "Avadable options:\n-t --text 'TEXT'\tProvide the text to decrypt (optional)\n-k --key 'KEY'\t\tProvide a key for the decrypt (optional)"
			echo -e "-d --debug\t\tShow debug informations\n-v --version\t\tDisplay the CC Dynamic version\n-h --help\t\tDisplay the help (this page)\n"
			exit 0
			;;
		* )
			echo -e "Unkonown option\nTry the option -h for the help page"
			exit 0
			;;
	esac
	shift
done

normal

if [[ $key == "" ]] ; then
	echo -e "Fatal error: key is NULL!"
	exit
fi

decrypt_func "$text" 

if [[ $decript =~ ^\[([0-9]+)/([0-9]+)\]\{(.*)\} ]]; then
  length="${BASH_REMATCH[1]}"
  length_cod="${BASH_REMATCH[2]}"
  decr_text="${BASH_REMATCH[3]}"
  decr_text=$(echo "$decr_text" | cut -c -"$length_cod")
else
  echo "Fatal error: metadata not found!"
fi

clear

if [[ ${#decr_text} == "$length_cod" && "$length_cod" != "$length" ]] ; then
	decr_text=$(replace_hex "$decr_text")
	if [[ $decr_text =~ "<sP>" ]] ; then
		decr_text=$(echo "$decr_text" | sed 's/<sP>/ /g')
	fi
	echo -e "Decrypted text:\n$decr_text" 
	if [[ $debug == '1' ]] ; then
		echo -e "###DEBUG: decripted: $decript"
	fi
elif [[ ${#decr_text} == "$length" ]] ; then
	echo -e "Decrypted text:\n$decr_text"
	if [[ $debug == '1' ]] ; then
		echo -e "###DEBUG: decripted: $decript"
	fi
else
	echo -e "ERROR, text could not be deciphered, please check if the key and text are correct."
	if [[ $debug == '1' ]] ; then
		echo -e "###DEBUG: decripted: \033[5m<<\033[0m$decript\033[5m>>\033[0m"
	fi
fi

