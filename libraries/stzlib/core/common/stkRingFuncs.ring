
# Wrappers to ring functions, that we use inside a softanza class
# where the same name is needed (example: insert() inside stzString)
#--> This will allow us to avoid conflicts!
#--> For you as a Ring programmer, this won't alter you Ring experience
#     when you want to use native Ring form. But if you are inside a
#     softanza object, then the softanza version will apply, unless you
#     you opt for the Ring's version using ring_...()

#TODO // Add the ring_...() form of all Ring functions

func SoftanzaLogo()
	return $SOFTANZALOGO

	func Softanza()
		return $SOFTANZALOGO

func StzVersion()
	return "0.9"

	func stz_version()
		return StzVersion()

func ring_version()
	return version()

	func RingVersion()
		return version()

func ring_char(n)
	return char(n)

func ring_EvenOrOdd(n) # Inverses the output to be more logic (odd -> 1, even -> 2)
	if EvenOrOdd(n) = 1
		return 2
	else
		return 1
	ok

	func ring_OddOrEven(n)
		return EvenOrOdd(n)

func ring_packages()
	return packages()

func ring_globals()
	return globals()

func ring_locals()
	return locals()

func ring_objects()
	return objects()

func ring_max(panNumbers)
	return max(panNumbers)

func ring_min(panNumbers)
	return min(panNumbers)

func ring_trim(str)
	return trim(str)

func ring_split(str, sep)
	return split(str, sep)

func ring_read(filePath)
	return read(filePath)

func ring_write(cFilePath, pcStr)
	return write(cFilePath, pcStr)

func ring_writeline(cFilePath, pcStr)
	return writeline(cFilePath, pcStr) #TODO // check that it exists in Ring!

func ring_insert(paList, n, item)
	#NOTE
	# We change the behaviour of the Ring function, since
	# it actually means in Ring insertAfter() and not insert()

	if NOT ( isList(paList)  or isNumber(n) )
		raise( "ERR-" + StkError(:IncorrectParamType) )
	ok

	if NOT n > 0
		raise( "ERR-" + StkError(:IncorrectParamValye) )
	ok

	insert(paList, n-1, item)
	return paList

func ring_find(paList, pItem)
	return find(paList, pItem)

func ring_type(p)
	return type(p)

func ring_reverse(pStrOrList)
	#WARNING // can't revese unicode string other then ASCII latin chars
	# --> use Softanza @Reverse() instead

	return reverse(pStrOrList)

func ring_sort(paList)
	return sort(paList)

	func ring_sort1(paList)
		return ring_sort(paList)

func ring_sort2(paList, n)
	aResult = sort(paList, n)
	return aResult

	func ring_sortXT(paList, n)
		return sort(paList, n)

func ring_swap(paList, n1, n2)
	swap(paList, n1, n2)
	return paList

func ring_methods(obj)
	return methods(obj)

func ring_attributes(obj)
	return attributes(obj)

func ring_classname(obj)
	return classname(obj)

func ring_factors(n)
	return factors(n)

func ring_LCM(n1, n2)
	return LCM(n1, n2)

func ring_GCD(n1, n2)
	return GCD(n1, n2)

func ring_log10(n)
	return log10(n)

func ring_log(n)
	return log(n)

func ring_tanhh(n)
	return tanhh(n)

func ring_cosh(n)
	return cosh(n)

func ring_sinh(n)
	return sinh(n)

func ring_atan2(n)
	return atan2(n)

func ring_acos(n)
	return acos(n)

func ring_asin(n)
	return asin(n)

func ring_tan(n)
	return tan(n)

func ring_cos(n)
	return cos(n)

func ring_sin(n)
	return sin(n)

func ring_exp(n)
	return exp(n) // #TODO What's the difference with pow() ?

func ring_pow(n, nPower)
	return pow(n, nPower)

	func power(n, nPower)
		return pow(n, nPower)

func ring_left(str, n)
	return left(str, n)

func ring_right(str, n)
	return right(str, n)

func ring_del(paList, n)

	del(paList, n)
	return paList

	#NOTE
	# Some Ring standard functions make the action in place and does not
	# return anything. Others do the action and return the result.
	#~>
	# The ring_...() functions family always do the action and return
	# the result. So you are free to say:

	# 	aList = [ 1, 1, 2, 3 ]
	# 	ring_insert(aList, 1, 1)
	# 	? aList
	# 	#--> [ 1, 2, 3 ]

	# Or directly:

	# 	? ring_insert([ 1, 1, 2, 3 ], 1, 1)
	# 	#--> [ 1, 2, 3 ]
	

	func ring_remove(paList, n) # An alternative I added to the Ring semantics
		return ring_del(paList, n)

func ring_file_remove(cFile)
	remove(cFile)

func ring_substr(paParams)
	if not isList(paParams)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	nLen = len(paParams)
	if n < 2 or n > 3
		raise("ERR-" + StkError(:IncorrectNumberOfParams))
	ok

	if nLen = 2
		return ring_substr1(paParams[1], paParams[2])
	but nLen = 3
		return ring_substr2(paParams[1], paParams[2], paParams[2])
	ok

func ring_substr1(str, substr) # Finds substr in str
	if str = "" or substr = ''
		return 0
	ok

	return substr(str, substr)

func ring_substr2(str, substr1, substr2) # Replaces substr1 by substr2 in str
	if str = "" or substr1 = ''
		return ""
	ok

	return substr(str, substr1, substr2)

func ring_copy(p1, p2)
	return copy(p1, p2)

	func @copy(p1, p2)
		return copy(p1, p2)

func ring_len(p)
	return len(p)

func ring_islower(str)
	return islower(str)

func ring_isupper(str)
	return isupper(str)

func ring_lower(str)
	return lower(str)

func ring_upper(str)
	return upper(str)

func ring_isPrime(n)
	return isPrime(n)

func ring_random(n)
	return random(n)

func ring_srandom(n)
	return srandom(n)

func ring_isvowel(c)
	return isvowel(c)

func ring_sqrt(n)
	return sqrt(n)

func ring_ceil(n)
	return ceil(n)

func ring_floor(n)
	return floor(n)

#-- #TODO need InternetLib.ring to work! Test them

func ring_md5(str)
	return md5(str)

func ring_sha1(str)
	return sha1(str)

func ring_sha256(str)
	return sha256(str)

func ring_sha384(str)
	return sha384(str)

func ring_sha224(str)
	return sha224(str)

func ring_sha512(str)
	return sha512(str)

func ring_supportedCiphers()
	return SupportedCiphers()

func ring_encrypt1(cString, cKey, cIV)
	return encrypt(cString, cKey, cIV)

func ring_encrypt2(cString, cKey, cIV, cCipherAlgorithmName)
	return encrypt(cString, cKey, cIV, cCipherAlgorithmName)

func ring_decrypt1(cString, cKey, cIV)
	return decrypt(cString, cKey, cIV)

func ring_decrypt2(cString, cKey, cIV, cCipherAlgorithmName)
	return decrypt(cString, cKey, cIV, cCipherAlgorithmName)

#--

func ring_randbytes(n)
	return randbytes(n)

func CatchError()
	return cCatchError
