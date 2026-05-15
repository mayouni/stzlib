#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCRYPTOXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String crypto extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCryptoXT from stzStringCrypto

	_bAliasesLoaded = FALSE

	def init(pcStr)
		super.init(pcStr)
		This._RegisterAliases()

	def _RegisterAliases()

		if _bAliasesLoaded
			return
		ok

		_bAliasesLoaded = TRUE

		_aAliases_ = [

			# --- Hash aliases ---

			[ "Hash",		"Hashed" ],
			[ "SHA256",		"Sha256Hash" ],
			[ "MD5",		"Md5Hash" ],

			# --- XOR aliases ---

			[ "XOREncrypt",		"XorEncrypt" ],
			[ "XORDecrypt",		"XorDecrypt" ],
			[ "XOREncrypt",		"XorCipher" ],

			# --- Checksum aliases ---

			[ "Checksum",		"CheckSum" ],
			[ "ChecksumHex",	"CheckSumHex" ],

			# --- Encoding aliases ---

			[ "Base64Encode",	"Encode64" ],
			[ "Base64Decode",	"Decode64" ],

			# --- ROT13 aliases ---

			[ "ROT13",		"Rot13Encrypt" ],
			[ "ROT13",		"Rot13" ],

			# --- Caesar aliases ---

			[ "CaesarEncrypt",	"CaesarCipher" ],

			# --- Obfuscation aliases ---

			[ "Obfuscate",		"Obscure" ],
			[ "ObfuscateQ",		"ObscureQ" ],
			[ "Obfuscated",		"Obscured" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
