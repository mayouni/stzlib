
func stzFileError(pcError)
	cErrorMsg = "in file stzFile.ring:" + NL

	switch pcError
	on :CanNotProceedWithOpeningMode
		cErrorMsg += "   What : Can't proceed with the open mode you provided." + NL
		cErrorMsg += "   Why  : The open mode you provided is not supported." + NL
		cErrorMsg += "   Todo : Select one of the three supported modes (:ReadOnly, :WriteToEnd, or :EraseAndWrite)."

	on :CanNotOpenInexistantFileForReading
		cErrorMsg += "   What : Can't open a file for reading while it is inexistant." + NL
		cErrorMsg += "   Why  : It's absurde to open a file that doses not exist!" + NL
		cErrorMsg += "   Todo : To create the file use one of these openeing modes (:WriteToEnd, or :EraseAndWrite)."

	on :CanNotCreateExistantFile
		cErrorMsg += "   What : Can't create the file." + NL
		cErrorMsg += "   Why  : File of the name you provided already exists." + NL
		cErrorMsg += "   Todo : Give a new file name and it will be fine :)"

	on :CanNotReadFileContent
		cErrorMsg += "   What : Can't read the file content." + NL
		cErrorMsg += "   Why  : File is either inaccessible or opened with the wrong mode." + NL
		cErrorMsg += "   Todo : Check that it exists, or that you opened it using ':ReadOnly' mode."

	on :CanNotWriteToFile
		cErrorMsg += "   What : Can't write to the file." + NL
		cErrorMsg += "   Why  : File is either inaccessible or opened on the wrong mode." + NL
		cErrorMsg += "   Todo : Check that you opened it using ':WriteToEnd' or ':EraseAndWrite' modes."

	on :CanNotRenameInexistantFile
		cErrorMsg += "   What : Can't rename the file." + NL
		cErrorMsg += "   Why  : File of the name you provided does not exist." + NL
		cErrorMsg += "   Todo : Give a new file name that exists and it will be fine :)"

	on :CanNotRemoveInexistantFile
		cErrorMsg += "   What : Can't remove the file." + NL
		cErrorMsg += "   Why  : File of the name you provided does not exist." + NL
		cErrorMsg += "   Todo : Give a new file name that exists and it will be fine :)"

	on :CanNotCopyInexistantFile
		cErrorMsg += "   What : Can't copy the file." + NL
		cErrorMsg += "   Why  : Source file you provided does not exist." + NL
		cErrorMsg += "   Todo : Give a new file name that exists and it will be fine :)"

	on :CanNotCopyFileToExistantName
		cErrorMsg += "   What : Can't copy the file." + NL
		cErrorMsg += "   Why  : Target file already exists." + NL
		cErrorMsg += "   Todo : Give a new file name that does not exist and it will be fine :)"


	on :CanNotSetShorcutForInexistantFiles
		cErrorMsg += "   What : Can't transform the file in to a shortcut." + NL
		cErrorMsg += "   Why  : Because, either the file or the file target you provided does not exist." + NL
		cErrorMsg += "   Todo : Give a name of a file that exists and it will be fine :)"

	on :CanNotWriteInFile
		cErrorMsg += "   What : Can't write in the file." + NL
		cErrorMsg += "   Why  : Either the file does not exist, or you don't have the right to write in it, or for any other reason." + NL
		cErrorMsg += "   Todo : Verify that the file exists. If so, verify you have the right to write into it. Otherwise, I can't help you :("

	on :CanNotReadFileContentInThisOpeningMode
		cErrorMsg += "   What : Can't read file." + NL
		cErrorMsg += "   Why  : Current opening mode does not support reading." + NL
		cErrorMsg += "   Todo : Use an opening mode that enables reading."

	on :CanNotWriteToFileInThisOpeningMode
		cErrorMsg += "   What : Can't write to the file." + NL
		cErrorMsg += "   Why  : Current opening mode does not support writing." + NL
		cErrorMsg += "   Todo : Use an opening mode that enables writing."

	on :UnsupportedModeInOpeningFile
		cErrorMsg += "   What : Error in opening mode." + NL
		cErrorMsg += "   Why  : Opening mode you provided is not supported." + NL
		cErrorMsg += "   Todo : Use one of the supported opening modes."

	on :CanNotChangeFileOpeneningMode
		cErrorMsg += "   What : Can not change current opening mode." + NL
		cErrorMsg += "   Why  : Sorry, can't help :(" + NL
		cErrorMsg += "   Todo : Ask a question in the Ring forum."

	on :CanNotLoadFileContent
		cErrorMsg += "   What : Can not load file content." + NL
		cErrorMsg += "   Why  : read() function was enable to load content." + NL
		cErrorMsg += "   Todo : Ask a question in the Ring forum."

	on :CanNotWriteContentToFile
		cErrorMsg += "   What : Can not write content in file." + NL
		cErrorMsg += "   Why  : write() function was enable to write content." + NL
		cErrorMsg += "   Todo : Ask a question in the Ring forum."

	on :CanNotReadFromFile
		cErrorMsg += "   What : Can not read data from file." + NL
		cErrorMsg += "   Why  : fread() function was enable to read data." + NL
		cErrorMsg += "   Todo : Check correctness of function parameters."
	off

	return cErrorMsg + NL
