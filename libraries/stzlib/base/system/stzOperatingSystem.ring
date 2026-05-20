#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  SOFTANZA OPERATING SYSTEM    #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# GLOBAL FUNCTIONS
#==================

func StzOperatingSystemQ()
	return new stzOperatingSystem()

func @isWindows()
	return iswindows()

func @isWindows64()
	return iswindows64()

func StzIsWindows32()
	return iswindows() and not iswindows64()

	func isWindows32()
		return StzIsWindows32()

	func @isWindows32()
		return StzIsWindows32()

func @isMSDOS()
	return ismsdos()

func @isUnix()
	return isunix()

func @isLinux()
	return islinux()

func @isMacOSX()
	return ismacosx()

func @isFreeBSD()
	return isfreebsd()

func @isAndroid()
	return isAndroid()

func StzOS()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.Name()

	func OS()
		return StzOS()

	func OperatingSystem()
		return StzOS()

func StzArch()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.Architecture()

	func Arch()
		return StzArch()

	func Architecture()
		return StzArch()

	func SystemArch()
		return StzArch()

	func SystemArchitecture()
		return StzArch()

func StzIs32Bit()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.Is32Bit()

	func Is32Bit()
		return StzIs32Bit()

func StzIs64Bit()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.Is64Bit()

	func Is64Bit()
		return StzIs64Bit()

func StzIsARM()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsARM()

	func IsARM()
		return StzIsARM()

func StzIsARM32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsARM32()

	func IsARM32()
		return StzIsARM32()

func StzIsARM64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsARM64()

	func IsARM64()
		return StzIsARM64()

func StzIsX86()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsX86()

	func IsX86()
		return StzIsX86()

func StzIsX64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsX64()

	func IsX64()
		return StzIsX64()

func StzIsMSDOS32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsMSDOS32()

	func IsMSDOS32()
		return StzIsMSDOS32()

	func @IsMSDOS32()
		return StzIsMSDOS32()

func StzIsMSDOS64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsMSDOS64()

	func IsMSDOS64()
		return StzIsMSDOS64()

	func @IsMSDOS64()
		return StzIsMSDOS64()

func StzIsUnix32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsUnix32()

	func IsUnix32()
		return StzIsUnix32()

	func @IsUnix32()
		return StzIsUnix32()

func StzIsUnix64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsUnix64()

	func IsUnix64()
		return StzIsUnix64()

	func @IsUnix64()
		return StzIsUnix64()

func StzIsLinux32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsLinux32()

	func IsLinux32()
		return StzIsLinux32()

	func @IsLinux32()
		return StzIsLinux32()

func StzIsLinux64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsLinux64()

	func IsLinux64()
		return StzIsLinux64()

	func @IsLinux64()
		return StzIsLinux64()

func StzIsFreeBSD32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsFreeBSD32()

	func IsFreeBSD32()
		return StzIsFreeBSD32()

	func @IsFreeBSD32()
		return StzIsFreeBSD32()

func StzIsFreeBSD64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsFreeBSD64()

	func IsFreeBSD64()
		return StzIsFreeBSD64()

	func @IsFreeBSD64()
		return StzIsFreeBSD64()

func StzIsMacOSX32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsMacOS32()

	func IsMacOSX32()
		return StzIsMacOSX32()

	func @IsMacOSX32()
		return StzIsMacOSX32()

	func IsMacOS32()
		return StzIsMacOSX32()

func StzIsMacOSX64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsMacOS64()

	func IsMacOSX64()
		return StzIsMacOSX64()

	func @IsMacOSX64()
		return StzIsMacOSX64()

	func IsMacOS64()
		return StzIsMacOSX64()

	func @IsMacOS64()
		return StzIsMacOSX64()

func StzIsAndroid32()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsAndroid32()

	func IsAndroid32()
		return StzIsAndroid32()

	func @IsAndroid32()
		return StzIsAndroid32()

func StzIsAndroid64()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.IsAndroid64()

	func IsAndroid64()
		return StzIsAndroid64()

	func @IsAndroid64()
		return StzIsAndroid64()

func StzIs32Or64Bit()
	_oOS_ = new stzOperatingSystem()
	nBits = _oOS_.BitSize()
	if nBits = 32
		return :32
	but nBits = 64
		return :64
	else
		return :Unknown
	ok

	func Is32Or64Bit()
		return StzIs32Or64Bit()

	func Is64Or32Bit()
		return StzIs32Or64Bit()

func StzOperatingSystemXT()
	_oOS_ = new stzOperatingSystem()
	return _oOS_.NameAndArchitecture()

	func OperatingSystemXT()
		return StzOperatingSystemXT()

	func OSXT()
		return OperatingSystemXT()

	func OperatingSystemAndItsArchitecture()
		return OperatingSystemXT()

	func OSAndArch()
		return OperatingSystemXT()

# THE CLASS
#===========

class stzOperatingSystem

	def init()

	#-----------------------#
	#  ARCHITECTURE INFO    #
	#-----------------------#

	def Architecture()
		return getArch()

		def Arch()
			return This.Architecture()

	def Is32Bit()
		cArch = This.Arch()
		return (cArch = "x86" or cArch = "arm")

	def Is64Bit()
		cArch = This.Arch()
		return (cArch = "x64" or cArch = "arm64")

	def BitSize()
		if This.Is32Bit()
			return 32
		but This.Is64Bit()
			return 64
		else
			return 0
		ok

		def Bits()
			return This.BitSize()

	def IsARM()
		cArch = This.Arch()
		return (cArch = "arm" or cArch = "arm64")

	def IsARM32()
		return (This.Arch() = "arm")

	def IsARM64()
		return (This.Arch() = "arm64")

	def IsX86()
		return (This.Arch() = "x86")

	def IsX64()
		return (This.Arch() = "x64")

	def IsIntel()
		return (This.IsX86() or This.IsX64())

	#-----------------------#
	#  OPERATING SYSTEM     #
	#-----------------------#

	def Name()
		if @isWindows() or @isWindows64()
			return "windows"

		but @isMSDOS()
			return "msdos"

		but @isUnix()
			return "unix"

		but @isLinux()
			return "linux"

		but @isMacOSX()
			return "macos"

		but @isFreeBSD()
			return "freebsd"

		but @isAndroid()
			return "android"
		else
			return "unknown"
		ok

		def OS()
			return This.Name()

		def OperatingSystem()
			return This.Name()

	def NameAndArchitecture()
		return [ This.Name(), This.Architecture() ]

		def NameAndArch()
			return This.NameAndArchitecture()

		def OSAndArch()
			return This.NameAndArchitecture()

	def FullName()
		cName = This.Name()
		nBits = This.BitSize()
		return cName + " " + nBits + "-bit"

		def FullOSName()
			return This.FullName()

	#-----------------------#
	#  OS TYPE CHECKS       #
	#-----------------------#

	def IsWindows()
		return (This.Name() = "windows")

	def IsWindows32()
		return (This.IsWindows() and This.Is32Bit())

	def IsWindows64()
		return (This.IsWindows() and This.Is64Bit())

	def IsMSDOS()
		return (This.Name() = "msdos")

	def IsMSDOS32()
		return (This.IsMSDOS() and This.Is32Bit())

	def IsMSDOS64()
		return (This.IsMSDOS() and This.Is64Bit())

	def IsUnix()
		return (This.Name() = "unix")

	def IsUnix32()
		return (This.IsUnix() and This.Is32Bit())

	def IsUnix64()
		return (This.IsUnix() and This.Is64Bit())

	def IsLinux()
		return (This.Name() = "linux")

	def IsLinux32()
		return (This.IsLinux() and This.Is32Bit())

	def IsLinux64()
		return (This.IsLinux() and This.Is64Bit())

	def IsFreeBSD()
		return (This.Name() = "freebsd")

	def IsFreeBSD32()
		return (This.IsFreeBSD() and This.Is32Bit())

	def IsFreeBSD64()
		return (This.IsFreeBSD() and This.Is64Bit())

	def IsMacOS()
		return (This.Name() = "macos")

		def IsMacOSX()
			return This.IsMacOS()

	def IsMacOS32()
		return (This.IsMacOS() and This.Is32Bit())

		def IsMacOSX32()
			return This.IsMacOS32()

	def IsMacOS64()
		return (This.IsMacOS() and This.Is64Bit())

		def IsMacOSX64()
			return This.IsMacOS64()

	def IsAndroid()
		return (This.Name() = "android")

	def IsAndroid32()
		return (This.IsAndroid() and This.Is32Bit())

	def IsAndroid64()
		return (This.IsAndroid() and This.Is64Bit())

	#-----------------------#
	#  OS FAMILY CHECKS     #
	#-----------------------#

	def IsUnixLike()
		return (This.IsUnix() or This.IsLinux() or 
		        This.IsMacOS() or This.IsFreeBSD())

		def IsPOSIX()
			return This.IsUnixLike()

	def IsMicrosoft()
		return (This.IsWindows() or This.IsMSDOS())

	def IsMobile()
		return This.IsAndroid()

	def IsDesktop()
		return NOT This.IsMobile()

	#-----------------------#
	#  SYSTEM INFO          #
	#-----------------------#

	def Info()
		aInfo = [
			:name = This.Name(),
			:architecture = This.Architecture(),
			:bits = This.BitSize(),
			:fullname = This.FullName(),
			:isUnixLike = This.IsUnixLike(),
			:isMicrosoft = This.IsMicrosoft(),
			:isMobile = This.IsMobile()
		]
		return aInfo

		def SystemInfo()
			return This.Info()

		def Details()
			return This.Info()

	def Show()
		aInfo = This.Info()
		? "Operating System Information:"
		? "  Name: " + aInfo[:name]
		? "  Architecture: " + aInfo[:architecture]
		? "  Bits: " + aInfo[:bits]
		? "  Full Name: " + aInfo[:fullname]
		? "  Unix-like: " + aInfo[:isUnixLike]
		? "  Microsoft: " + aInfo[:isMicrosoft]
		? "  Mobile: " + aInfo[:isMobile]

		def Print()
			This.Show()

		def Display()
			This.Show()

	#-----------------------#
	#  UTILITIES            #
	#-----------------------#

	def PathSeparator()
		if This.IsWindows()
			return "\"
		else
			return "/"
		ok

		def PathSep()
			return This.PathSeparator()

		def DirectorySeparator()
			return This.PathSeparator()

	def LineEnding()
		if This.IsWindows()
			return "\r\n"
		else
			return "\n"
		ok

		def NewLine()
			return This.LineEnding()

		def EOL()
			return This.LineEnding()

	def NormalizePath(cPath)
		cSep = This.PathSeparator()
		if This.IsWindows()
			cPath = StzReplace(cPath, "/", "\")
		else
			cPath = StzReplace(cPath, "\", "/")
		ok
		return cPath

		def NormalizePathQ(cPath)
			return This.NormalizePath(cPath)

	def ExecutableExtension()
		if This.IsWindows()
			return ".exe"
		else
			return ""
		ok

		def ExeExtension()
			return This.ExecutableExtension()

	def SupportsColor()
		# Basic check - can be enhanced
		if This.IsWindows()
			return TRUE  # Windows 10+ supports ANSI
		else
			return TRUE  # Unix-like systems typically support color
		ok

		def HasColorSupport()
			return This.SupportsColor()
