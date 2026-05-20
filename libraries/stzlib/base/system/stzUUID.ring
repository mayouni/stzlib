/*
stzUUID - Multiplatform UUID Generation Class for Softanza Library
Provides robust UUID generation using the C++ Uiid extension by Youssef Saeed
*/

load "uuid.ring" # The C++ uuid extension should be isntalled
# Link: https://github.com/ysdragon/uuid


#TODO Study the additon of ULID, KSUID, and SnowFlakeID

func StzUUID()
	return StzUpper(uuid_generate())

	func UUID()
		return StzUUID()

	func @Uuid()
		return StzUUID()

func StzNullUUID()
	return StzUpper( uuid_nil() )

	func NullUUID()
		return StzNullUUID()

	func @NullUuid()
		return StzNullUUID()

func StzIsValidUuid(cUuidStr)
	return uuid_isvalid(cUuidStr)

	func IsValidUuid(cUuidStr)
		return StzIsValidUuid(cUuidStr)

func StzUUIDQ()
	return new stzUUID()

class stzUUID

	# Private attributes
	@cUuid = ""
	@nVersion = 4

	def init()
		@cUuid = StzUpper(uuid_generate())
		@nVersion = This.Version()

	# Public methods

	def Content()
		return @cUuid

	def Copy()
		return new stzUUID(@cUuid)

	def WithoutHyphens()
		return StzReplace(@cUuid, "-", "")

	def WithHyphens()
		if StzFind(@cUuid, "-") = 0
			# Add hyphens in standard UUID format: 8-4-4-4-12
			cResult = StzMid(@cUuid, 1, 8) + "-" +
			          StzMid(@cUuid, 9, 4) + "-" +
			          StzMid(@cUuid, 13, 4) + "-" +
			          StzMid(@cUuid, 17, 4) + "-" +
			          StzMid(@cUuid, 21, 12)
			return cResult
		ok
		return @cUuid

	def IsNull()
		return @cUuid = @NullUuid()

	def IsValid()
		return uuid_isvalid(@cUuid)

	def Version()
		if StzLen(@cUuid) >= 14
			return number("0x" + @cUuid[15])
		ok
		return 0

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
		# Simple hash function for UUID
		nHash = 0
		cClean = WithoutHyphens()
		nLen = StzLen(cClean)
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
