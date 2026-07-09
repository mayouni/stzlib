

class stzTextStream from stzObject
	_oQTextStream_

	_cSourceOfStream_
	_bIsSetFromFile_
	_bIsSetFromSocket_
	_bIsSetFromProcess_

	  #----------#
	 #   INIT   #
	#----------#

	def init()
		_oQTextStream_ = new QTextStream()

	  #------------#
	 #   CREATE   #
	#------------#

	# Sets the string from a QFile or QSocket or QProcess
	def SetFromFile(pcFile)
		_oFile_ = new stzFile(pcFile, :WriteToEnd)
		_oQTextStream_.setDevice(_oFile_.Pointer())

		This.SetSourceOfStreamTo(:File)

	def SetFromScocket(poQSocket)
		// TODO: check this is really a socket
		_oQTextStream_.setDevice(poQSocket)

		This.SetSourceOfStreamTo(:Socket)

	def SetFromProcess(poQProcess)
		// TODO: check this is really a process
		_oQTextStream_.setDevice(poQProcess)

		This.SetSourceOfStreamTo(:Process)

	  #--------------#
	 #   SETTINGS   #
	#--------------#

	def SetBOM(bTrueOrFalse)
		return _oQTextStream_.setGenerateByteOrderMark(bTrueOrFalse)

	def SetAutoDetectUnicode(bTrueOrFalse)
		return _oQTextStream_.setAutodetectUnicode(bTrueOrFalse)

	def SetEncoding(pcEncodingName)
		return _oQTextStream_.setCodec(pcEncodingName)

	def SetStatus(pcStatus)
		switch pcStatus
		on :Ok			n = 0
		on :ReadPastEnd		n = 1
		on :ReadCorruptData	n = 2
		on :WriteFailed		n = 3
		other
			StzRaise(stzTextStreamError(:UnsupportedStatus))
		off

		return 1

	def SetLocale(pcLocale)
		return _oQTextStream_.setLocale(pcLocale)

	  #----------#
	 #   INFO   #
	#----------#

	def Pointer()
		return _oQTextStream_.ObjectPointer()

	def SourceOfStream()
		return _cSourceOfStream_

	def IsSetFromFile()
		return _bIsSetFromFile_

	def IsSetFromSocket()
		return _bIsSetFromSocket_

	def IsSetFromProcess()
		reurn _bIsSetFromProcess_

	def IsUnicodeAutoDetected()
		return _oQTextStream_.autoDetectUnicode()

	def TextEncoding()
		return _oQTextStream_.codec()

	def FilePointer()
		return _oQTextStream_.device()

	def SocketPointer()
		return _oQTextStream_.device()

	def ProcessPointer()
		return _oQTextStream_.device()

	def Status()
		switch _oQTextStream_.status()
		on 0	return :Ok
		on 1	return :ReadPastEnd
		on 2	return :ReadCorruptData
		on 3	return :WriteFailed
		off

	def Locale()
		return _oQTextStream_.locale()

	  #----------#
	 #   READ   #
	#----------#

	def ReadAll()
		return _oQTextStream_.readAll()

	def Lines()
		_oStzStr_ = new stzString(This.ReadAll())
		return _oStzStr_.Lines()

	def ReadLine(n)
		return This.Lines()[n]


	  #-------------#
	 #   ACTIONS   #
	#-------------#

	def Delete()
		_oQTextStream_.delete()


	def Flush()
		return _oQTextStream_.flash()

	def Reset()
		return _oQTextStream_.reset()

	def ResetStatus()
		return _oQTextStream_.resetStatus()

	  #---------------------#
	 #   PRIVATE KITCHEN   #
	#---------------------#

	PRIVATE

	def SetSourceOfStreamTo(pcSource)
		_bIsSetFromFile_ = 0
		_bIsSetFromSocket_ = 0
		_bIsSetFromProcess_ = 0
	
		switch pcSource
		on :File
			_cSourceOfStream_ = :File
			_bSetFromFile_ = 1
		on :Socket
			_cSourceOfStream_ = :Socket
			_bSetFromSocket_ = 1
		on :Process
			_cSourceOfStream_ = :Process
			_bSetFromProcess_ = 1
		off
	
