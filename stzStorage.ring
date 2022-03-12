
class stzStorage from stzObject
	cStorageType	# :InFile, :InMemory, :InDatabase, or
			# any combination of them (:InFile + :InMemory, ...)

	cStoragePath

	cFileName
	cCompleteFileName
	FileHandler

	cMemString
	cDatabaseName

	def init(pcStoragePath, pcStorageName, pcStorageType)
		cFileName = pcStorageName + ".txt"
		cCompleteFileName = pcStoragePath + "/" + cFileName

		cStorageType = pcStorageType

/* TODO
		oTempStr = new stzString(pcSoragePath)
		if oTempStr.LastChar() = "/" or
		   oTempStr.LastChar() = "\"
			pcStoragePath = oTempStr.RemoveLastChar()
		ok
*/

		cStoragePath = pcStoragePath

		switch pcStorageType
		on :InFile
			FileHandler = TextFileCreateIfInexistant(cCompleteFileName)

		on :InMemmory
			// cMemString = ""

		on :InDatabase
			// Create the SQLite database

		other
			stzWarning(:InsupportedStorageType)
		off

	def Delete()

	def FileHandler()
		return FileHandler

	def FileName()
		return cFileName

	def CompleteFileName()
		return cCompleteFileName

	def StorageType()
		return cStorageType
