

# Wraps the RingQt text stream to read text from an attached device, line by line or all at once.
#
# It is a thin wrapper over QTextStream and needs RingQt: load guilib.ring before stzlib, otherwise
# building one raises class not found: qtextstream. Attach a device with SetFromProcess or
# SetFromScocket (any open RingQt device works, such as a QBuffer over a QByteArray), then read with
# ReadAll, Lines or ReadLine. Reading consumes the device: a second ReadAll finds nothing, and
# ReadLine takes the whole rest to hand back one line. The class is mostly unfinished today:
# SetFromFile raises R20, SetEncoding raises Bad parameter type!, SetLocale ends the Ring process,
# Flush and IsSetFromProcess raise on misspelled names, IsSetFromFile and IsSetFromSocket never
# become TRUE, SetStatus changes nothing, and text that is not ASCII (Hebrew, Arabic, emoji) is read
# back garbled. Reading plain ASCII text works.
#
#   receiver   load "guilib.ring" o1 = new stzTextStream()
#   example    oBA = new QByteArray()
#              oBA.append("alpha" + char(10) + "beta")
#              oBuf = new QBuffer(NULL)
#              oBuf.setData(oBA)
#              oBuf.open(1)
#              o1.SetFromProcess(oBuf)
#              ? @@( o1.Lines() )
#              #--> [ "alpha", "beta" ]
#              ? o1.Status()
#              #--> ok
#   see        stzString, stzFile, stzStringLines
class stzTextStream from stzObject
	_oQTextStream_

	_cSourceOfStream_
	_bIsSetFromFile_
	_bIsSetFromSocket_
	_bIsSetFromProcess_

	  #----------#
	 #   INIT   #
	#----------#

	# Builds a text stream, a thin wrapper over the RingQt QTextStream with no device attached yet.
	#
	#   returns    nothing; the object is built
	#   note       build it, then attach a device with SetFromProcess or SetFromScocket; SetFromFile
	#              is broken today
	#   warning    raises R11 class not found: qtextstream unless RingQt is loaded first with load
	#              "guilib.ring", which stzlib does not do
	#   see        SetFromProcess, ReadAll
	def init()
		_oQTextStream_ = new QTextStream()

	  #------------#
	 #   CREATE   #
	#------------#

	# Raises error R20 today instead of attaching a file as the source of the stream.
	#
	#   pcFile     the path of the file to read
	#   returns    nothing
	#   note       attach an open RingQt device with SetFromProcess instead
	#   warning    raises Calling function with extra number of parameters (R20): it builds new
	#              stzFile(pcFile, :WriteToEnd) and stzFile takes one parameter; nothing is attached
	#              and SourceOfStream stays NULL (checked on a scratch file, twice)
	#   see        SetFromProcess, ReadAll
	#@ aka  Sets the string from a QFile or QSocket or QProcess
	def SetFromFile(pcFile)
		_oFile_ = new stzFile(pcFile, :WriteToEnd)
		_oQTextStream_.setDevice(_oFile_.Pointer())

		This.SetSourceOfStreamTo(:File)

	# Attaches an open RingQt socket object as the source of the stream and records the source as a socket.
	#
	#   poQSocket   the RingQt socket object, such as a QTcpSocket
	#   returns     nothing; the object is attached
	#   note        an unconnected QTcpSocket is accepted
	#   warning     the name is misspelled (Scocket); a number raises Bad parameter type! and
	#               nothing checks that the object is really a socket (a TODO in the code); not run
	#               against a connected socket
	#   see         SetFromProcess, SourceOfStream
	def SetFromScocket(poQSocket)
		// TODO: check this is really a socket
		_oQTextStream_.setDevice(poQSocket)

		This.SetSourceOfStreamTo(:Socket)

	# Attaches a RingQt device object as the source of the stream and records the source as a process.
	#
	#   poQProcess   the RingQt device object, a QProcess in intention
	#   returns      nothing; the object is attached
	#   note         an open QBuffer over a QByteArray reads text from memory
	#   warning      nothing checks that the object is really a process (a TODO in the code); not
	#                run with a started process, only with an unstarted QProcess and an in-memory
	#                QBuffer
	#   see          SetFromScocket, ReadAll
	def SetFromProcess(poQProcess)
		// TODO: check this is really a process
		_oQTextStream_.setDevice(poQProcess)

		This.SetSourceOfStreamTo(:Process)

	  #--------------#
	 #   SETTINGS   #
	#--------------#

	# Sets whether the stream writes a byte order mark when it writes Unicode text.
	#
	#   bTrueOrFalse   1 to write the mark, 0 not to
	#   returns        nothing
	#   note           the stream is used for reading here, so it has no visible effect
	#   see            SetEncoding, SetAutoDetectUnicode
	def SetBOM(bTrueOrFalse)
		return _oQTextStream_.setGenerateByteOrderMark(bTrueOrFalse)

	# Sets whether the stream recognises UTF-16 and UTF-32 text by its byte order mark when reading.
	#
	#   bTrueOrFalse   1 to detect, 0 not to
	#   returns        nothing
	#   note           IsUnicodeAutoDetected reads it back: 1 by default, 0 after
	#                  SetAutoDetectUnicode(0)
	#   see            IsUnicodeAutoDetected, SetEncoding
	def SetAutoDetectUnicode(bTrueOrFalse)
		return _oQTextStream_.setAutodetectUnicode(bTrueOrFalse)

	# Raises error Bad parameter type! today instead of selecting the stream's text encoding by name.
	#
	#   pcEncodingName   the encoding name, such as UTF-8
	#   returns          nothing
	#   note             so the codec cannot be changed from here, and non-ASCII text read comes
	#                    back garbled (see ReadAll)
	#   warning          raises for UTF-8, utf8 and ISO-8859-1; only an empty text passes, and it
	#                    selects nothing; the underlying call wants a QTextCodec object, which this
	#                    class cannot build
	#   see              TextEncoding, ReadAll
	def SetEncoding(pcEncodingName)
		return _oQTextStream_.setCodec(pcEncodingName)

	# Accepts a status name and answers 1 without changing the stream's status.
	#
	#   pcStatus   one of the names Ok, ReadPastEnd, ReadCorruptData or WriteFailed
	#   returns    1; an unknown name raises R3 Calling Function without definition:
	#              stztextstreamerror
	#   note       read the status with Status
	#   warning    the status is never set: after SetStatus(:ReadPastEnd), Status still answers ok
	#   see        Status, ResetStatus
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

	# Ends the Ring process today, without any message and with exit code 1, instead of setting the stream's locale.
	#
	#   pcLocale   a locale, passed on to the QTextStream
	#   returns    nothing
	#   note       do not call it
	#   warning    ends the process for the text C and for the number 1 (two calls, same result);
	#              the underlying call wants a QLocale object
	#   see        Locale
	def SetLocale(pcLocale)
		return _oQTextStream_.setLocale(pcLocale)

	  #----------#
	 #   INFO   #
	#----------#

	# Returns the RingQt QTextStream object that does the reading.
	#
	#   returns    a RingQt object
	#   see        FilePointer, TextEncoding
	def Pointer()
		return _oQTextStream_.ObjectPointer()

	# Returns the kind of source attached last, as lower-case text.
	#
	#   returns    a text: process or socket; NULL before any source is attached
	#   note       the text is lower case because the code writes :Process and :Socket
	#   warning    file never appears, since SetFromFile does not work
	#   see        SetFromProcess, SetFromScocket
	def SourceOfStream()
		return _cSourceOfStream_

	# Returns a flag meant to tell that the stream reads a file, which stays NULL or 0 whatever is attached today.
	#
	#   returns    0, or NULL before any source is attached
	#   note       read SourceOfStream instead
	#   warning    never TRUE: the setter writes _bSetFromFile_ while the getter reads
	#              _bIsSetFromFile_, two different attributes
	#   see        IsSetFromSocket, SourceOfStream
	def IsSetFromFile()
		return _bIsSetFromFile_

	# Returns a flag meant to tell that the stream reads a socket, which stays NULL or 0 whatever is attached today.
	#
	#   returns    0, or NULL before any source is attached
	#   note       read SourceOfStream instead
	#   warning    never TRUE: after SetFromScocket it answers 0 while SourceOfStream answers
	#              socket; the setter writes _bSetFromSocket_ and the getter reads
	#              _bIsSetFromSocket_
	#   see        IsSetFromFile, SourceOfStream
	def IsSetFromSocket()
		return _bIsSetFromSocket_

	# Raises error R24 today instead of telling that the stream reads a process.
	#
	#   returns    nothing
	#   note       read SourceOfStream instead
	#   warning    raises Using uninitialized variable: reurn, a misspelled return, before and after
	#              SetFromProcess
	#   see        IsSetFromFile, SourceOfStream
	def IsSetFromProcess()
		reurn _bIsSetFromProcess_

	# TRUE if the stream recognises UTF-16 and UTF-32 text by its byte order mark.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       1 on a new stream
	#   see        SetAutoDetectUnicode, TextEncoding
	def IsUnicodeAutoDetected()
		return _oQTextStream_.autoDetectUnicode()

	# Returns the RingQt QTextCodec object the stream decodes its text with.
	#
	#   returns    a RingQt object
	#   see        SetEncoding, Pointer
	def TextEncoding()
		return _oQTextStream_.codec()

	# Returns the RingQt device object attached to the stream, whatever kind it is.
	#
	#   returns    a RingQt object
	#   note       the same call as SocketPointer and ProcessPointer; the name does not mean the
	#              source is a file
	#   see        SocketPointer, ProcessPointer, Pointer
	def FilePointer()
		return _oQTextStream_.device()

	# Returns the RingQt device object attached to the stream, whatever kind it is.
	#
	#   returns    a RingQt object
	#   note       the same call as FilePointer and ProcessPointer; the name does not mean the
	#              source is a socket
	#   see        FilePointer, ProcessPointer
	def SocketPointer()
		return _oQTextStream_.device()

	# Returns the RingQt device object attached to the stream, whatever kind it is.
	#
	#   returns    a RingQt object
	#   note       the same call as FilePointer and SocketPointer; the name does not mean the source
	#              is a process
	#   see        FilePointer, SocketPointer
	def ProcessPointer()
		return _oQTextStream_.device()

	# Returns the stream's status as lower-case text.
	#
	#   returns    a text: ok on a healthy stream; the code also names readpastend, readcorruptdata
	#              and writefailed, which were not observed
	#   note       ok on a new stream and after reading to the end
	#   see        SetStatus, ResetStatus
	def Status()
		switch _oQTextStream_.status()
		on 0	return :Ok
		on 1	return :ReadPastEnd
		on 2	return :ReadCorruptData
		on 3	return :WriteFailed
		off

	# Returns the RingQt QLocale object the stream uses.
	#
	#   returns    a RingQt object
	#   see        SetLocale
	def Locale()
		return _oQTextStream_.locale()

	  #----------#
	 #   READ   #
	#----------#

	# Reads everything left on the device and returns it as one text, leaving nothing to read.
	#
	#   returns    a text; an empty text when nothing is left or no device is attached
	#   note       for Hebrew, Arabic or emoji text read the bytes through another route
	#   warning    a second call returns an empty text, since the first consumed the device; non-
	#              ASCII text comes back garbled: Hebrew שלום returned as four Latin-1 character
	#              pairs, and the same for an Arabic line and an emoji line (three lines, one call),
	#              probably because the stream decodes with a Latin-1 codec that SetEncoding cannot
	#              change; ASCII text is exact
	#   see        Lines, ReadLine
	def ReadAll()
		return _oQTextStream_.readAll()

	# Reads everything left on the device and returns it as a list of lines.
	#
	#   returns    a list of text; [ ] when nothing is left
	#   note       alpha, beta and gamma on three lines give [ alpha, beta, gamma ]
	#   warning    consumes the device as ReadAll does, so a second call returns [ ]; non-ASCII text
	#              comes back garbled as for ReadAll
	#   see        ReadAll, ReadLine
	def Lines()
		_oStzStr_ = new stzString(This.ReadAll())
		return _oStzStr_.Lines()

	# Reads everything left on the device and returns the line at a position, discarding the other lines.
	#
	#   n          the 1-based position of the line
	#   returns    a text
	#   note       take Lines once and index it
	#   warning    it does not read one line: all the lines are consumed, so a second call finds
	#              nothing; a position of 0 or past the last line raises Array Access (Index out of
	#              range) (R2); non-ASCII text comes back garbled as for ReadAll
	#   see        Lines, ReadAll
	def ReadLine(n)
		return This.Lines()[n]


	  #-------------#
	 #   ACTIONS   #
	#-------------#

	# Frees the underlying RingQt QTextStream.
	#
	#   returns    nothing
	#   note       the helper must not be used afterwards; it does not close the device
	#   see        Pointer
	def Delete()
		_oQTextStream_.delete()


	# Raises error R14 today instead of flushing the stream.
	#
	#   returns    nothing
	#   note       nothing needs flushing for a reading stream
	#   warning    raises Calling Method without definition: flash, a misspelled call to flush on
	#              the QTextStream
	#   see        Reset
	def Flush()
		return _oQTextStream_.flash()

	# Resets the stream's number and field formatting to its defaults, without rewinding the device.
	#
	#   returns    nothing
	#   note       seek the device back yourself to read again
	#   warning    after ReadAll, Reset and another ReadAll the second read is empty, and
	#              SetAutoDetectUnicode(0) survives it
	#   see        ResetStatus, ReadAll
	def Reset()
		return _oQTextStream_.reset()

	# Resets the stream's status to ok.
	#
	#   returns    nothing
	#   see        Status, SetStatus
	def ResetStatus()
		return _oQTextStream_.resetStatus()

	  #---------------------#
	 #   PRIVATE KITCHEN   #
	#---------------------#

	PRIVATE

	# Records which kind of source feeds the stream.
	#
	#   pcSource   the kind, File, Socket or Process
	#   returns    nothing
	#   note       it is called by the three SetFrom methods
	#   warning    private: calling it from outside raises R26 Calling private method from outside
	#              the class; inside, it writes attributes the IsSetFrom getters do not read
	#   see        SourceOfStream
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
	
