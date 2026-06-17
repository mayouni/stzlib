load "../../stzBase.ring"
func MakeTestArea cRoot
	if dirExists(cRoot) RemoveFolderRecursive(cRoot) ok
	QMkdir(cRoot + "/docs")
	QMkdir(cRoot + "/images/more")
	QMkdir(cRoot + "/images/notes")
	QMkdir(cRoot + "/music")
	QMkdir(cRoot + "/tempo")
	QMkdir(cRoot + "/videos")
	write(cRoot + "/test.txt", "program line 1" + nl + "x" + nl + "program line 3")
	write(cRoot + "/images/image1.png", "x")
	write(cRoot + "/images/image2.png", "x")
	write(cRoot + "/images/notes/howto.txt", "howto program here")
	write(cRoot + "/images/notes/sources.txt", "program sources")
	write(cRoot + "/tempo/temp1.txt", "temp program")
	write(cRoot + "/tempo/temp2.txt", "another program")
