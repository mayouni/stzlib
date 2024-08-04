
# Wrappers to ring functions, that we use inside a softanza class
# where the same name is needed (example: insert() inside stzString)
#--> This will allow us to avoid conflicts!
#--> For you as a Ring programmer, this won't alter you Ring experience
#     when you want to use natibe Ring form. But if you are inside a
#     softanza object, then the softanza version will apply, unless you
#     you for the Ring's version using ring_...()

#TODO: Add the ring_...() form of all Ring functions

func ring_packages()
	return packages()

	func @ring_packages()
		return packages()

func ring_globals()
	return globals()

	func @ring_globals()
		return globals()

func ring_locals()
	return locals()

	func @ring_locals()
		return locals()

func ring_objects()
	return objects()

	func @ring_objects()
		return objects()

func ring_max(panNumbers)
	return max(panNumbers)

func ring_min(panNumbers)
	return min(panNumbers)

func ring_trim(str)
	return trim(str)

	func @trim(str)
		return trim(str)

func ring_split(str, sep)
	return split(str, sep)

	func @ring_split(str, sep)
		return split(str, sep)

func ring_read(filePath)
	return read(filePath)

	func @ring_read(filePath)
		return read(filePath)

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

	func @ring_insert(paList, n, item)
		return ring_insert(paList, n, item)

func ring_find(paList, pItem)
	return find(paList, pItem)

	func @ring_find(paList, pItem)
		return find(paList, pItem)

func ring_type(p)
	return type(p)

	func @ring_type(p)
		return type(p)

func ring_reverse(pStrOrList)
	#WARNING // can't revese unicode string other then ASCII latin chars
	# --> use Softanza @Reverse() instead

	return reverse(pStrOrList)

	func @ring_reverse(pStrOrList)
		return reverse(pStrOrList)

func ring_sort(paList)
	return sort(paList)

	func ring_sort1(paList)
		return ring_sort(paList)

	func @ring_sort(paList)
		return sort(paList)

	func @ring_sort1(paList)
		return ring_sort(paList)

func ring_sort2(paList, n)
	aResult = sort(paList, n)
	return aResult

	func ring_sortXT(paList, n)
		return sort(paList, n)

	func @ring_sort2(paList, n)
		return sort(paList, n)

	func @ring_sortXT(paList, n)
		return sort(paList, n)


func ring_swap(paList, n1, n2)
	swap(paList, n1, n2)
	return paList

	func @ring_swap(paList, n1, n2)
		return ring_swap(paList, n1, n2)

func ring_methods(obj)
	return methods(obj)

	func @ring_methods(obj)
		return methods(obj)

func ring_attributes(obj)
	return attributes(obj)

	func @ring_attributes(obj)
		return attributes(obj)

func ring_classname(obj)
	return classname(obj)

	func @ring_classname(obj)
		return classname(obj)

func ring_factors(n)
	return factors(n)

	func @ring_factors(n)
		return factors(n)

func ring_LCM(n1, n2)
	return LCM(n1, n2)

	func @ring_LCM(n1, n2)
		return LCM(n1, n2)

func ring_GCD(n1, n2)
	return GCD(n1, n2)

	func @ring_GCD(n1, n2)
		return GCD(n1, n2)

func ring_exp(n)
	return exp(n)

	func @ring_exp(n)
		return exp(n)

func ring_log10(n)
	return log10(n)

	func @ring_log10(n)
		return log10(n)

func ring_log(n)
	return log(n)

	func @ring_log(n)
		return log(n)

func ring_tanhh(n)
	return tanhh(n)

	func @ring_tanhh(n)
		return tanhh(n)

func ring_cosh(n)
	return cosh(n)

	func @ring_cosh(n)
		return cosh(n)

func ring_sinh(n)
	return sinh(n)

	func @ring_sinh(n)
		return sinh(n)

func ring_atan2(n)
	return atan2(n)

	func @ring_atan2(n)
		return atan2(n)

func ring_acos(n)
	return acos(n)

	func @ring_acos(n)
		return acos(n)

func ring_asin(n)
	return asin(n)

	func @ring_asin(n)
		return asin(n)

func ring_tan(n)
	return tan(n)

	func @ring_tan(n)
		return tan(n)

func ring_cos(n)
	return cos(n)

	func @ring_cos(n)
		return cos(n)

func ring_sin(n)
	return sin(n)

	func @ring_sin(n)
		return sin(n)

func ring_pow(n, nPower)
	return pow(n, nPower)

	func Power(n, nPower)
		return pow(n, nPower)

	func @Power(n, nPower)
		return pow(n, nPower)

	func @ring_power(n, nPower)
		return pow(n, nPower)

func ring_left(str, n)
	return left(str, n)

	func @ring_left(str, n)
		return left(str, n)

func ring_right(str, n)
	return right(str, n)

	func @ring_right(str, n)
		return right(str, n)

func ring_del(paList, n)
	del(paList, n)
	return paList

	#NOTE
	# Some Ring standard functions make the action in place and does nit
	# return anything. Others do the action and return the result.
	#~>
	# The ring_...() functions familty always do the action and return
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

	func remove(paList, n)	    # Idem
		return ring_del(paList, n)

	func @ring_del(paList, n)
		return ring_del(paList, n)

	func @ring_remove(paList, n) # An alternative I added to the Ring semantics
		return ring_del(paList, n)

	func @remove(paList, n)	    # Idem
		return ring_del(paList, n)


func ring_copy(p1, p2)
	return copy(p1, p2)

	func @ring_copy(p1, p2)
		return copy(p1, p2)

func ring_len(p)
	return len(p)

	func @ring_len(p)
		return len(p)

func ring_islower(str)
	return islower(str)

	func @ring_islower(str)
		return islower(str)

func ring_isupper(str)
	return isupper(str)

	func @ring_isupper(str)
		return isupper(str)

func ring_lower(str)
	return lower(str)

	func @ring_lower(str)
		return lower(str)

func ring_upper(str)
	return upper(str)

	func @ring_upper(str)
	return upper(str)

func ring_isPrime(n)
	return isPrime(n)

	func @ring_isPrime(n)
		return isPrime(n)


func ring_random(n)
	return random(n)

	func @ring_random(n)
		return random(n)

func ring_srandom(n)
	return srandom(n)

	func @ring_srandom(n)
		return srandom(n)

func ring_isvowel(c)
	return isvowel(c)

	func @ring_isvowel(c)
		return isvowel(c)
