
//t0 = clock()

# Loading common staff

	load "common/stkRingLibs.ring"		# Ring libraries and extensions
	load "common/stkWrapRingFuncs.ring"	# Wrappers to Ring funcs for scope protection
	load "common/stkLowLevelFuncs.ring"	# Pointer and simular low level functions staff

	load "common/stkNumberCommons.ring"	# Common functions (and constants) to all number classes
	load "common/stkStringCommons.ring"	# Idem for strings
	load "common/stkListCommons.ring"	# Idem for lists
	load "common/stkObjectCommons.ring"	# Idem for objects

# Loading core technical services

	load "error/stkError.ring"

# Loading Softanka (core) classes

	load "object/stkObject.ring"

	load "string/stkString.ring"
	load "string/stkChar.ring"

	load "list/stkList.ring"
	load "number/stkNumber.ring"

//? ( clock() - t0 ) / clockspersecond()
