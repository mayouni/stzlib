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

class stzUUID

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
		oC = new stzUUID()
		oC.@cUuid = @cUuid
		oC.@nVersion = @nVersion
		return oC

	def WithoutHyphens()
		return StzReplace(@cUuid, "-", "")

	def WithHyphens()
		if StzFindFirst(@cUuid, "-") = 0
			# Standard 8-4-4-4-12 hyphenation.
			cResult = StzMid(@cUuid, 1, 8)  + "-" +
			          StzMid(@cUuid, 9, 4)  + "-" +
			          StzMid(@cUuid, 13, 4) + "-" +
			          StzMid(@cUuid, 17, 4) + "-" +
			          StzMid(@cUuid, 21, 12)
			return cResult
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
			nVariantBits = number("0x" + @cUuid[20])
			if (nVariantBits & 8) = 0
				return "Reserved (NCS)"
			but (nVariantBits & 12) = 8
				return "RFC 4122"
			but (nVariantBits & 14) = 12
				return "Microsoft"
			else
				return "Future"
			ok
		ok
		return "Unknown"

	def Hashed()
		# Simple per-codepoint hash on the un-hyphenated form.
		nHash = 0
		cClean = This.WithoutHyphens()
		nLen = StzLen(cClean)
		for i = 1 to nLen
			nHash = (nHash * 31 + ascii(cClean[i])) % 2147483647
		next
		return nHash

		def Hash()
			return This.Hashed()

		def ToHash()
			return This.Hashed()

	# ToBytes: hex-decode the 32 hex chars (sans hyphens) into a
	# list of 16 byte values. Pure Ring -- no engine call needed.
	def ToBytes()
		cClean = This.WithoutHyphens()
		aBytes = []
		nLen = len(cClean)
		i = 1
		while i + 1 <= nLen
			cPair = StzMid(cClean, i, 2)
			aBytes + number("0x" + cPair)
			i += 2
		end
		return aBytes
