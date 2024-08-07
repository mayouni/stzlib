
$LOADED_RING_FILES = []

func Use(cRingFile)

	if isString(cRingFile)

		# Case where the file name contains no path

		if substr(cRingFile, "/") = 0
			cFileName = lower(cRingFile)

		else // Case where the file name contains a path

			i = len(cRingFile)
			cFileName = ""
	
			while TRUE
				c = cRingFile[i]
				if c = "/"
					exit
	
				else
					cFileName += c
					i--
					if i = 0
						exit
					ok
				ok
	
			end

			cFileName = lower( reverse(cFileName) )
		ok

		# Loading the file only if ity has not been loaded before

		if find( $LOADED_RING_FILES, cFileName ) = 0

			# Loading the file

			cCode = 'load "' + cRingFile + '"'
			eval(cCode)

			# Memorising the file name

			$LOADED_RING_FILES + cFileName
		ok

	but isList(cRingFile)
		UseMany(cRingFile)
	ok

func UseMany(acRingFiles)

	if not isList(acRingFiles)
		raise( "ERR-" + raise(StkError(:IncorrectParamType)) )

	else

		nLen = len(acRingFiles)
		if nLen = 0
			return
		ok

		# all items must be strings

		for i = 1 to nLen
			if not isString(acRingFiles[i])
				raise( "ERR-" + raise( StkError(:IncorrectParamType)) )
			ok
		next

		# loading the files

		for i = 1 to nLen
			if find( $LOADED_RING_FILES, lower(acRingFiles[i]) ) = 0
				Use(acRingFiles[i])
			ok
		next

	ok

	
