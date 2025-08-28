/*
	stzUUID - Multiplatform UUID Generation Class for Softanza Library
	Provides robust UUID generation using system calls across platforms
*/

func UUID()
	return StzUUIDQ().Content()

func NullUUID()
	return "00000000-0000-0000-0000-000000000000"

func StzUUIDQ()
	return new stzUUID()

class stzUUID

	# Private attributes
	@cUuid = ""
	@nVersion = 4

	def init()
		GenerateUUID()

	# Public methods

	def Generate()
		GenerateUUID()


	def Content()
		return @cUuid

	def Copy()
		return new stzUUID(This.UUID())

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
		return @cUuid = "00000000-0000-0000-0000-000000000000"

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

		# Convert UUID to byte array (32 hex chars = 16 bytes)

		cHex = WithoutHyphens()
		nLen = len(cHex)
		aBytes = []
		for i = 1 to nLen step 2
			cByte = @substr(cHex, i, 2)
			add(aBytes, number("0x" + cByte))
		next
		return aBytes

	# Private methods

	private

	def GenerateUUID()
		if isWindows()
			GenerateWindowsUUID()
		but isLinux()
			GenerateLinuxUUID()
		but isMacosx()
			GenerateMacOSUUID()
		other
			GenerateFallbackUUID()
		ok

	def GenerateWindowsUUID()
	    # Use temp file to capture PowerShell output
	    cTempFile = "uuid_temp.txt"
	    cCommand = 'powershell -c "[guid]::NewGuid().ToString()" > ' + cTempFile
	    system(cCommand)
    
	    try
	        cResult = read(cTempFile)
	        remove(cTempFile)
	        
	        if len(cResult) >= 36
	            @cUuid = upper(trim(cResult))
	        else
	            GenerateFallbackUUID()
	        ok
	    catch
	        GenerateFallbackUUID()
	    done

	def GenerateLinuxUUID()
	    # Try uuidgen with clean output
	    cTempFile = "uuid_temp.txt"
	    cCommand = "uuidgen > " + cTempFile
	    system(cCommand)
	    
	    try
	        cResult = read(cTempFile)
	        remove(cTempFile)
	        if len(trim(cResult)) >= 36
	            @cUuid = upper(trim(cResult))
	            return
	        ok
	    catch
	    done
	    
	    # Fallback to /proc/sys/kernel/random/uuid
	    cCommand = "cat /proc/sys/kernel/random/uuid > " + cTempFile
	    system(cCommand)
	    
	    try
	        cResult = read(cTempFile)
	        remove(cTempFile)
	        if len(trim(cResult)) >= 36
	            @cUuid = upper(trim(cResult))
	        else
	            GenerateFallbackUUID()
	        ok
	    catch
	        GenerateFallbackUUID()
	    done

	def GenerateMacOSUUID()
	    # Use macOS uuidgen with temp file
	    cTempFile = "uuid_temp.txt"
	    cCommand = "uuidgen > " + cTempFile
	    system(cCommand)
	    
	    try
	        cResult = read(cTempFile)
	        remove(cTempFile)
	        if len(trim(cResult)) >= 36
	            @cUuid = upper(trim(cResult))
	        else
	            GenerateFallbackUUID()
	        ok
	    catch
	        GenerateFallbackUUID()
	    done

	def GenerateFallbackUUID()
		# Generate UUID v4 using Ring's random functions
		srandom(clockspersecond())
		
		# Generate 16 random bytes (32 hex chars)
		cHex = ""
		for i = 1 to 16
			nByte = random(255)
			cByteHex = hex(nByte)
			if len(cByteHex) = 1
				cByteHex = "0" + cByteHex
			ok
			cHex += upper(cByteHex)
		next
		
		# Ensure exactly 32 characters
		cHex = left(cHex, 32)
		
		# Set version (4) and variant bits for UUID v4
		# Position 13: version 4 (bits 12-15 = 0100)
		cHex = @substr(cHex, 1, 12) + "4" + @substr(cHex, 14, len(cHex)-13)

		# Position 17: variant bits (10xx)
		nVariantByte = (ascii(cHex[17]) & 15) | 128  # Set bit 7, clear bit 6
		cHex = @substr(cHex, 1, 16) + upper(hex(nVariantByte % 16)) + @substr(cHex, 18, len(cHex)-17)
		
		# Format with hyphens: 8-4-4-4-12
		@cUuid = @substr(cHex, 1, 8) + "-" +
		         @substr(cHex, 9, 4) + "-" +
		         @substr(cHex, 13, 4) + "-" +
		         @substr(cHex, 17, 4) + "-" +
		         @substr(cHex, 21, 12)

	def SystemCommand(cCommand)
	    # Execute system command and return output
	    try
	        cResult = system(cCommand)
	        # Debug output
	        ? "Command: " + cCommand
	        ? "Raw result: [" + cResult + "]"
	        return cResult
	    catch cError
	        ? "System command error: " + cError
	        return ""
	    done

	def IsValidUUID(cUUID)
		# Validate UUID format
		if len(cUUID) != 36
			return False
		ok
		
		# Check pattern: 8-4-4-4-12
		if cUUID[9] != "-" or cUUID[14] != "-" or 
		   cUUID[19] != "-" or cUUID[24] != "-"
			return False
		ok
		
		# Check if remaining characters are hex
		cClean = substr(cUUID, "-", "")
		if len(cClean) != 32
			return False
		ok

		nLen = len(cClean)
		for i = 1 to nLen
			c = cClean[i]
			n = ascii(c)
			if not ( (n >= ascii("0") and n <= ascii("9")) or 
			       (n >= ascii("A") and n <= ascii("F")) or
			       (n >= ascii("a") and n <= ascii("f")))
				return False
			ok
		next
		
		return True

		def IsValid()
			return This.IsValidUUID()
