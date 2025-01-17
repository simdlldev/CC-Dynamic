import random
import string
import argparse

characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.-;_?/()=+[]{}|<>:"
encript = ""
key = ""
debug = '0'
shift = 42

def shuffle_string(s):
    indices = list(range(len(s)))
    random.shuffle(indices)
    shuffled = ''.join(s[i] for i in indices)
    return shuffled

def encrypt_func(characters, key, shift):
    encript = ""
    for i, char in enumerate(characters):
        pos = key.find(char)
        if pos != -1:
            dynamic_shift = shift + i + 1
            new_pos = (pos + dynamic_shift) % len(key)
            encript += key[new_pos]
        else:
            encript += char
    return encript

parser = argparse.ArgumentParser(
    description='CC Dynamic - Help',
    epilog="Note: for the options \033[4m-t\033[0m and \033[4m-k\033[0m you have use single quote \033[4m'\033[0m for the text and the key.If your text contein the character \033[4m'\033[0m you have to write it in this way: \033[4m'\\''\033[0m. And if your text include the character \033[4m\\\033[0m you have to write twice, like: \033[4m\\\\\033[0m\n"
)

parser.add_argument('-t', '--text', type=str, metavar='\'TEXT\'', help='Provide the text to encrypt')
parser.add_argument('-k', '--key', type=str,  metavar='\'KEY\'', help='Provide a key for encrypt')
parser.add_argument('-d', '--debug', action='store_true', help='Show debug informations')
parser.add_argument('-v', '--version', action='store_true', help='Display the CC Dynamic version')

args = parser.parse_args()

run = '1'

key = shuffle_string(characters)

if args.version:
    print("CC-Dynamic-encryptor version 2.4.3_python\nCC Dynamic Implementation: S-std\nCC Dynamic Implementation version: 1.0\n┼────>  CC-Dynamic-engine version: S-1.2\n┼────>  CC-Dynamic-encoder version S-3.8\n╰────>  Metadata model: lltn/llt\n\t╰────>  Metadata model version: S-2.5")
    exit()
if args.debug:
    debug = '1'
if args.text:
    text = args.text
    run = '0'
if args.key:
    key = args.key

if run == '1':
    text = input("Enter the text to encrypt: ")
length = len(text)
    
text = text.replace('\\', '<_005c_>')
for char1 in text:
    if char1 not in characters and char1 != ' ' or char1 == '{' or char1 == '}':
        ascii_val = format(ord(char1), '02x')
        if len(ascii_val) < 3:
            ascii_val = "00" + ascii_val
        elif len(ascii_val) < 4:
            ascii_val = "0" + ascii_val
        else:
            ascii_val = ascii_val
        to_sub = f"<_{ascii_val}_>"
        text = text.replace(char1, to_sub)

    if char1 == "\\":
        print("\n\t+----------------------------------------------------------+")
        print("\t| \033[1;31mInternal error, the character \033[4m\\\033[0m\033[1;31m cannot be processed!\033[0m |")
        print("\t+----------------------------------------------------------+\n")
        exit()

text = text.replace(' ', '<sP>')

if len(text) % 10 != 0:
    n_dec = (len(text) // 10) * 10
    ll = 10 - (len(text) - n_dec)
    noise = ''.join(random.choices(characters, k=ll))
    ctext = f"[{length}/{len(text)}]{{{text}{noise}}}"
else:
    ctext = f"[{length}/{len(text)}]{{{text}}}"

encript = encrypt_func(ctext, key, shift)

print(f"Encrypted text:\n\033[5m\"\033[0m{encript}\033[5m\"\033[0m\nEncryption key:\n\033[5m\"\033[0m{key}\033[5m\"\033[0m")
if debug == '1':
	print(f"###DEBUG: encrypted: {ctext}")

