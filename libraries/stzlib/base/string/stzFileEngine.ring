#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZFILEENGINE              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : File/Dir/Path ops -- Engine-backed          #
#                  (Zig DLL). Standalone functions for file     #
#                  I/O, directory management, path parsing.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  ///////////////////////////
 ///   FILE FUNCTIONS    ///
///////////////////////////

func StzFileExists(pcPath)
	return StzEngineFileExists(pcPath)

func StzFileSize(pcPath)
	return StzEngineFileSize(pcPath)

func StzFileRead(pcPath)
	return StzEngineFileRead(pcPath)

func StzFileWrite(pcPath, pcContent)
	return StzEngineFileWrite(pcPath, pcContent)

func StzFileAppend(pcPath, pcContent)
	return StzEngineFileAppend(pcPath, pcContent)

func StzFileDelete(pcPath)
	return StzEngineFileDelete(pcPath)

func StzFileCopy(pcSrc, pcDst)
	return StzEngineFileCopy(pcSrc, pcDst)


  ////////////////////////////
 ///   DIR FUNCTIONS      ///
////////////////////////////

func StzDirExists(pcPath)
	return StzEngineDirExists(pcPath)

func StzDirCreate(pcPath)
	return StzEngineDirCreate(pcPath)

func StzDirCreatePath(pcPath)
	return StzEngineDirCreatePath(pcPath)

	func StzDirCreateAll(pcPath)
		return StzDirCreatePath(pcPath)

func StzDirDelete(pcPath)
	return StzEngineDirDelete(pcPath)

func StzDirCountFiles(pcPath)
	return StzEngineDirCountFiles(pcPath)

func StzDirCountDirs(pcPath)
	return StzEngineDirCountDirs(pcPath)


  /////////////////////////////
 ///   PATH FUNCTIONS      ///
/////////////////////////////

func StzPathExtension(pcPath)
	return StzEnginePathExtension(pcPath)

	func StzFileExtension(pcPath)
		return StzPathExtension(pcPath)

func StzPathBasename(pcPath)
	return StzEnginePathBasename(pcPath)

	func StzFileName(pcPath)
		return StzPathBasename(pcPath)

func StzPathDirname(pcPath)
	return StzEnginePathDirname(pcPath)

	func StzFileDir(pcPath)
		return StzPathDirname(pcPath)
