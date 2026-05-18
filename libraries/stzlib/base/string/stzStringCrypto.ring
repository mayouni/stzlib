#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCRYPTO             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String crypto -- Wraps stzString via         #
#                  composition. Hashing, basic encryption/       #
#                  decryption, checksum operations.              #
#                  All ops are engine-backed (Zig DLL).          #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCrypto

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCrypto! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     HASHING (Engine-backed)   #
	#===============================#

	def Hash()
		pH = @oString.Engine()
		return StzEngineStringHash(pH)

	def Entropy()
		pH = @oString.Engine()
		return StzEngineStringEntropy(pH)

	  #===============================#
	 #     XOR CIPHER (Engine)       #
	#===============================#

	def XOREncrypt(pcKey)
		pH = @oString.Engine()
		pKey = StzEngineString(pcKey)
		pR = StzEngineStringXorCipher(pH, pKey)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pKey)
		return c

	def XORDecrypt(pcKey)
		return This.XOREncrypt(pcKey)

	  #===============================#
	 #     CHECKSUM                  #
	#===============================#

	def Checksum()
		cContent = @oString.Content()
		nLen = len(cContent)
		nSum = 0

		for i = 1 to nLen
			nSum += ascii(substr(cContent, i, 1))
		next

		return nSum

	def ChecksumHex()
		return hex(This.Checksum())

	  #===============================#
	 #     BASE64 (Engine-backed)    #
	#===============================#

	def Base64Encode()
		pH = @oString.Engine()
		pR = StzEngineStringToBase64(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

		def Base64Encoded()
			return This.Base64Encode()

	def Base64Decode()
		pH = @oString.Engine()
		pR = StzEngineStringBase64(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

		def Base64Decoded()
			return This.Base64Decode()

	  #===============================#
	 #     ROT13 CIPHER (Engine)     #
	#===============================#

	def ROT13()
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, 13)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def ROT13Q()
			This.ROT13()
			return This

	def ROT13ed()
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, 13)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     CAESAR CIPHER (Engine)    #
	#===============================#

	def CaesarEncrypt(nShift)
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, nShift)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

	def CaesarDecrypt(nShift)
		This.CaesarEncrypt(26 - (nShift % 26))

	def CaesarEncrypted(nShift)
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, nShift)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     VIGENERE CIPHER (Engine)  #
	#===============================#

	def VigenereEncrypt(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringVigenereEncrypt(pH, pcKey, len(pcKey))
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

	def VigenereEncrypted(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringVigenereEncrypt(pH, pcKey, len(pcKey))
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     ATBASH CIPHER (Engine)    #
	#===============================#

	def Atbash()
		pH = @oString.Engine()
		pR = StzEngineStringAtbash(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

	def Atbashed()
		pH = @oString.Engine()
		pR = StzEngineStringAtbash(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     ROT47 CIPHER (Engine)     #
	#===============================#

	def ROT47()
		pH = @oString.Engine()
		pR = StzEngineStringRot47(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

	def ROT47ed()
		pH = @oString.Engine()
		pR = StzEngineStringRot47(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	  #===============================#
	 #     ENCRYPTION DETECTION      #
	#===============================#

	def IsEncrypted()
		# High entropy suggests encrypted/random data
		nE = This.Entropy()
		return nE > 4

	  #===============================#
	 #     OBFUSCATION               #
	#===============================#

	def Obfuscate()
		cReversed = StzReverse(@oString.Content())
		# XOR with fixed key "ZiN"
		pRev = StzEngineString(cReversed)
		pKey = StzEngineString("ZiN")
		pR = StzEngineStringXorCipher(pRev, pKey)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pKey)
		StzEngineStringFree(pRev)
		@oString.Update(c)

		def ObfuscateQ()
			This.Obfuscate()
			return This

	def Obfuscated()
		cReversed = StzReverse(@oString.Content())
		pRev = StzEngineString(cReversed)
		pKey = StzEngineString("ZiN")
		pR = StzEngineStringXorCipher(pRev, pKey)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pKey)
		StzEngineStringFree(pRev)
		return c
