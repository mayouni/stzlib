# Additional functions to stkRingFuncs.ring in CORE layer

func ceiling(n)
	return ceil(n)

func low(str)
	return lower(str)

func ring_dir(cFolderPath)
	return dir(cFolderPath)

func ring_dirExists(cDirPath)
	return dirExists(cDirPath)

func ring_getPathType(cPath)
	return getPathType(cPath)
	#--->
	# 0 if the path doesn't exists
	# 1 if it corresponds to existing file
	# 2 if it corresponds to existing directory
	# -1 if the path exists but has an unknown type (e.g. a pipe)

func ring_isdir(cPath)
	return isDir(cPath)

func ring_ChDir(cNewPath)
	return ChDir(cNewPath)

func ring_exefolder()
	return ring_exefolder()

func ring_fexists(cFile)
	return fexists(cFile)

#---

func ring_map(aList, f)
	return map(aList, f)

func ring_filter(aList, f)
	return filter(aList, f)

func ring_reduce(aList, f1, initialVal)
	return reduce(aList, f1, initialVal)

#---

func ring_download(cURL)
	return download(cURL)

#---

func ring_time()
	return time()

	func CurrentTime()
		return time()
