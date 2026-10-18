

# Wraps the RingQt text stream to read text from an attached device, line by line or all at once.
#
# It is a thin wrapper over QTextStream and needs RingQt: load guilib.ring before stzlib, otherwise
# building one raises class not found: qtextstream. Attach a source with SetFromFile (a file path),
# SetFromProcess or SetFromSocket (any open RingQt device works, such as a QBuffer over a QByteArray),
# then read with ReadAll, Lines or ReadLine. Reading consumes the device: a second ReadAll finds
# nothing, and ReadLine takes the whole rest to hand back one line. IsSetFromFile, IsSetFromSocket and
# IsSetFromProcess tell which kind was attached last, and SourceOfStream names it. The text is decoded
# with the default codec until SetEncoding names another one: plain ASCII is exact either way, while
# Hebrew, Arabic or emoji text is read back garbled unless SetEncoding("UTF-8") was called first.
# SetEncoding applies one of UTF-8, ISO-8859-1 (or latin1), UTF-16, UTF-16LE, UTF-16BE, UTF-32,
# UTF-32LE and UTF-32BE, whatever the letter case, and refuses every other name. The stream is meant
# for reading: SetBOM, Reset and Flush are kept for the writing side, which this class does not offer.
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
	_oFile_
	_cEncoding_

	  #----------#
	 #   INIT   #
	#----------#

	# Builds a text stream, a thin wrapper over the RingQt QTextStream with no device attached yet.
	#
	#   returns    nothing; the object is built
	#   note       build it, then attach a source with SetFromFile, SetFromProcess or SetFromSocket
	#   warning    raises R11 class not found: qtextstream unless RingQt is loaded first with load
	#              "guilib.ring", which stzlib does not do
	#   see        SetFromFile, ReadAll
	def init()
		_oQTextStream_ = new QTextStream()
		_cSourceOfStream_ = ""
		_bIsSetFromFile_ = 0
		_bIsSetFromSocket_ = 0
		_bIsSetFromProcess_ = 0
		_oFile_ = ""
		_cEncoding_ = ""

	  #------------#
	 #   CREATE   #
	#------------#

	# Opens a file for reading and attaches it as the source of the stream, closing any file attached before.
	#
	#   pcFile     the path of the file to read
	#   returns    1 when the file was opened and attached, 0 when it was not (a missing file, a folder,
	#              a path that cannot be read, or a value that is not a text)
	#   note       the file is opened read-only through a RingQt QFile that the stream keeps, and it
	#              stays open until Delete or until another source replaces it, so call Delete when
	#              done; a failed call leaves the stream and its flags as they were
	#   warning    the text is decoded with the default codec: call SetEncoding("UTF-8") for text that
	#              is not ASCII
	#   see        SetFromProcess, SourceOfStream, ReadAll
	#@ aka  Sets the string from a QFile or QSocket or QProcess
	def SetFromFile(pcFile)
		if NOT isString(pcFile)
			return 0
		ok

		_oNewFile_ = new QFile()
		_oNewFile_.setFileName(pcFile)

		if _oNewFile_.exists() = 0
			return 0
		ok

		if _oNewFile_.open_3(1) = 0
			return 0
		ok

		This.ReleaseFile()
		_oFile_ = _oNewFile_
		_oQTextStream_.setDevice(_oFile_)
		This.ReapplyEncoding()

		This.SetSourceOfStreamTo(:File)
		return 1

	# Attaches an open RingQt socket object as the source of the stream and records the source as a socket.
	#
	#   poQSocket   the RingQt socket object, such as a QTcpSocket
	#   returns     1 when the object was attached, 0 when the value is not an object
	#   note        an unconnected QTcpSocket is accepted; a failed call leaves the stream and its
	#               flags as they were
	#   warning     nothing checks that the object is really a socket: any RingQt device object is
	#               taken; not run against a connected socket
	#   see         SetFromProcess, SourceOfStream
	def SetFromSocket(poQSocket)
		if NOT isObject(poQSocket)
			return 0
		ok

		This.ReleaseFile()
		_oQTextStream_.setDevice(poQSocket)
		This.ReapplyEncoding()

		This.SetSourceOfStreamTo(:Socket)
		return 1

	# Keeps the old misspelled name of the call that attaches a socket, with the same result.
	#
	#   poQSocket   the RingQt socket object, such as a QTcpSocket
	#   returns     1 when the object was attached, 0 when the value is not an object
	#   note        kept so that older code still works; write SetFromSocket in new code
	#   see         SetFromSocket
	def SetFromScocket(poQSocket)
		_bDone_ = This.SetFromSocket(poQSocket)
		return _bDone_

	# Attaches a RingQt device object as the source of the stream and records the source as a process.
	#
	#   poQProcess   the RingQt device object, a QProcess in intention
	#   returns      1 when the object was attached, 0 when the value is not an object
	#   note         an open QBuffer over a QByteArray reads text from memory; a failed call leaves the
	#                stream and its flags as they were
	#   warning      nothing checks that the object is really a process: any RingQt device object is
	#                taken; not run with a started process, only with an in-memory QBuffer
	#   see          SetFromSocket, ReadAll
	def SetFromProcess(poQProcess)
		if NOT isObject(poQProcess)
			return 0
		ok

		This.ReleaseFile()
		_oQTextStream_.setDevice(poQProcess)
		This.ReapplyEncoding()

		This.SetSourceOfStreamTo(:Process)
		return 1

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

	# Selects the codec the stream decodes its text with, from a fixed list of encoding names.
	#
	#   pcEncodingName   one of UTF-8, utf8, ISO-8859-1, latin1, UTF-16, UTF-16LE, UTF-16BE, UTF-32,
	#                    UTF-32LE or UTF-32BE, in any letter case
	#   returns          1 when the codec was applied, 0 when the name is not in that list (or is not a
	#                    text); nothing changes then
	#   note             Encoding answers the name that was applied, an empty text before any; UTF-8
	#                    makes Hebrew, Arabic and emoji text read back exact, and the call works before
	#                    or after a source is attached, and survives a later attach
	#   warning          only the names listed are accepted, though Qt knows more; a name outside the
	#                    list is refused and never reaches Qt, which would ignore it silently
	#   see              Encoding, TextEncoding, ReadAll
	def SetEncoding(pcEncodingName)
		if NOT isString(pcEncodingName)
			return 0
		ok

		_cKey_ = " " + StzLower(pcEncodingName) + " "
		_cList_ = " utf-8 utf8 iso-8859-1 latin1 utf-16 utf-16le utf-16be utf-32 utf-32le utf-32be "

		if StzFindFirst(_cKey_, _cList_) = 0
			return 0
		ok

		_oQTextStream_.setCodec_2(pcEncodingName)
		_cEncoding_ = pcEncodingName
		return 1

	# Sets the stream's status to one of four named states, so Status reads it back.
	#
	#   pcStatus   one of the names Ok, ReadPastEnd, ReadCorruptData or WriteFailed
	#   returns    1; an unknown name raises an error naming it
	#   note       read the status with Status; Qt keeps the first problem: once the status is not ok,
	#              a further SetStatus changes nothing until ResetStatus
	#   see        Status, ResetStatus
	def SetStatus(pcStatus)
		switch pcStatus
		on :Ok			n = 0
		on :ReadPastEnd		n = 1
		on :ReadCorruptData	n = 2
		on :WriteFailed		n = 3
		other
			StzRaise("Unsupported status for a text stream: " + pcStatus)
		off

		_oQTextStream_.setStatus(n)
		return 1

	# Sets the locale the stream uses to format and read numbers, from a locale name or a QLocale object.
	#
	#   pcLocale   a locale name such as de_DE or C, or a RingQt QLocale object
	#   returns    1 when the locale was applied, 0 when the value is neither a text nor an object
	#   note       Locale().name() reads it back; a name Qt does not know falls back to the C locale
	#   see        Locale
	def SetLocale(pcLocale)
		if isString(pcLocale)
			_oLocale_ = new QLocale(pcLocale)
		but isObject(pcLocale)
			_oLocale_ = pcLocale
		else
			return 0
		ok

		_oQTextStream_.setLocale(_oLocale_)
		return 1

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
	#   returns    a text: file, process or socket; an empty text before any source is attached
	#   note       the text is lower case because the code writes :File, :Process and :Socket
	#   see        SetFromFile, SetFromProcess, SetFromSocket
	def SourceOfStream()
		return _cSourceOfStream_

	# Tells whether the source attached last is a file.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 0 before any source is attached
	#   note       a failed SetFromFile leaves it as it was
	#   see        IsSetFromSocket, IsSetFromProcess, SourceOfStream
	def IsSetFromFile()
		return _bIsSetFromFile_

	# Tells whether the source attached last is a socket.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 0 before any source is attached
	#   note       true after SetFromSocket and after its old spelling SetFromScocket
	#   see        IsSetFromFile, IsSetFromProcess, SourceOfStream
	def IsSetFromSocket()
		return _bIsSetFromSocket_

	# Tells whether the source attached last is a process.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 0 before any source is attached
	#   note       a device attached with SetFromProcess counts, whatever it really is
	#   see        IsSetFromFile, IsSetFromSocket, SourceOfStream
	def IsSetFromProcess()
		return _bIsSetFromProcess_

	# TRUE if the stream recognises UTF-16 and UTF-32 text by its byte order mark.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       1 on a new stream
	#   see        SetAutoDetectUnicode, TextEncoding
	def IsUnicodeAutoDetected()
		return _oQTextStream_.autoDetectUnicode()

	# Returns the name of the encoding that SetEncoding applied last, as it was written.
	#
	#   returns    a text; an empty text when SetEncoding has not applied a name, which means the
	#              default codec
	#   note       a refused name does not change it
	#   see        SetEncoding, TextEncoding
	def Encoding()
		return _cEncoding_

	# Returns the RingQt QTextCodec object the stream decodes its text with.
	#
	#   returns    a RingQt object
	#   note       RingQt gives no way to read a codec's name: ask Encoding for the name applied
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
	#   returns    a text: ok on a healthy stream, or readpastend, readcorruptdata or writefailed
	#              after SetStatus names one
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
	#   note       call SetEncoding("UTF-8") first for Hebrew, Arabic or emoji text, which is then
	#              exact
	#   warning    a second call returns an empty text, since the first consumed the device; without
	#              SetEncoding, non-ASCII text comes back garbled, each UTF-8 byte read as one Latin-1
	#              character, because the default codec is not UTF-8; ASCII text is exact
	#   see        Lines, ReadLine, SetEncoding
	def ReadAll()
		return _oQTextStream_.readAll()

	# Reads everything left on the device and returns it as a list of lines.
	#
	#   returns    a list of text; [ ] when nothing is left
	#   note       alpha, beta and gamma on three lines give [ alpha, beta, gamma ]
	#   warning    consumes the device as ReadAll does, so a second call returns [ ]; non-ASCII text
	#              comes back garbled as for ReadAll unless SetEncoding("UTF-8") was called
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

	# Frees the underlying RingQt QTextStream and closes the file attached by SetFromFile, if any.
	#
	#   returns    nothing
	#   note       the helper must not be used afterwards; a device attached by SetFromProcess or
	#              SetFromSocket is not closed, since the caller owns it
	#   see        Pointer
	def Delete()
		This.ReleaseFile()
		_oQTextStream_.delete()


	# Pushes any text waiting in the stream's buffer through to its device.
	#
	#   returns    1
	#   note       nothing needs flushing for a reading stream, so it changes nothing visible; it is
	#              safe with no device attached
	#   see        Reset
	def Flush()
		_oQTextStream_.flush()
		return 1

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
	#   note       it is called by the three SetFrom methods; only the flag of the kind given is 1
	#   warning    private: calling it from outside raises R26 Calling private method from outside
	#              the class
	#   see        SourceOfStream
	def SetSourceOfStreamTo(pcSource)
		_bIsSetFromFile_ = 0
		_bIsSetFromSocket_ = 0
		_bIsSetFromProcess_ = 0

		switch pcSource
		on :File
			_cSourceOfStream_ = :File
			_bIsSetFromFile_ = 1
		on :Socket
			_cSourceOfStream_ = :Socket
			_bIsSetFromSocket_ = 1
		on :Process
			_cSourceOfStream_ = :Process
			_bIsSetFromProcess_ = 1
		off

	# Applies the encoding chosen with SetEncoding again, because attaching a device resets the codec.
	#
	#   returns    nothing
	#   note       it is called by the three SetFrom methods after the device is attached; it does
	#              nothing when no encoding was chosen
	#   warning    private: calling it from outside raises R26 Calling private method from outside
	#              the class
	#   see        SetEncoding, SetFromFile
	def ReapplyEncoding()
		if ring_len(_cEncoding_) > 0
			_oQTextStream_.setCodec_2(_cEncoding_)
		ok

	# Closes the file that SetFromFile attached, if there is one, and forgets it.
	#
	#   returns    nothing
	#   note       it is called before another source replaces the file and by Delete
	#   warning    private: calling it from outside raises R26 Calling private method from outside
	#              the class
	#   see        SetFromFile, Delete
	def ReleaseFile()
		if isObject(_oFile_)
			_oFile_.close()
			_oFile_ = ""
		ok

