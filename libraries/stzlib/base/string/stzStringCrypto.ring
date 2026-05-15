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

