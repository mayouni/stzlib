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


# Hashes, signs and ciphers a text: SHA-256, MD5, BLAKE3, HMAC, base64, and the classic toy ciphers.
#
# It is the crypto helper of stzString. Build it with StzStringCryptoQ over a text, or with new
# stzStringCrypto, and keep the text and the key apart: the digests are engine-backed and match the
# published test vectors (abc gives ba7816bf... under SHA-256). The ciphers (ROT13, Caesar,
# Vigenere, Atbash, ROT47, XOR, Obfuscate) are toys that hide text from a glance and are not
# encryption: they only move the Latin letters or the ASCII range, so Hebrew, Arabic and emoji pass
# through unchanged, while the digests, base64 and XOR work on UTF-8 bytes. A verb without an ending
# (ROT13, Atbash) changes the held text and returns nothing, the form ending in -ed (ROT13ed,
# Atbashed, CaesarEncrypted) returns the new text and leaves the helper alone. Pass a plain text,
# not a stzString object: editing through the helper empties the stzString that was passed in.
# IsEncrypted answers TRUE for almost any text today.
#
#   receiver   o1 = StzStringCryptoQ("abc")
#   example    ? o1.Sha256()
#              #--> ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
#              ? o1.HmacSha256("key")
#              #--> 9c196e32dc0175f86f4b1cb89289d6619de6bee699e4c378e68309ed97a1a6ab
#              o2 = StzStringCryptoQ("שלום")
#              ? o2.Base64Encode()
#              #--> 16nXnNeV150=
#   see        stzString, stzSecretStore, stzRequestSigner
class stzStringCrypto from stzObject

	@oString

	# Builds a crypto helper over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to hash or encrypt, or a stzString to wrap
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; the helper is not made
	#                     by stzString itself, you build it over the same text
	#   warning           with a stzString argument, the first in-place edit (ROT13, CaesarEncrypt,
	#                     Atbash, Obfuscate...) leaves the stzString you passed reading as an empty
	#                     text, while the helper keeps the right one (ROT13 and Atbash on keep me,
	#                     both times)
	#   see               Content, Sha256
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCrypto! Parameter must be a string or stzString object.")
		ok

	# Returns the text as it stands now, after any in-place cipher applied through this helper.
	#
	#   returns    a text
	#   see        NumberOfChars, IsEmpty
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting an Arabic letter or an emoji as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     HASHING (Engine-backed)   #
	#===============================#

	# Returns the 64-bit FNV-1a hash of the text, a quick fingerprint that is not secure.
	#
	#   returns    a number
	#   note       not for passwords or integrity checks; use Sha256 or Blake3
	#   warning    the value is held as a number, so the low digits above 2^53 are rounded: abc
	#              gives 16654208175385434112 where the exact hash is 16654208175385433931
	#   see        Sha256, Checksum
	def Hash()
		_pH_ = @oString.Engine()
		return StzEngineStringHash(_pH_)

	# Returns the Shannon entropy of the characters, in hundredths of a bit per character.
	#
	#   returns    a number; 0 for a text of one repeated character, 158 for abc
	#   note       the figure is already scaled by 100, so 158 means 1.58 bits
	#   see        IsEncrypted, Hash
	def Entropy()
		_pH_ = @oString.Engine()
		return StzEngineStringEntropy(_pH_)

	  #===============================#
	 #     SHA-256 (Engine-backed)   #
	#===============================#

	# Returns the SHA-256 digest of the text as 64 lower-case hex characters.
	#
	#   returns    a text of 64 hex characters
	#   note       the text is hashed as UTF-8 bytes; the digest of abc is
	#              ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad, the published
	#              test vector
	#   see        Md5, Blake3, HmacSha256
	def Sha256()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSha256(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     MD5 (Engine-backed)       #
	#===============================#

	# Returns the MD5 digest of the text as 32 lower-case hex characters.
	#
	#   returns    a text of 32 hex characters
	#   note       MD5 is broken as a security hash; use it only for legacy checksums. The digest of
	#              abc is 900150983cd24fb0d6963f7d28e17f72, the published test vector
	#   see        Sha256, Blake3
	def Md5()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringMd5(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     BLAKE3 (Engine-backed)    #
	#===============================#

	# Returns the BLAKE3 digest of the text as 64 lower-case hex characters.
	#
	#   returns    a text of 64 hex characters
	#   note       the digest of abc is
	#              6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85, the published
	#              test vector
	#   see        Sha256, Md5
	def Blake3()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringBlake3(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #=================================#
	 #     HMAC-SHA256 (Engine-backed) #
	#=================================#

	# Returns the keyed HMAC-SHA256 of the text as 64 hex characters, so only the key holder can reproduce it.
	#
	#   pcKey      the secret key, as text
	#   returns    a text of 64 hex characters; an empty text for an empty key
	#   note       HMAC of abc under the key key is
	#              9c196e32dc0175f86f4b1cb89289d6619de6bee699e4c378e68309ed97a1a6ab, equal to Python
	#              hmac.new
	#   warning    an empty key returns an empty text instead of the HMAC under the empty key
	#   see        Sha256, XorEncrypt
	def HmacSha256(pcKey)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringHmacSha256(_pH_, pcKey)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     XOR CIPHER (Engine)       #
	#===============================#

	# Returns the text XORed byte by byte with a repeating key, encoded as base64 so it stays text.
	#
	#   pcKey      the passphrase that repeats along the text, as text
	#   returns    a text in base64; an empty text for an empty key
	#   note       the result is base64 because raw cipher bytes are not valid UTF-8 text and the
	#              engine would drop them; the helper keeps its own text, and to undo you give the
	#              base64 result to XorDecrypt with the same key
	#   warning    an empty key returns an empty text; a toy cipher, not secure
	#   see        XorDecrypt, VigenereEncrypted
	#@ aka  XOR with a repeating passphrase, returned as BASE64.
	def XorEncrypt(pcKey)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringXorEncryptB64(_pH_, pcKey)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Returns the plain text recovered from a base64 XOR result and the same key.
	#
	#   pcKey      the same passphrase that was used to encrypt
	#   returns    a text; an empty text for an empty key
	#   note       the helper must hold the base64 text that XorEncrypt returned; Hebrew, Arabic and
	#              emoji text round trips
	#   see        XorEncrypt
	def XorDecrypt(pcKey)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringXorDecryptB64(_pH_, pcKey)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     CHECKSUM                  #
	#===============================#

	# Returns the sum of the code points of every character, a very weak fingerprint.
	#
	#   returns    a number
	#   note       abc gives 294, and an emoji counts as its one code point
	#   see        ChecksumHex, Hash
	def Checksum()
		_pH_ = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_nSum_ = 0

		for i = 1 to _nLen_
			_nSum_ += StzEngineStringCharAt(_pH_, i)
		next

		return _nSum_

	# Returns the checksum written in hexadecimal.
	#
	#   returns    a text, such as 126 for abc
	#   note       the text has no 0x prefix
	#   see        Checksum
	def ChecksumHex()
		return hex(This.Checksum())

	  #===============================#
	 #     BASE64 (Engine-backed)    #
	#===============================#

	# Returns the text encoded in base64 from its UTF-8 bytes.
	#
	#   returns    a text; Base64Encoded is the same call
	#   note       abc gives YWJj
	#   see        Base64Decode, XorEncrypt
	def Base64Encode()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringToBase64(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

		def Base64Encoded()
			return This.Base64Encode()

	# Returns the text that a base64 text stands for.
	#
	#   returns    a text; Base64Decoded is the same call
	#   note       the helper must hold base64; YWJj gives abc
	#   see        Base64Encode
	def Base64Decode()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringBase64(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

		def Base64Decoded()
			return This.Base64Decode()

	  #===============================#
	 #     ROT13 CIPHER (Engine)     #
	#===============================#

	# Replaces the held text by its ROT13 form, in place, rotating each Latin letter by 13.
	#
	#   returns    nothing; the text changes. ROT13Q returns the helper for chaining
	#   note       only A-Z and a-z move; Hebrew, Arabic and emoji pass through unchanged; applying
	#              it twice restores the text
	#   see        ROT13ed, CaesarEncrypt
	def ROT13()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCaesar(_pH_, 13)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def ROT13Q()
			This.ROT13()
			return This

	# Returns the ROT13 form of the text, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       Hello gives Uryyb
	#   see        ROT13
	def ROT13ed()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCaesar(_pH_, 13)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     CAESAR CIPHER (Engine)    #
	#===============================#

	# Replaces the held text by its Caesar shift of the Latin letters, in place.
	#
	#   nShift     how many places each letter moves forward in the alphabet, 3 for Hello giving
	#              Khoor
	#   returns    nothing; the text changes
	#   note       only A-Z and a-z move; any other script and emoji pass through unchanged; a shift
	#              of 26 changes nothing
	#   see        CaesarEncrypted, CaesarDecrypt
	def CaesarEncrypt(nShift)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCaesar(_pH_, nShift)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

	# Replaces the held text by the Caesar shift of the same size taken backwards, in place.
	#
	#   nShift     the shift that was used to encrypt
	#   returns    nothing; the text changes
	#   note       Khoor with 3 gives Hello; a shift of 29 is read as 3
	#   see        CaesarEncrypt
	def CaesarDecrypt(nShift)
		This.CaesarEncrypt(26 - (nShift % 26))

	# Returns the text with each Latin letter moved forward by a shift, leaving the helper unchanged.
	#
	#   nShift     how many places each letter moves forward
	#   returns    a text
	#   note       Hello with 3 gives Khoor and with -3 gives Ebiil
	#   see        CaesarEncrypt
	def CaesarEncrypted(nShift)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCaesar(_pH_, nShift)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     VIGENERE CIPHER (Engine)  #
	#===============================#

	# Replaces the held text by its Vigenere encryption under a key word, in place.
	#
	#   pcKey      the key word whose letters give the successive shifts
	#   returns    nothing; the text changes
	#   note       the classic ATTACKATDAWN under LEMON gives LXFOPVEFRNHR; Hebrew, Arabic and emoji
	#              pass through unchanged
	#   warning    an empty key leaves an empty text
	#   see        VigenereEncrypted
	def VigenereEncrypt(pcKey)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringVigenereEncrypt(_pH_, pcKey, len(pcKey))
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

	# Returns the Vigenere encryption of the text under a key word, leaving the helper unchanged.
	#
	#   pcKey      the key word whose letters give the successive shifts
	#   returns    a text
	#   note       ATTACKATDAWN under LEMON gives LXFOPVEFRNHR; Hello World under key gives Rijvs
	#              Uyvjn
	#   warning    an empty key returns an empty text
	#   see        VigenereEncrypt
	def VigenereEncrypted(pcKey)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringVigenereEncrypt(_pH_, pcKey, len(pcKey))
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     ATBASH CIPHER (Engine)    #
	#===============================#

	# Replaces the held text by its Atbash form, in place, mirroring each Latin letter in the alphabet.
	#
	#   returns    nothing; the text changes
	#   note       a becomes z and Hello becomes Svool; other scripts pass through unchanged;
	#              applying it twice restores the text
	#   see        Atbashed, ROT13
	def Atbash()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringAtbash(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

	# Returns the Atbash form of the text, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       Hello gives Svool
	#   see        Atbash
	def Atbashed()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringAtbash(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     ROT47 CIPHER (Engine)     #
	#===============================#

	# Replaces the held text by its ROT47 form, in place, rotating the printable ASCII characters by 47.
	#
	#   returns    nothing; the text changes
	#   note       Hello gives w6==@; digits and punctuation move too; characters outside printable
	#              ASCII pass through unchanged; applying it twice restores the text
	#   see        ROT47ed, ROT13
	def ROT47()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRot47(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

	# Returns the ROT47 form of the text, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       Hello gives w6==@
	#   see        ROT47
	def ROT47ed()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRot47(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     ENCRYPTION DETECTION      #
	#===============================#

	# TRUE if the entropy figure of the text is above 4, which almost any text with two different characters passes.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       do not use it to detect encryption
	#   warning    answers TRUE for ab, abab and a plain English sentence, and FALSE only for a text
	#              of one repeated character or an empty one: Entropy is scaled by 100 (hundredths
	#              of a bit) and is compared with 4 as if it were in bits, so the answer cannot tell
	#              cipher text from plain text today
	#   see        Entropy
	def IsEncrypted()
		# High entropy suggests encrypted/random data
		_nE_ = This.Entropy()
		return _nE_ > 4

	  #===============================#
	 #     OBFUSCATION               #
	#===============================#

	# Replaces the held text by its reversal XORed with the fixed key ZiN and written in base64, in place.
	#
	#   returns    nothing; the text changes. ObfuscateQ returns the helper for chaining
	#   note       a fixed key, so it hides text from a glance and is not encryption
	#   see        Obfuscated, Deobfuscate
	def Obfuscate()
		_cReversed_ = StzReverse(@oString.Content())
		# XOR with fixed key "ZiN"
		pRev = StzEngineString(_cReversed_)
		_pR_ = StzEngineStringXorEncryptB64(pRev, "ZiN")
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pRev)
		@oString.Update(_c_)

		def ObfuscateQ()
			This.Obfuscate()
			return This

	# Returns the obfuscated form of the text, leaving the helper unchanged.
	#
	#   returns    a text in base64
	#   note       Hello gives NQUiPyE=
	#   see        Obfuscate, Deobfuscated
	def Obfuscated()
		_cReversed_ = StzReverse(@oString.Content())
		pRev = StzEngineString(_cReversed_)
		_pR_ = StzEngineStringXorEncryptB64(pRev, "ZiN")
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		StzEngineStringFree(pRev)
		return _c_

	# Returns the plain text hidden by an obfuscation, leaving the helper unchanged.
	#
	#   returns    a text
	#   note       the helper must hold the base64 text that Obfuscated returned
	#   see        Obfuscated, Deobfuscate
	#@ aka  The inverse, which did not exist. Obfuscate() could be applied and never undone -- reversing then XORing again is NOT the inverse of XORing then reversing, so callers had no way back.
	def Deobfuscated()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringXorDecryptB64(_pH_, "ZiN")
		_cX_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return StzReverse(_cX_)

	# Replaces the held base64 text by the plain text it hides, in place.
	#
	#   returns    nothing; the text changes. DeobfuscateQ returns the helper for chaining
	#   note       undoes Obfuscate
	#   see        Obfuscate, Deobfuscated
	def Deobfuscate()
		@oString.Update(This.Deobfuscated())

		def DeobfuscateQ()
			This.Deobfuscate()
			return This
