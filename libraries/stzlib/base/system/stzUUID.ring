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

class stzUUID from stzObject

	# Private attributes
	@cUuid = ""
	@nVersion = 4

	def init()
		@cUuid = StzUpper(StzEngineUUIDV4())
		@nVersion = This.Version()

	# Public methods

	def Content()
		return @cUuid

	def Copy()
		_oC_ = new stzUUID()
		_oC_.@cUuid = @cUuid
		_oC_.@nVersion = @nVersion
		return _oC_

	def WithoutHyphens()
		return StzReplace(@cUuid, "-", "")

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

	def IsNull()
		return StzEngineUUIDCompare(@cUuid, StzEngineUUIDNil()) = 0

	def IsValid()
		return StzEngineUUIDIsValid(@cUuid) = 1

	def Version()
		_n_ = StzEngineUUIDVersion(@cUuid)
		if _n_ < 0 return 0 ok
		return _n_

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

	# ToBytes: hex-decode the 32 hex chars (sans hyphens) into a
	# list of 16 byte values. Pure Ring -- no engine call needed.
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
