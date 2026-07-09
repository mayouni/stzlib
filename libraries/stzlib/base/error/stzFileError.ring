
func stzFileError(pcError)
	_cErrorMsg_ = "in file stzFile.ring:" + NL

	switch pcError
	on :CanNotProceedWithOpeningMode
		_cErrorMsg_ += "   What : Can't proceed with the open mode you provided." + NL
		_cErrorMsg_ += "   Why  : The open mode you provided is not supported." + NL
		_cErrorMsg_ += "   Todo : Select one of the three supported modes (:ReadOnly, :WriteToEnd, or :EraseAndWrite)."

	on :CanNotOpenInexistantFileForReading
		_cErrorMsg_ += "   What : Can't open a file for reading while it is inexistant." + NL
		_cErrorMsg_ += "   Why  : It's absurde to open a file that doses not exist!" + NL
		_cErrorMsg_ += "   Todo : To create the file use one of these openeing modes (:WriteToEnd, or :EraseAndWrite)."

	on :CanNotCreateExistantFile
		_cErrorMsg_ += "   What : Can't create the file." + NL
		_cErrorMsg_ += "   Why  : File of the name you provided already exists." + NL
		_cErrorMsg_ += "   Todo : Give a new file name and it will be fine :)"

	on :CanNotReadFileContent
		_cErrorMsg_ += "   What : Can't read the file content." + NL
		_cErrorMsg_ += "   Why  : File is either inaccessible or opened with the wrong mode." + NL
		_cErrorMsg_ += "   Todo : Check that it exists, or that you opened it using ':ReadOnly' mode."

	on :CanNotWriteToFile
		_cErrorMsg_ += "   What : Can't write to the file." + NL
		_cErrorMsg_ += "   Why  : File is either inaccessible or opened on the wrong mode." + NL
		_cErrorMsg_ += "   Todo : Check that you opened it using ':WriteToEnd' or ':EraseAndWrite' modes."

	on :CanNotRenameInexistantFile
		_cErrorMsg_ += "   What : Can't rename the file." + NL
		_cErrorMsg_ += "   Why  : File of the name you provided does not exist." + NL
		_cErrorMsg_ += "   Todo : Give a new file name that exists and it will be fine :)"

	on :CanNotRemoveInexistantFile
		_cErrorMsg_ += "   What : Can't remove the file." + NL
		_cErrorMsg_ += "   Why  : File of the name you provided does not exist." + NL
		_cErrorMsg_ += "   Todo : Give a new file name that exists and it will be fine :)"

	on :CanNotCopyInexistantFile
		_cErrorMsg_ += "   What : Can't copy the file." + NL
		_cErrorMsg_ += "   Why  : Source file you provided does not exist." + NL
		_cErrorMsg_ += "   Todo : Give a new file name that exists and it will be fine :)"

	on :CanNotCopyFileToExistantName
		_cErrorMsg_ += "   What : Can't copy the file." + NL
		_cErrorMsg_ += "   Why  : Target file already exists." + NL
		_cErrorMsg_ += "   Todo : Give a new file name that does not exist and it will be fine :)"


	on :CanNotSetShorcutForInexistantFiles
		_cErrorMsg_ += "   What : Can't transform the file in to a shortcut." + NL
		_cErrorMsg_ += "   Why  : Because, either the file or the file target you provided does not exist." + NL
		_cErrorMsg_ += "   Todo : Give a name of a file that exists and it will be fine :)"

	on :CanNotWriteInFile
		_cErrorMsg_ += "   What : Can't write in the file." + NL
		_cErrorMsg_ += "   Why  : Either the file does not exist, or you don't have the right to write in it, or for any other reason." + NL
		_cErrorMsg_ += "   Todo : Verify that the file exists. If so, verify you have the right to write into it. Otherwise, I can't help you :("

	on :CanNotReadFileContentInThisOpeningMode
		_cErrorMsg_ += "   What : Can't read file." + NL
		_cErrorMsg_ += "   Why  : Current opening mode does not support reading." + NL
		_cErrorMsg_ += "   Todo : Use an opening mode that enables reading."

	on :CanNotWriteToFileInThisOpeningMode
		_cErrorMsg_ += "   What : Can't write to the file." + NL
		_cErrorMsg_ += "   Why  : Current opening mode does not support writing." + NL
		_cErrorMsg_ += "   Todo : Use an opening mode that enables writing."

	on :UnsupportedModeInOpeningFile
		_cErrorMsg_ += "   What : Error in opening mode." + NL
		_cErrorMsg_ += "   Why  : Opening mode you provided is not supported." + NL
		_cErrorMsg_ += "   Todo : Use one of the supported opening modes."

	on :CanNotChangeFileOpeneningMode
		_cErrorMsg_ += "   What : Can not change current opening mode." + NL
		_cErrorMsg_ += "   Why  : Sorry, can't help :(" + NL
		_cErrorMsg_ += "   Todo : Ask a question in the Ring forum."

	on :CanNotLoadFileContent
		_cErrorMsg_ += "   What : Can not load file content." + NL
		_cErrorMsg_ += "   Why  : read() function was enable to load content." + NL
		_cErrorMsg_ += "   Todo : Ask a question in the Ring forum."

	on :CanNotWriteContentToFile
		_cErrorMsg_ += "   What : Can not write content in file." + NL
		_cErrorMsg_ += "   Why  : write() function was enable to write content." + NL
		_cErrorMsg_ += "   Todo : Ask a question in the Ring forum."

	on :CanNotReadFromFile
		_cErrorMsg_ += "   What : Can not read data from file." + NL
		_cErrorMsg_ += "   Why  : fread() function was enable to read data." + NL
		_cErrorMsg_ += "   Todo : Check correctness of function parameters."
	off

	return _cErrorMsg_ + NL
