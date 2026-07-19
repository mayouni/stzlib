#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCRYPTO             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String crypto -- Wraps stzString via        #
#                  composition. Hashing, basic encryption/     #
#                  decryption, checksum operations.            #
#                  All ops are engine-backed (Zig DLL).        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringCrypto from stzObject

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
	 #     SHA-256 (Engine-backed)   #
	#===============================#

	def Sha256()
		pH = @oString.Engine()
		pR = StzEngineStringSha256(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     MD5 (Engine-backed)       #
	#===============================#

	def Md5()
		pH = @oString.Engine()
		pR = StzEngineStringMd5(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     BLAKE3 (Engine-backed)    #
	#===============================#

	def Blake3()
		pH = @oString.Engine()
		pR = StzEngineStringBlake3(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #=================================#
	 #     HMAC-SHA256 (Engine-backed) #
	#=================================#

	def HmacSha256(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringHmacSha256(pH, pcKey)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     XOR CIPHER (Engine)       #
	#===============================#

	# XOR with a repeating passphrase, returned as BASE64.
	#
	# Two bugs lived here. The key was passed as a string HANDLE to an engine
	# function whose key parameter is a single BYTE, so the bridge coerced the
	# pointer to a number and every call XORed with a different arbitrary
	# byte -- "Secret" encrypted and decrypted with "key" came back "Pf`qfw",
	# every byte off by a constant 0x03, the gap between the two accidental
	# keys.
	#
	# And the result is BINARY. Every other cipher here permutes letters and
	# stays in the text domain; XOR does not. The engine's string type
	# validates UTF-8 (rightly), so feeding raw cipher bytes back in for
	# decryption dropped them: "Secret"/"key" happens to produce only
	# ASCII-range bytes and survived, but two Arabic letters produce
	# B5 D0 A1 E0, which is not valid UTF-8, and came back empty.
	#
	# So the cipher now stays inside the engine and what crosses the bridge is
	# always base64. XorDecrypt is a real method rather than an alias for
	# XorEncrypt: the pair is still an involution over the BYTES, but the
	# encoding step has a direction.
	def XorEncrypt(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringXorEncryptB64(pH, pcKey)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def XorDecrypt(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringXorDecryptB64(pH, pcKey)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     CHECKSUM                  #
	#===============================#

	def Checksum()
		pH = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_nSum_ = 0

		for i = 1 to _nLen_
			_nSum_ += StzEngineStringCharAt(pH, i)
		next

		return _nSum_

	def ChecksumHex()
		return hex(This.Checksum())

	  #===============================#
	 #     BASE64 (Engine-backed)    #
	#===============================#

	def Base64Encode()
		pH = @oString.Engine()
		pR = StzEngineStringToBase64(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

		def Base64Encoded()
			return This.Base64Encode()

	def Base64Decode()
		pH = @oString.Engine()
		pR = StzEngineStringBase64(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

		def Base64Decoded()
			return This.Base64Decode()

	  #===============================#
	 #     ROT13 CIPHER (Engine)     #
	#===============================#

	def ROT13()
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, 13)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def ROT13Q()
			This.ROT13()
			return This

	def ROT13ed()
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, 13)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     CAESAR CIPHER (Engine)    #
	#===============================#

	def CaesarEncrypt(nShift)
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, nShift)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

	def CaesarDecrypt(nShift)
		This.CaesarEncrypt(26 - (nShift % 26))

	def CaesarEncrypted(nShift)
		pH = @oString.Engine()
		pR = StzEngineStringCaesar(pH, nShift)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     VIGENERE CIPHER (Engine)  #
	#===============================#

	def VigenereEncrypt(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringVigenereEncrypt(pH, pcKey, len(pcKey))
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

	def VigenereEncrypted(pcKey)
		pH = @oString.Engine()
		pR = StzEngineStringVigenereEncrypt(pH, pcKey, len(pcKey))
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     ATBASH CIPHER (Engine)    #
	#===============================#

	def Atbash()
		pH = @oString.Engine()
		pR = StzEngineStringAtbash(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

	def Atbashed()
		pH = @oString.Engine()
		pR = StzEngineStringAtbash(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     ROT47 CIPHER (Engine)     #
	#===============================#

	def ROT47()
		pH = @oString.Engine()
		pR = StzEngineStringRot47(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

	def ROT47ed()
		pH = @oString.Engine()
		pR = StzEngineStringRot47(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #===============================#
	 #     ENCRYPTION DETECTION      #
	#===============================#

	def IsEncrypted()
		# High entropy suggests encrypted/random data
		_nE_ = This.Entropy()
		return _nE_ > 4

	  #===============================#
	 #     OBFUSCATION               #
	#===============================#

	def Obfuscate()
		_cReversed_ = StzReverse(@oString.Content())
		# XOR with fixed key "ZiN"
		pRev = StzEngineString(_cReversed_)
		pR = StzEngineStringXorEncryptB64(pRev, "ZiN")
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pRev)
		@oString.Update(_c_)

		def ObfuscateQ()
			This.Obfuscate()
			return This

	def Obfuscated()
		_cReversed_ = StzReverse(@oString.Content())
		pRev = StzEngineString(_cReversed_)
		pR = StzEngineStringXorEncryptB64(pRev, "ZiN")
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pRev)
		return _c_

	# The inverse, which did not exist. Obfuscate() could be applied and
	# never undone -- reversing then XORing again is NOT the inverse of
	# XORing then reversing, so callers had no way back.
	def Deobfuscated()
		pH = @oString.Engine()
		pR = StzEngineStringXorDecryptB64(pH, "ZiN")
		_cX_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return StzReverse(_cX_)

	def Deobfuscate()
		@oString.Update(This.Deobfuscated())

		def DeobfuscateQ()
			This.Deobfuscate()
			return This
