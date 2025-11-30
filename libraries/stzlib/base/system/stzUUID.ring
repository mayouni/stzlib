/*
stzUUID - Multiplatform UUID Generation Class for Softanza Library
Provides robust UUID generation using the C++ Uiid extension by Youssef Saeed
*/

load "uuid.ring"

#TODO Study the additon of ULID, KSUID, and SnowFlakeID

func UUID()
	return upper(uuid_generate())

	func @Uuid()
		return UUID()

func NullUUID()
	return upper( uuid_nil() )

	func @NullUuid()
		return NullUuid()

func IsValidUuid(cUuidStr)
	return uuid_isvalid(cUuidStr)

func StzUUIDQ()
	return new stzUUID()

class stzUUID

	# Private attributes
	@cUuid = ""
	@nVersion = 4

	def init()
		@cUuid = upper(uuid_generate())
		@nVersion = This.Version()

	# Public methods

	def Content()
		return @cUuid

	def Copy()
		return new stzUUID(@cUuid)

	def WithoutHyphens()
		return substr(@cUuid, "-", "")

	def WithHyphens()
		if substr(@cUuid, "-") = 0
			# Add hyphens in standard UUID format: 8-4-4-4-12
			cResult = @substr(@cUuid, 1, 8) + "-" +
			          @substr(@cUuid, 9, 4) + "-" +
			          @substr(@cUuid, 13, 4) + "-" +
			          @substr(@cUuid, 17, 4) + "-" +
			          @substr(@cUuid, 21, 12)
			return cResult
		ok
		return @cUuid

	def IsNull()
		return @cUuid = @NullUuid()

	def IsValid()
		return uuid_isvalid(@cUuid)

	def Version()
		if len(@cUuid) >= 14
			return number("0x" + @cUuid[15])
		ok
		return 0

	def Variant()
		if len(@cUuid) >= 19
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
		# Simple hash function for UUID
		nHash = 0
		cClean = WithoutHyphens()
		nLen = len(cClean)
		for i = 1 to nLen
			nHash = (nHash * 31 + ascii(cClean[i])) % 2147483647
		next
		return nHash

		def Hash()
			return This.Hashed()

		def ToHash()
			return This.Hashed()

	def ToBytes()
		return uuid_tobytes(@cUuid)
