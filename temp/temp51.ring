load "stzlib.ring"
/*
OpenFile(:ForReading)		:ReadOnly
OpenFile(:ForWrtingAtEnd)	:Append
OpenFile(:ForErasingAndWriting)	:WriteOnly
*/



o1 = new QFile()
o1.setFileName("bazza.txt")
// Open the file in any combination of opening modes you need
o1.open_3(QIODevice_ReadWrite)

// Write something into the file
cStr = " أيّها العالم"
o1.write(cStr, len(cStr)) 

// Read the file content
// Note: The file must be opened in a reading-enabled mode
? o1.readall().data()
? o1.close()
