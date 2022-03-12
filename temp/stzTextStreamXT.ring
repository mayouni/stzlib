

class stzTextStream
	oQTextStream

	  #----------#
	 #   INIT   #
	#----------#

	def init()
		oQTextStream = new QTextStream()

	  #------------#
	 #   CREATE   #
	#------------#

	// Set the stream from a text string
	def SetString(pcString, pcOpeningMode)
		oQString = new QString()
		oQString.append(pcString)

		return oQTextStream.setString(oQString, pcOpeningMode)

	// Set the stream from a binary string

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
			raise(stzTextStreamError(:UnsupportedStatus))
		off

		return oQTextStream.setStatus(n)

	def SetLocale(pcLocale)
		return oQTextStream.setLocale(pcLocale)

	def SetFile(poQFile)
		// pcDevice can be a QFile, QBuffer or QTCPSocket!
		return oQTextStream.setDevice(poQFile)

	  #------------#
	 #   FIELDS   #
	#------------#

	def SetFieldAlignment(n)
		return oQTextStream.setFieldAlignment(n)

	def SetFiedlWidth(n)
		return oQTextStream.setFieldWidth(n)

	def SetPadChar(pcChar)
		oChar= new stzChar(pcChar)
		return oQTextStream.setPadChar(oChar.Object())

	  #----------#
	 #   INFO   #
	#----------#

	def Pointer()
		return oQTextStream.ObjectPointer()

	def IsUnicodeAutoDetected()
		return oQTextStream.autoDetectUnicode()

	def TextEncoding()
		return oQTextStream.codec()

	def Device()
		return oQTextStream.device()

	def FieldAlignment()
		return oQTextStream.fieldAlignment()

	def FieldWidth()
		return oQTextStream.fieldWidth()

	def Status()
		switch oQTextStream.status()
		on 0	return :Ok
		on 1	return :ReadPastEnd
		on 2	return :ReadCorruptData
		on 3	return :WriteFailed
		off

	def Locale()
		return oQTextStream.locale()

	def PadChar()
		return oQTextStream.padChar()

	  #----------#
	 #   READ   #
	#----------#

	def Position()
		return oQTextStream.pos()

	def Read(n)
		return oQTextStream.read(n)

	def ReadAll()
		return oQTextStream.readAll()

	def ReadLine(n)
		return oQTextStream.readLine(n)

	def Seek(n)
		return oQTextStream.seek(n)

	def SkipWhiteSpace()
		return oQTextStream.skipWhiteSpace()

	def IsEndOfStream()
		return oQTextStream.atEnd()

	  #-------------#
	 #   ACTIONS   #
	#-------------#

	def Delete()
		oQTextStream.delete()


	def Flush()
		return oQTextStream.flash()

	def GenerateBOM()
		return oQTextStream.generateByteOrderMark()

	def Reset()
		return oQTextStream.reset()

	def ResetStatus()
		return oQTextStream.resetStatus()

	  #-------------#
	 #   NUMBERS   #
	#-------------#

	def IntegerBase()
		return oQTextStream.integerBase()

	def SetIntegerBase(n)
		// usually, n can be 0 (unkowan), 2 (binary),
		// 8 (octal), 10 (decimal), or 16 (hexadecimal)
		return oQTextStream.setIntegerBase(n)


	def NumberFlags()
		return oQTextStream.numberFlags()

	def SetNumberFlags(aFlags)
		/*
		specifies various flags that can be set to affect
		the output of integers, floats, and doubles.

		aFlags can be composed of:
		:ShowBase
			Show the base as a prefix if the base is 16 ("0x"),
			8 ("0"), or 2 ("0b")
		:ForcePoint
			Always put the decimal separator in numbers,
			even if there are no decimals
		:ForceSign
			Always put the sign in numbers, even for positive numbers
		:UppercaseBase
			Use uppercase versions of base prefixes ("0X", "0B")
		:UppercaseDigits
			Use uppercase letters for expressing digits 10 to 35
			instead of lowercase
		
		*/
		return oQTextStream.setNumberFlags(aFlags)

	def RealNumberNotation()
		return oQTextStream.realNumberNotation()

	def SetRealNumberNotation(p)
		return oQTextStream.setRealNumberNotation(p)

	def RealNumberPrecision()
		return oQTextStream.realNumberPrecision()

	def SetRealNumberPrecision(n)
		return oQTextStream.setRealNumberPrecision(n)


	
