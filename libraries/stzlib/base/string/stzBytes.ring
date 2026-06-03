#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZBYTES                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Binary buffer -- Engine-backed (Zig DLL).   #
#                  Create, manipulate, encode/decode binary     #
#                  data. Base64, hex, percent encoding.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzBytesQ(pData)
	return new stzBytes(pData)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzBytes

	@pEngine = NULL

	def init(pData)
		if isString(pData)
			if pData = ""
				@pEngine = StzEngineBytesNew()
			else
				@pEngine = StzEngineBytesFrom(pData)
			ok
		but isList(pData) and ring_len(pData) = 0
			@pEngine = StzEngineBytesNew()
		else
			@pEngine = StzEngineBytesNew()
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return StzEngineBytesData(@pEngine)

		def Data()
			return This.Content()

	def Size()
		return StzEngineBytesSize(@pEngine)

		def NumberOfBytes()
			return This.Size()

		def Count()
			return This.Size()

	def IsEmpty()
		return StzEngineBytesIsEmpty(@pEngine)

	def ByteAt(n)
		return StzEngineBytesAt(@pEngine, n)

		def At(n)
			return This.ByteAt(n)

	  #===============================#
	 #     SLICING                   #
	#===============================#

	def Left(n)
		return StzEngineBytesLeft(@pEngine, n)

	def Right(n)
		return StzEngineBytesRight(@pEngine, n)

	def Mid(nStart, nLen)
		return StzEngineBytesMid(@pEngine, nStart, nLen)

		def Section(nStart, nLen)
			return This.Mid(nStart, nLen)

	  #===============================#
	 #     MODIFICATION              #
	#===============================#

	def Append(cData)
		StzEngineBytesAppend(@pEngine, cData)

		def AppendQ(cData)
			This.Append(cData)
			return This

	def Insert(nPos, cData)
		StzEngineBytesInsert(@pEngine, nPos, cData)

		def InsertQ(nPos, cData)
			This.Insert(nPos, cData)
			return This

	def Remove(nStart, nLen)
		StzEngineBytesRemove(@pEngine, nStart, nLen)

		def RemoveQ(nStart, nLen)
			This.Remove(nStart, nLen)
			return This

	def Replace(nStart, nLen, cData)
		StzEngineBytesReplace(@pEngine, nStart, nLen, cData)

		def ReplaceQ(nStart, nLen, cData)
			This.Replace(nStart, nLen, cData)
			return This

	def Fill(nByte, nCount)
		StzEngineBytesFill(@pEngine, nByte, nCount)

		def FillQ(nByte, nCount)
			This.Fill(nByte, nCount)
			return This

	def Resize(nNewSize)
		StzEngineBytesResize(@pEngine, nNewSize)

		def ResizeQ(nNewSize)
			This.Resize(nNewSize)
			return This

	def Clear()
		StzEngineBytesClear(@pEngine)

		def ClearQ()
			This.Clear()
			return This

	  #===============================#
	 #     CASE CONVERSION           #
	#===============================#

	def ToLower()
		return StzEngineBytesToLower(@pEngine)

	def ToUpper()
		return StzEngineBytesToUpper(@pEngine)

	  #===============================#
	 #     ENCODING                  #
	#===============================#

	def ToBase64()
		return StzEngineBytesToBase64(@pEngine)

	def FromBase64(cBase64)
		StzEngineBytesFromBase64(@pEngine, cBase64)

		def FromBase64Q(cBase64)
			This.FromBase64(cBase64)
			return This

	def ToHex()
		return StzEngineBytesToHex(@pEngine)

	def FromHex(cHex)
		StzEngineBytesFromHex(@pEngine, cHex)

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	def ToPercent()
		return StzEngineBytesToPercent(@pEngine)

	def FromPercent(cPercent)
		StzEngineBytesFromPercent(@pEngine, cPercent)

		def FromPercentQ(cPercent)
			This.FromPercent(cPercent)
			return This

	  #===============================#
	 #     LIFECYCLE                 #
	#===============================#

	def Free()
		if @pEngine != NULL
			StzEngineBytesFree(@pEngine)
			@pEngine = NULL
		ok
