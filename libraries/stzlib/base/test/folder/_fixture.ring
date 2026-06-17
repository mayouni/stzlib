# Shared fixture for the stzFolder examples.
#
# Builds the documented "testarea" tree in a LOCAL sandbox so every example
# runs for real and reproducibly (the originals assumed a machine-specific
# c:/testarea). Folder names are deliberately MIXED-CASE on disk (Docs,
# Images, Music, Videos) to demonstrate Softanza's lowercase listing
# convention while real-case paths are preserved.
#
#   testarea/
#     test.txt
#     Docs/                 (empty)
#     Images/
#       image1.png
#       image2.png
#       more/               (empty)
#       notes/
#         howto.txt
#         sources.txt
#     Music/                (empty)
#     tempo/
#       temp1.txt
#       temp2.txt
#     Videos/               (empty)
#
# Root: 1 file + 5 folders (6 elements). Deep: 7 files, 7 folders.

func BuildTestArea(cBase)
	if dirExists(cBase) RemoveFolderRecursive(cBase) ok
	StzMakeDir(cBase + "/Docs")
	StzMakeDir(cBase + "/Images/more")
	StzMakeDir(cBase + "/Images/notes")
	StzMakeDir(cBase + "/Music")
	StzMakeDir(cBase + "/tempo")
	StzMakeDir(cBase + "/Videos")
	write(cBase + "/test.txt", "program starts here" + nl + "second line" + nl + "program ends")
	write(cBase + "/Images/image1.png", "x")
	write(cBase + "/Images/image2.png", "x")
	write(cBase + "/Images/notes/howto.txt", "x")
	write(cBase + "/Images/notes/sources.txt", "x")
	write(cBase + "/tempo/temp1.txt", "program one" + nl + "two" + nl + "program three")
	write(cBase + "/tempo/temp2.txt", "alpha" + nl + "program beta")
	return cBase

func RemoveTestArea(cBase)
	if dirExists(cBase) RemoveFolderRecursive(cBase) ok
