#!/bin/bash

characters='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.-;_?|()=+<>:'
encript=""
key=""
debug='0'
shift=42

function shuffle_string() {
  local str="$1"
  local shuffled=""
  local indices=($(seq 0 $((${#str}-1))))

  shuffle() {
    local i j
    for ((i = ${#indices[@]} - 1; i > 0; i--)); do
      j=$(( RANDOM % (i + 1) ))
      t=${indices[i]}
      indices[i]=${indices[j]}
      indices[j]=$t
    done
  }

  shuffle

  for i in "${indices[@]}"; do
    shuffled+="${str:$i:1}"
  done

  echo "$shuffled"
}


encrypt_func() {
  local characters="$1"

  for (( i=0; i<${#characters}; i++ )); do
    char="${characters:$i:1}"
    pos=$(echo "$key" | grep -obF "$char" | cut -d: -f1)

    if [[ -n "$pos" ]]; then
      dynamic_shift=$(( shift + i + 1))
      new_pos=$(( (pos + dynamic_shift) % ${#key} ))
      encript+="${key:$new_pos:1}"
    else
      encript+="$char"
    fi
  done
  
}

normal() {
	echo "Enter the text to encrypt: "
	read -r text
}

usage() {
    echo -e "Uso: $0 [-t 'TEXT' | --text 'TEXT'] [-k 'KEY' | --key 'KEY'] [-d | --debug] [-v | --version] [-h | --help]\n"
    
}

key=$(shuffle_string "$characters")
run='1'
while [[ "$#" -gt 0 ]]; do
  case $1 in
		-t | --text )
			text="$2"
			run='0'
			shift
			;;
		-k | --key )
			key="$2"
			shift
			;;
		-d | --debug )
			debug='1'
			;;
		-v | --version )
			echo -e "CC-Dynamic-encryptor version 2.4.7_bash\nCC Dynamic Implementation: S-(std)\nCC Dynamic Implementation version: 1.0\n┼────>  CC-Dynamic-engine version: S-1.2\n┼────>  CC-Dynamic-encoder version S-3.8\n╰────>  Metadata model: (lltn)/(llt)\n\t╰────>  Metadata model version: S-2.4"
			exit 0
			;;
		-h | --help )
			usage
			echo -e "CC Dynamic - Help\n"
			echo -e "Avadable options:\n-t 'TEXT'\t\tProvide the text to encrypt (optional)\n-k 'KEY'\t\tProvide a key for encrypt (optional)"
			echo -e "-d --debug\t\tShow debug informations\n-v --version\t\tDisplay the CC Dynamic version\n-h --help\t\tDisplay the help (this page)\n"
			echo -e "Note: for the options \033[4m-t\033[0m and \033[4m-k\033[0m you have use single quote \033[4m'\033[0m for the text and the key. If your text contein the character \033[4m'\033[0m you have to write it in this way: \033[4m'\\''\033[0m\nAnd if your text include the character \033[4m\\\\\033[0m you have to write twice, like: \033[4m\\\\\033[0m\033[4m\\\\\033[0m\n"
			exit 0
			;;
		* )
			echo -e "Unkonown option\nTry the option -h for the help page"
			exit 0
			;;
	esac
	shift
done

if [[ $run == '1' ]] ; then
	normal
fi

length="${#text}"
IFS='\' read -ra array <<< "$text"

if [[ ${#array[@]} != '1' ]] ; then
	for element in "${array[@]}"; do
		list+="$element<_005c_>"
	done
	text="${list:0:${#list}-8}"
else
	text="${array[@]}"
fi

for (( j=0; j<${#text}; j++ )); do
	char1="${text:$j:1}"
	if [[ ! $characters =~ $char1 && $char1 != '['  && $char1 != ']' && $char1 != '/' ]] ; then
		ascii_val=$(printf "%x" "'$char1")
		if [[ ${#ascii_val} -lt '3' ]] ; then
			ascii_val="00$ascii_val"
		elif [[ ${#ascii_val} -lt '4' ]] ; then
			ascii_val="0$ascii_val"
		fi
		to_sub1="<_$ascii_val"
		to_sub2="_>"
		to_sub="$to_sub1$to_sub2"
		text=$(echo "$text" | sed "s/$char1/$to_sub/g" 2> /dev/null) 
	fi
	if [[ $char1 == '[' ]] ; then 
		text=$(echo "$text" | sed "s/\[/<_005b_>/g" )
	elif [[ $char1 == ']' ]] ; then
		text=$(echo "$text" | sed "s/\]/<_005d_>/g" )
	elif [[ $char1 == '/' ]] ; then
		text=$(echo "$text" | sed "s/\//<_002f_>/g" )
	fi
	if [[ $char1 == "\\" ]] ; then
		echo -e "\n\t+----------------------------------------------------------+"
		echo -e "\t| \033[1;31mInternal error, the character \033[4m\\\\\033[0m\033[1;31m cannot be processed!\033[0m |"
		echo -e "\t+----------------------------------------------------------+\n"
		exit
	fi
done

for (( l=0; l<${#text}; l++ )); do
	char2="${text:$l:1}"
	if [[ "$char2" == ' ' ]] ; then
		text=$(echo "$text" | sed 's/ /<sP>/g')
	fi
done


if [[ $((${#text} % 10)) != 0 ]] ; then
	n_dec=$((${#text} / 10 * 10))
	ll=$((10 - (${#text} - $n_dec)))
	noise=$(cat /dev/urandom | tr -dc "$characters" | fold -w $ll | head -n 1)
	ctext="[$length/${#text}]{$text$noise}"
else
	ctext="[$length/${#text}]{$text}"
fi
clear
encrypt_func "$ctext" 
echo -e "Encrypted text:\n\033[5m\"\033[0m$encript\033[5m\"\033[0m\nEncryption key:\n\033[5m\"\033[0m$key\033[5m\"\033[0m" 
if [[ $debug == '1' ]] ; then
	echo -e "###DEBUG: encrypted: $ctext"
fi

