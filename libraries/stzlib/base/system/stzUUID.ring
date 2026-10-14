/*
stzUUID - Multiplatform UUID Generation for Softanza Library
Backed by the Softanza Zig engine (libraries/stzlib/engine/src/uuid.zig).
No external dependencies. Previously loaded the C++ uuid.ring extension;
swapped 2026-06-13 to the in-tree Zig implementation (StzEngineUUID*).
*/

#TODO Study the addition of ULID, KSUID, and SnowFlakeID

func StzUUID()
	return StzUpper(StzEngineUUIDV4())

	func UUID()
		return StzUUID()

	func @Uuid()
		return StzUUID()

func StzNullUUID()
	return StzUpper(StzEngineUUIDNil())

	func NullUUID()
		return StzNullUUID()

	func @NullUuid()
		return StzNullUUID()

func StzIsValidUuid(cUuidStr)
	return StzEngineUUIDIsValid(cUuidStr) = 1

	func IsValidUuid(cUuidStr)
		return StzIsValidUuid(cUuidStr)

func StzUUIDQ()
	return new stzUUID()

# Generates a random version-4 UUID and answers questions about it: its text forms, validity, version, variant and bytes.
#
# A new object is a fresh random UUID held in upper case with hyphens. The generation and the
# validity check are done by the engine; the rest is reading the text. Two objects built one after
# the other differ, and a copy made with Copy holds the same value as the original.
#
#   receiver   o1 = new stzUUID()
#   example    ? len(o1.Content())
#              #--> 36
#              ? len(o1.WithoutHyphens())
#              #--> 32
#              ? o1.Version()
#              #--> 4
#              ? o1.Variant()
#              #--> RFC 4122
#              ? o1.IsValid()
#              #--> 1
#   see        stzRandom, stzSystemActor
class stzUUID from stzObject

	# Private attributes
	@cUuid = ""
	@nVersion = 4

	# Generates a new random version-4 UUID, held in upper case with hyphens, such as 3F2504E0-4F89-41D3-9A0C-0305E82C3301.
	#
	#   returns    nothing; the object is built
	#   see        Content, IsValid
	def init()
		@cUuid = StzUpper(StzEngineUUIDV4())
		@nVersion = This.Version()

	# Returns the UUID as 36 upper-case characters with hyphens.
	#
	#   returns    a text
	#   see        WithHyphens, WithoutHyphens
	#@ aka  Public methods
	def Content()
		return @cUuid

	# Returns a new stzUUID that holds the same value, so the two are independent objects with one identity.
	#
	#   returns    a new stzUUID
	#   warning    the constructor generates a fresh UUID first, which the copy then overwrites
	#   see        Content
	def Copy()
		_oC_ = new stzUUID()
		_oC_.@cUuid = @cUuid
		_oC_.@nVersion = @nVersion
		return _oC_

	# Returns the UUID as 32 hexadecimal characters with the hyphens removed.
	#
	#   returns    a text
	#   see        WithHyphens, Content
	def WithoutHyphens()
		return StzReplace(@cUuid, "-", "")

	# Returns the UUID in the 8-4-4-4-12 form.
	#
	#   returns    a text
	#   warning    it returns the same text as Content for a UUID built by this class
	#   see        WithoutHyphens, Content
	def WithHyphens()
		if StzFindFirst("-", @cUuid) = 0
			# Standard 8-4-4-4-12 hyphenation.
			_cResult_ = StzMid(@cUuid, 1, 8)  + "-" +
			          StzMid(@cUuid, 9, 4)  + "-" +
			          StzMid(@cUuid, 13, 4) + "-" +
			          StzMid(@cUuid, 17, 4) + "-" +
			          StzMid(@cUuid, 21, 12)
			return _cResult_
		ok
		return @cUuid

	# TRUE if the UUID is the nil UUID, all zeros.
	#
	#   returns    TRUE or FALSE
	#   warning    a generated UUID is never nil
	#   see        IsValid
	def IsNull()
		return StzEngineUUIDCompare(@cUuid, StzEngineUUIDNil()) = 0

	# TRUE if the engine reads the value as a well-formed UUID.
	#
	#   returns    TRUE or FALSE
	#   see        IsNull, Version
	def IsValid()
		return StzEngineUUIDIsValid(@cUuid) = 1

	# Returns the UUID version number, 4 for a generated one; 0 when the engine cannot read it.
	#
	#   returns    a number
	#   see        Variant, IsValid
	def Version()
		_n_ = StzEngineUUIDVersion(@cUuid)
		if _n_ < 0 return 0 ok
		return _n_

	# Returns the name of the UUID variant read from its variant bits: RFC 4122, Microsoft, Reserved (NCS) or Future.
	#
	#   returns    a text
	#   see        Version
	def Variant()
		if StzLen(@cUuid) >= 19
			_nVariantBits_ = number("0x" + @cUuid[20])
			if (_nVariantBits_ & 8) = 0
				return "Reserved (NCS)"
			but (_nVariantBits_ & 12) = 8
				return "RFC 4122"
			but (_nVariantBits_ & 14) = 12
				return "Microsoft"
			else
				return "Future"
			ok
		ok
		return "Unknown"

	# Returns a small number derived from the 32 characters, for use as a hash key.
	#
	#   returns    a number below 2147483647
	#   warning    a polynomial hash of the hex text, not a cryptographic one; equal UUIDs give
	#              equal numbers
	#   see        Content
	def Hashed()
		# Simple per-codepoint hash on the un-hyphenated form.
		_nHash_ = 0
		_cClean_ = This.WithoutHyphens()
		_nLen_ = StzLen(_cClean_)
		for _i_ = 1 to _nLen_
			_nHash_ = (_nHash_ * 31 + ascii(_cClean_[_i_])) % 2147483647
		next
		return _nHash_

		def Hash()
			return This.Hashed()

		def ToHash()
			return This.Hashed()

	# Returns the 16 bytes of the UUID as numbers from 0 to 255.
	#
	#   returns    a list of 16 numbers
	#   see        WithoutHyphens, Hashed
	#@ aka  ToBytes: hex-decode the 32 hex chars (sans hyphens) into a list of 16 byte values. Pure Ring -- no engine call needed.
	def ToBytes()
		_cClean_ = This.WithoutHyphens()
		_aBytes_ = []
		_nLen_ = len(_cClean_)
		_i_ = 1
		while _i_ + 1 <= _nLen_
			_cPair_ = StzMid(_cClean_, _i_, 2)
			_aBytes_ + number("0x" + _cPair_)
			_i_ += 2
		end
		return _aBytes_
