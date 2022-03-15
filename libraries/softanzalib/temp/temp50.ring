load "stzlib.ring"
/*
o1 = new stzFile("sonwe.txt", :text)
? o1.Content()

? o1.OpeningMode()

*/

// Create the file
o1 = new QFile()
o1.setFileName("تسعون.txt")
// Open the file in any combination of opening modes you need
o1.open_3(QIODevice_ReadOnly | QIODevice_Text)
// Write something into the file
/*
cStr = NL + "text5 = كلام" + NL
cStr += "text6 = جميل"
o1.write(cStr, len(cStr)) 
*/
// Read the file content
// Note: The file must be opened in a reading-enabled mode
? o1.readall().data()
o1.close()
