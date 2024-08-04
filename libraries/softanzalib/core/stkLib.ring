# Lading Ring standard library

	load "stdLib.ring"

# Loading Ring extensions (used by SoftanzaCore)

	load "lightguilib.ring" # Takes most of the time made by non-Softanza libraries

	#TODO // Replace with "ringqtcorelib.ring" when included in future Ring.
	      // test it with:
	      // load "../libraries/guilib/classes/ring_qtcore.ring"
	      // loadlib("ringqt_core.dll")
	      // But don't keep it because we will not be able to use load "guilib.ring" or "lightguilib.ring"
	
	# load "sqlitelib.ring"
	# load "tracelib.ring"

# Loading common staff

	load "common/stkRingFunc.ring"

# Loading core technical services

	load "error/stkError.ring"

# Loading Softanka (core) classes

	load "object/stkObject.ring"

	load "string/stkString.ring"
	load "string/stkChar.ring"

	load "list/stkList.ring"

