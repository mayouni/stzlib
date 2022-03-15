load "guilib.ring"

? :start
// Creating a QFile object
oFile = new QFile()
oFile.setFileName("abc.txt")

oFile.open_3(QIODevice_ReadWrite)

cString = "khouya"
nSize = len(cString)

oFile.write(cString,nSize)


// Reading the file content
oFile.refresh()
? oFile.readall().data()

oFile.close()
? :Done
