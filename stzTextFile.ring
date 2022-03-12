class stzTextFile from stzFile
	cFile
	cFile
	cOpenMode
	fPointer

	def init(pcPath, pcFileName, pcOpenMode)
		fPointer = CreateIfInexistant(pcPath, pcFileName, pcOpenMode)

