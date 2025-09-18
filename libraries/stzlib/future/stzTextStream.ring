

class stzTextStream from stzObject
	oQTextStream

	cSourceOfStream
	bIsSetFromFile
	bIsSetFromSocket
	bIsSetFromProcess

	  #----------#
	 #   INIT   #
	#----------#

	def init()
		oQTextStream = new QTextStream()

	  #------------#
	 #   CREATE   #
	#------------#

	# Sets the string from a QFile or QSocket or QProcess
	def SetFromFile(pcFile)
		oFile = new stzFile(pcFile, :WriteToEnd)
		oQTextStream.setDevice(oFile.Pointer())

		This.SetSourceOfStreamTo(:File)

	def SetFromScocket(poQSocket)
		// TODO: check this is really a socket
		oQTextStream.setDevice(poQSocket)

		This.SetSourceOfStreamTo(:Socket)

	def SetFromProcess(poQProcess)
		// TODO: check this is really a process
		oQTextStream.setDevice(poQProcess)

		This.SetSourceOfStreamTo(:Process)

	  #--------------#
	 #   SETTINGS   #
	#--------------#

	def SetBOM(bTrueOrFalse)
		return oQTextStream.setGenerateByteOrderMark(bTrueOrFalse)

	def SetAutoDetectUnicode(bTrueOrFalse)
		return oQTextStream.setAutodetectUnicode(bTrueOrFalse)

	def SetEncoding(pcEncodingName)
		return oQTextStream.setCodec(pcEncodingName)

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
		return oQTextStream.setLocale(pcLocale)

	  #----------#
	 #   INFO   #
	#----------#

	def Pointer()
		return oQTextStream.ObjectPointer()

	def SourceOfStream()
		return cSourceOfStream

	def IsSetFromFile()
		return bIsSetFromFile

	def IsSetFromSocket()
		return bIsSetFromSocket

	def IsSetFromProcess()
		reurn bIsSetFromProcess

	def IsUnicodeAutoDetected()
		return oQTextStream.autoDetectUnicode()

	def TextEncoding()
		return oQTextStream.codec()

	def FilePointer()
		return oQTextStream.device()

	def SocketPointer()
		return oQTextStream.device()

	def ProcessPointer()
		return oQTextStream.device()

	def Status()
		switch oQTextStream.status()
		on 0	return :Ok
		on 1	return :ReadPastEnd
		on 2	return :ReadCorruptData
		on 3	return :WriteFailed
		off

	def Locale()
		return oQTextStream.locale()

	  #----------#
	 #   READ   #
	#----------#

	def ReadAll()
		return oQTextStream.readAll()

	def Lines()
		oStzStr = new stzString(This.ReadAll())
		return oStzStr.Lines()

	def ReadLine(n)
		return This.Lines()[n]


	  #-------------#
	 #   ACTIONS   #
	#-------------#

	def Delete()
		oQTextStream.delete()


	def Flush()
		return oQTextStream.flash()

	def Reset()
		return oQTextStream.reset()

	def ResetStatus()
		return oQTextStream.resetStatus()

	  #---------------------#
	 #   PRIVATE KITCHEN   #
	#---------------------#

	PRIVATE

	def SetSourceOfStreamTo(pcSource)
		bIsSetFromFile = 0
		bIsSetFromSocket = 0
		bIsSetFromProcess = 0
	
		switch pcSource
		on :File
			cSourceOfStream = :File
			bSetFromFile = 1
		on :Socket
			cSourceOfStream = :Socket
			bSetFromSocket = 1
		on :Process
			cSourceOfStream = :Process
			bSetFromProcess = 1
		off
	
