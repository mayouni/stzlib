/*
fHandler = fopen("c.txt","r")	// how to knwo that the file has been opened
? fHandler			// Ring returnd a value of type file beginning by 00000


if fexists("c.txt")
	? "file has been created"
else
	? "file is not created"
ok
*/

o1 = new stzFile("abc.txt")
? o1.Status()
? o1.Handler()

class stzFile from stzObject
	fHandler
	cFile = pcfile
	cStatus = :NULL

	aHistory = []

	// When initated for the first time, a file is
	// physically created and then immedidatly closed
	def init(pcfile)
		if fexists(pcfile)
			raise("file already exists!")
			// Replace with
			stzError(:CanNotCreateExistantFile)
			raise(stzError(:CanNotCreateExistantFile))
		ok

		// This is a new file, create it...
		fTempHandler = fopen(pcfile,"r")

		// If the file has been correctly created
		if fexists(pcfile)
			// then we initiate our stzFile object
			cFile = pcFile
			cStatus = :Created
			aHistory + cStatus
			// and we close it
			fclose(fTempHandler)
		else
			raise("File has not been correctly created!")
		ok

	def Status()
		return cStatus

	def History()
		return aHistory

	def IsExistant()
		return fexists(cFile)

	def Handler()
		return fHandler
