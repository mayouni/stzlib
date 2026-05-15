#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCRYPTO             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String crypto subclass -- hashing,           #
#                  basic encryption/decryption, checksum         #
#                  operations.                                   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCrypto from stzString

	  #===============================#
	 #     HASHING                   #
	#===============================#

	def Hash(pcAlgorithm)
		return sha256(This.Content())

		def HashQ(pcAlgorithm)
			return new stzStringCrypto(This.Hash(pcAlgorithm))

	def SHA256()
		return sha256(This.Content())

	def MD5()
		return md5(This.Content())

	  #===============================#
	 #     SIMPLE XOR CIPHER         #
	#===============================#

	def XOREncrypt(pcKey)
		cContent = This.Content()
		cKey = pcKey
		nLen = len(cContent)
		nKeyLen = len(cKey)
		cResult = ""

		for i = 1 to nLen
			nKeyIdx = ((i - 1) % nKeyLen) + 1
			nXOR = ascii(substr(cContent, i, 1)) ^ ascii(substr(cKey, nKeyIdx, 1))
			cResult += char(nXOR)
		next

		return cResult

	def XORDecrypt(pcKey)
		return This.XOREncrypt(pcKey)

	  #===============================#
	 #     CHECKSUM                  #
	#===============================#

	def Checksum()
		cContent = This.Content()
		nLen = len(cContent)
		nSum = 0

		for i = 1 to nLen
			nSum += ascii(substr(cContent, i, 1))
		next

		return nSum

	def ChecksumHex()
		return hex(This.Checksum())

	  #===============================#
	 #     BASE64                    #
	#===============================#

	def Base64Encode()
		cContent = This.Content()
		cTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		cResult = ""
		nLen = len(cContent)
		i = 1

		while i <= nLen
			nB1 = ascii(substr(cContent, i, 1))
			if i + 1 <= nLen
				nB2 = ascii(substr(cContent, i + 1, 1))
			else
				nB2 = 0
			ok
			if i + 2 <= nLen
				nB3 = ascii(substr(cContent, i + 2, 1))
			else
				nB3 = 0
			ok

			nIdx1 = (nB1 >> 2) + 1
			nIdx2 = (((nB1 & 3) << 4) | (nB2 >> 4)) + 1
			nIdx3 = (((nB2 & 15) << 2) | (nB3 >> 6)) + 1
			nIdx4 = (nB3 & 63) + 1

			cResult += substr(cTable, nIdx1, 1)
			cResult += substr(cTable, nIdx2, 1)

			if i + 1 <= nLen
				cResult += substr(cTable, nIdx3, 1)
			else
				cResult += "="
			ok

			if i + 2 <= nLen
				cResult += substr(cTable, nIdx4, 1)
			else
				cResult += "="
			ok

			i += 3
		end

		return cResult

	def Base64Decode()
		cContent = This.Content()
		cTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		cResult = ""
		nLen = len(cContent)
		i = 1

		while i <= nLen
			nV1 = substr(cTable, substr(cContent, i, 1)) - 1
			nV2 = substr(cTable, substr(cContent, i + 1, 1)) - 1

			c3 = substr(cContent, i + 2, 1)
			c4 = substr(cContent, i + 3, 1)

			if c3 != "="
				nV3 = substr(cTable, c3) - 1
			else
				nV3 = 0
			ok

			if c4 != "="
				nV4 = substr(cTable, c4) - 1
			else
				nV4 = 0
			ok

			cResult += char((nV1 << 2) | (nV2 >> 4))

			if c3 != "="
				cResult += char(((nV2 & 15) << 4) | (nV3 >> 2))
			ok

			if c4 != "="
				cResult += char(((nV3 & 3) << 6) | nV4)
			ok

			i += 4
		end

		return cResult

	  #===============================#
	 #     ROT13 CIPHER              #
	#===============================#

	def ROT13()
		This.CaesarEncrypt(13)

		def ROT13Q()
			This.ROT13()
			return This

	def ROT13ed()
		cSaved = This.Content()
		This.ROT13()
		cResult = This.Content()
		This.Update(cSaved)
		return cResult

	  #===============================#
	 #     CAESAR CIPHER             #
	#===============================#

	def CaesarEncrypt(nShift)
		cContent = This.Content()
		nLen = len(cContent)
		cResult = ""

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			nCode = ascii(c)

			if nCode >= 65 and nCode <= 90
				# Uppercase A-Z
				nCode = ((nCode - 65 + nShift) % 26) + 65
				cResult += char(nCode)

			but nCode >= 97 and nCode <= 122
				# Lowercase a-z
				nCode = ((nCode - 97 + nShift) % 26) + 97
				cResult += char(nCode)

			else
				cResult += c
			ok
		next

		This.Update(cResult)

	def CaesarDecrypt(nShift)
		This.CaesarEncrypt(26 - (nShift % 26))

	  #===============================#
	 #     ENCRYPTION DETECTION      #
	#===============================#

	def IsEncrypted()
		cContent = This.Content()
		nLen = len(cContent)
		if nLen < 4
			return 0
		ok

		# Heuristic: count unique chars relative to length
		acSeen = []
		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if ring_find(acSeen, c) = 0
				acSeen + c
			ok
		next

		nUnique = len(acSeen)
		# High ratio of unique chars suggests encrypted/random data
		nRatio = nUnique * 100 / nLen
		return nRatio > 70

	  #===============================#
	 #     OBFUSCATION               #
	#===============================#

	def Obfuscate()
		# Reverse the string then XOR with a fixed key
		cContent = This.Content()
		nLen = len(cContent)

		# Reverse
		cReversed = ""
		for i = nLen to 1 step -1
			cReversed += substr(cContent, i, 1)
		next

		# XOR with fixed key "ZiN"
		cKey = "ZiN"
		nKeyLen = len(cKey)
		cResult = ""

		for i = 1 to nLen
			nKeyIdx = ((i - 1) % nKeyLen) + 1
			nXOR = ascii(substr(cReversed, i, 1)) ^ ascii(substr(cKey, nKeyIdx, 1))
			cResult += char(nXOR)
		next

		This.Update(cResult)

		def ObfuscateQ()
			This.Obfuscate()
			return This

	def Obfuscated()
		cSaved = This.Content()
		This.Obfuscate()
		cResult = This.Content()
		This.Update(cSaved)
		return cResult
