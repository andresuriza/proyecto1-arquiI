import matplotlib.pyplot as plt
import pandas as pd
import codecs

wordList = []
numList = []

odd = True

f = open('postprocess.bin', 'rb')
for line in f:
    if line.decode("utf-8", 'ignore') == '\n':
        numList += ["b'0a0d0a"]
    else:
        if odd: 
            wordList += [line]
        else:
            if line.decode("utf-8", 'ignore') != '\r\n':
                numList += [codecs.encode(line, "hex")]
    
        odd = not odd
f.close()

newWList = []
newNList = []

for char in wordList:
    newWList += [''.join(repr(char).replace("b'", '').replace('\\n', '').replace('\\r', '').replace("'", ""))]

for char in numList:
    newNList += [''.join(repr(char).replace("b'", '').replace('0d0a', '').replace("'", "").replace('"', ''))]

numList = []

for num in newNList:
        numList += [int(num,16)]

histList = list(zip(newWList, numList))

df = pd.DataFrame(histList, columns=['Palabra', 'Frecuencia'])
df['Frecuencia'] = pd.to_numeric(df['Frecuencia'])
df_cleaned = df.drop_duplicates('Palabra', keep='first')
df = df_cleaned.nlargest(10, 'Frecuencia')
df.plot(kind='bar', x='Palabra', y='Frecuencia')
plt.show()