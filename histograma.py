import matplotlib.pyplot as plt
import pandas as pd
import codecs

wordList = []   # Lista donde se escriben palabras
numList = []    # Lista donde se escriben numeros en hexa

odd = True

f = open('postprocess.bin', 'rb')   # Abre bytes de archivo
for line in f:
    if line.decode("utf-8", 'ignore') == '\n':  # Si la linea es 0xa
        numList += ["b'0a0d0a"]
    else:
        if odd: # Si es una palabra
            wordList += [line]
        else:   # Si es un numero
            if line.decode("utf-8", 'ignore') != '\r\n': # Si la linea no es 0xa
                numList += [codecs.encode(line, "hex")]
    
        odd = not odd
f.close()

newWList = []
newNList = []

for char in wordList:
    newWList += [''.join(repr(char).replace("b'", '').replace('\\n', '').replace('\\r', '').replace("'", ""))] # Se escriben palabras sin caracteres especiales

for char in numList:
    newNList += [''.join(repr(char).replace("b'", '').replace('0d0a', '').replace("'", "").replace('"', ''))] # Se escriben numeros sin caracteres especiales

numList = []

for num in newNList:
        numList += [int(num,16)] # Se guardan numeros en decimal

histList = list(zip(newWList, numList)) # Se generan tuplas de palabra y numero

df = pd.DataFrame(histList, columns=['Palabra', 'Frecuencia'])  # Histograma
df['Frecuencia'] = pd.to_numeric(df['Frecuencia'])
df_cleaned = df.drop_duplicates('Palabra', keep='first') # Se eliminan palabras repetidas
df = df_cleaned.nlargest(10, 'Frecuencia')  # Se escogen 10 palabras mas repetidas
df.plot(kind='bar', x='Palabra', y='Frecuencia')
plt.show()