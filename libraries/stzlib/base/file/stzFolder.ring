func IsFolder(cDir)
	return dirExists(cDir)

	func IsDir(cDir)
		return dirExists(cDir)

	func @IsFolder(cDir)
		return dirExists(cDir)

	func @IsDir(cDir)
		return dirExists(cDir)


func StzFolderQ(cDir)
	return new stzFolder(cDir)

	func StzDirQ(cDir)
		return new stzFolder(cDir)

class stzDir from stzFolder
class stzFolder from stzObject
	oQDir

	def init(pcDirPath)
		oQDir = new QDir()

		// oQDir.mkdir(pcDirPath)
		oQDir.setPath(pcDirPath)
	
	def Name()
		return oQDir.dirname()

	def Path()
		return oQDir.Path()

	def AbsolutePath()
		return oQDir.absolutePath()

	def CanonicalPath()
		return oQDir.canonicalPath()

	def cd()
		return oQDir.cd()

	def cdUp()
		return oQDir.cdUp()

	// Creates a sub-directory
	def mkdir(pcDirName)
		return oQDir.mkdir(pcDirName)

	// Creates all the directories indicated by the provided path
	def mkpath(pcDirPath)
		return oQDir.mkpath(pcDirPath)

	def rmdir()
		return oQDir.rmdir(".")

	  #-----------#
	 #   MISC.   #
	#-----------#

	def IsFolder() # required by stzChainOfTruth
		return _TRUE_

		def IsAFolder()
			return _TRUE_

		def IsDir()
			return _TRUE_

		def IsADir()
			return _TRUE_