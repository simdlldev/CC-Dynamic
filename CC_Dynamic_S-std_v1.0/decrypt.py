import re
import string
import subprocess
import argparse

debug = '0'

def replace_hex(input_str):
    def replace(match):
        hexadecimal = match.group(1)
        byte = bytes.fromhex(hexadecimal)
        characters = byte.decode('latin-1')
        return characters

    pattern = r"<_\s*(\w+)\s*_>"
    result = re.sub(pattern, replace, input_str)
    return result
    
def decrypt_func(strings, key, shift):
    decript = ""
    for j, char in enumerate(strings):
        pos = key.find(char)
        if pos != -1:
            dynamic_shift = -(shift + j + 1)
            new_pos = (pos + dynamic_shift) % len(key)
            if new_pos < 0:
                new_pos += len(key)
            decript += key[new_pos]
        else:
            decript += char
    return decript

def main():
    debug = '0'
    comm1 = "set +H"
    comm2 = "set -H"
    proc1 = subprocess.run(comm1, shell=True, text=True, capture_output=True)
    
    parser = argparse.ArgumentParser(
        description='CC Dynamic - Help')

    parser.add_argument('-t', '--text', type=str, metavar='\'TEXT\'', help='Provide the text to decrypt')
    parser.add_argument('-k', '--key', type=str,  metavar='\'KEY\'', help='Provide a key for the decrypt')
    parser.add_argument('-d', '--debug', action='store_true', help='Show debug informations')
    parser.add_argument('-v', '--version', action='store_true', help='Display the CC Dynamic version')
    #print("0")
    args = parser.parse_args()
    
    runt = '0'
    runk = '0'

    if args.version:
        print("CC-Dynamic-decryptor version 2.4.3_python\nCC Dynamic Implementation: S-std\nCC Dynamic Implementation version: 1.0\n┼────>  CC-Dynamic-engine version: S-1.2\n┼────>  CC-Dynamic-encoder version S-3.8\n╰────>  Metadata model: lltn/llt\n\t╰────>  Metadata model version: S-2.5")
        exit()
    if args.debug:
        debug = '1'
    if args.text:
        text = args.text
        runt = '1'
    if args.key:
        key = args.key
        #print("1")
        runk = '1'
    
    if runt == '0':
        text = input("Enter the encrypted text: ")
    if runk == '0':
        key = input("Enter the encryption key: ")
    
    if not key:
        print("Fatal error: key is NULL!")
        return

    shift = 42
    decript = decrypt_func(text, key, shift)
    
    
    pattern = r"\[(\d+)/(\d+)\]\{(.*?)\}"
    match = re.match(pattern, decript)
    if match:
        length = match.group(1)
        length_cod = match.group(2)
        decr_text = match.group(3)[:int(length_cod)]
    else:
        print("Fatal error: metadata not found!")
        if debug == '1':
            print(f"###DEBUG: decript: {decript}")
        return

    if len(decr_text) == int(length_cod) and length_cod != length:
        decr_text = decr_text.replace("<sP>", " ")
        decr_text = replace_hex(decr_text)
        print(f"Decrypted text:\n{decr_text}")
        if debug == '1':
            print(f"###DEBUG: decript: {decript}")
    elif len(decr_text) == int(length):
        print(f"Decrypted text:\n{decr_text}")
        if debug == '1':
            print(f"###DEBUG: decript: {decript}")
    else:
        print("ERROR, text could not be deciphered, please check if the key and text are correct.")
    subprocess.run(comm2, shell=True, text=True, capture_output=True)

if __name__ == "__main__":
    main()

