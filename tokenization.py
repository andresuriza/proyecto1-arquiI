import string

with open('lorem.txt', 'r') as file:
    text = file.read()

outputStr = []

words = text.split()

for word in words[:-1]:
    outputStr += [word.strip(string.punctuation).replace("'", "").replace('"', "") + "\n"]

outputStr += [words[-1].strip(string.punctuation).replace("'", "").replace('"', "") + "\n."]
    
with open("preprocess.txt", "w") as text_file:
    for line in outputStr:
        text_file.write(line)
