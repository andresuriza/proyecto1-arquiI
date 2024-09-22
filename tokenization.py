import string

with open('lorem.txt', 'r') as file: # Abre archivo a tokenizar
    text = file.read()

outputStr = []

words = text.split() # Separa palabras por espacio

for word in words[:-1]:
    outputStr += [word.strip(string.punctuation).replace("'", "").replace('"', "") + "\n"]  # Elimina puntuacion y comillas, agrega nextline

outputStr += [words[-1].strip(string.punctuation).replace("'", "").replace('"', "") + "\n."] # Agrega punto a la ultima palabra
    
with open("preprocess.txt", "w") as text_file:  # Escribe las palabras en preprocess.txt
    for line in outputStr:
        text_file.write(line)
