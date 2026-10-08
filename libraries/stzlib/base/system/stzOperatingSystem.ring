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
	_nBits_ = _oOS_.BitSize()
	if _nBits_ = 32
		return :32
	but _nBits_ = 64
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

# Answers what machine and operating system the program runs on, with a predicate for each family and width.
#
# It reads the processor facts (architecture, pointer width, byte order) from the engine and the
# operating-system family from Ring, and offers one TRUE or FALSE question per family and per width,
# so a program branches on the machine instead of parsing a name. Name gives the family as a lower-
# case word, Info gathers the facts in a list of pairs, and PathSeparator, LineEnding, NormalizePath
# and ExecutableExtension answer what a path or a program file looks like here. It only reads:
# nothing is changed on the machine.
#
#   receiver   o1 = new stzOperatingSystem()
#   example    ? o1.BitSize() = (o1.PointerSize() * 8)
#              #--> 1
#              ? o1.NormalizePath("a/b/c.txt") = ("a" + o1.PathSeparator() + "b" + o1.PathSeparator() + "c.txt")
#              #--> 1
#              ? len(o1.Info())
#              #--> 7
#   see        stzProcess, stzSystemProfile, stzCurrentSystem
class stzOperatingSystem from stzObject

	# Builds a reader of the machine the program runs on; it takes no argument and holds nothing.
	#
	#   returns    nothing; the object is built
	#   see        Name, Architecture
	def init()

	#-----------------------#
	#  ARCHITECTURE INFO    #
	#-----------------------#

	# Returns the processor family of this machine, read from the engine: x64, x86, arm or arm64.
	#
	#   returns    a text such as "x64"
	#   note       the engine is the one source of the fact, so the answer agrees with stzProcess
	#   see        BitSize, IsX64, IsARM64
	#@ aka  ENGINE-BACKED. This used to be Ring's getArch() -- a SECOND computation of a fact the engine already owns (process.zig's process_arch). Two sources of one truth: they happened to agree, but nothing guaranteed it, and a future non-Ring binding of Softanza would have had to derive the fact a third time. It now reads the ONE engine source, through stzProcess, which also owns the Zig<->Softanza vocabu
	def Architecture()
		_oP_ = new stzProcess()
		return _oP_.Architecture()

		def Arch()
			return This.Architecture()

	# TRUE if this machine's native pointer is 4 bytes wide.
	#
	#   returns    TRUE or FALSE
	#   see        BitSize, Is64Bit, PointerSize
	#@ aka  ENGINE-BACKED: the native pointer size decides the bit width directly (8 bytes = 64-bit), rather than inferring it from the arch string and returning 0 for anything unrecognised.
	def Is32Bit()
		_oP_ = new stzProcess()
		return _oP_.Is32Bit()

	def Is64Bit()
		_oP_ = new stzProcess()
		return _oP_.Is64Bit()

	# Returns the width of this machine's native pointer, in bits.
	#
	#   returns    a number, 32 or 64
	#   see        Is32Bit, Is64Bit, PointerSize
	def BitSize()
		_oP_ = new stzProcess()
		return _oP_.BitSize()

		def Bits()
			return This.BitSize()

	# Returns the byte order of this machine as a word.
	#
	#   returns    a text, "little" or "big"
	#   see        IsLittleEndian, IsBigEndian
	#@ aka  ENGINE-BACKED machine facts (were absent on this class).
	def Endianness()
		_oP_ = new stzProcess()
		return _oP_.Endianness()

	# TRUE if this machine stores the least significant byte first.
	#
	#   returns    TRUE or FALSE
	#   see        Endianness, IsBigEndian
	def IsLittleEndian()
		_oP_ = new stzProcess()
		return _oP_.IsLittleEndian()

	# TRUE if this machine stores the most significant byte first.
	#
	#   returns    TRUE or FALSE
	#   see        Endianness, IsLittleEndian
	def IsBigEndian()
		_oP_ = new stzProcess()
		return _oP_.IsBigEndian()

	# Returns how many bytes a native pointer takes on this machine.
	#
	#   returns    a number, 4 or 8
	#   see        BitSize
	def PointerSize()
		_oP_ = new stzProcess()
		return _oP_.PointerSize()

		def PointerSizeInBytes()
			return This.PointerSize()

	# TRUE if the processor is an ARM, 32-bit or 64-bit.
	#
	#   returns    TRUE or FALSE
	#   see        Architecture, IsARM32, IsARM64
	def IsARM()
		_cArch_ = This.Arch()
		return (_cArch_ = "arm" or _cArch_ = "arm64")

	# TRUE if the processor is a 32-bit ARM.
	#
	#   returns    TRUE or FALSE
	#   see        IsARM, Architecture
	def IsARM32()
		return (This.Arch() = "arm")

	# TRUE if the processor is a 64-bit ARM.
	#
	#   returns    TRUE or FALSE
	#   see        IsARM, Architecture
	def IsARM64()
		return (This.Arch() = "arm64")

	# TRUE if the processor is a 32-bit Intel-compatible one.
	#
	#   returns    TRUE or FALSE
	#   see        IsX64, IsIntel
	def IsX86()
		return (This.Arch() = "x86")

	# TRUE if the processor is a 64-bit Intel-compatible one.
	#
	#   returns    TRUE or FALSE
	#   see        IsX86, IsIntel
	def IsX64()
		return (This.Arch() = "x64")

	# TRUE if the processor is Intel-compatible, 32-bit or 64-bit.
	#
	#   returns    TRUE or FALSE
	#   see        IsX86, IsX64
	def IsIntel()
		return (This.IsX86() or This.IsX64())

	#-----------------------#
	#  OPERATING SYSTEM     #
	#-----------------------#

	# Returns the family of operating system this program runs on, as a lower-case word.
	#
	#   returns    a text: windows, msdos, unix, linux, macos, freebsd, android, or unknown
	#   note       the other Is... family predicates compare this word
	#   warning    on Linux the answer depends on Ring's own Unix test, which Name asks before the
	#              Linux test: this was run on Windows only, so whether Linux answers linux or unix
	#              is not run
	#   see        FullName, NameAndArchitecture, IsWindows
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

	# Returns the operating system and the processor family together, as a pair.
	#
	#   returns    a list [ name, architecture ], such as [ "windows", "x64" ]
	#   see        Name, Architecture
	def NameAndArchitecture()
		return [ This.Name(), This.Architecture() ]

		def NameAndArch()
			return This.NameAndArchitecture()

		def OSAndArch()
			return This.NameAndArchitecture()

	# Returns the operating system and its pointer width as one sentence-like text.
	#
	#   returns    a text such as "windows 64-bit"
	#   see        Name, BitSize
	def FullName()
		_cName_ = This.Name()
		_nBits_ = This.BitSize()
		return _cName_ + " " + _nBits_ + "-bit"

		def FullOSName()
			return This.FullName()

	#-----------------------#
	#  OS TYPE CHECKS       #
	#-----------------------#

	# TRUE if this program runs on Microsoft Windows.
	#
	#   returns    TRUE or FALSE
	#   see        IsWindows64, Name
	def IsWindows()
		return (This.Name() = "windows")

	# TRUE if this program runs on 32-bit Microsoft Windows.
	#
	#   returns    TRUE or FALSE
	#   see        IsWindows, Is32Bit
	def IsWindows32()
		return (This.IsWindows() and This.Is32Bit())

	# TRUE if this program runs on 64-bit Microsoft Windows.
	#
	#   returns    TRUE or FALSE
	#   see        IsWindows, Is64Bit
	def IsWindows64()
		return (This.IsWindows() and This.Is64Bit())

	# TRUE if this program runs on MS-DOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsMicrosoft, Name
	def IsMSDOS()
		return (This.Name() = "msdos")

	# TRUE if this program runs on 32-bit MS-DOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsMSDOS, Is32Bit
	def IsMSDOS32()
		return (This.IsMSDOS() and This.Is32Bit())

	# TRUE if this program runs on 64-bit MS-DOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsMSDOS, Is64Bit
	def IsMSDOS64()
		return (This.IsMSDOS() and This.Is64Bit())

	# TRUE if the family word is unix, which Name tests before linux, macos and freebsd.
	#
	#   returns    TRUE or FALSE
	#   note       on a system where Ring's own Unix test is also true for Linux, this answers TRUE
	#              and IsLinux FALSE; not run, this was checked on Windows only
	#   see        IsUnixLike, Name
	def IsUnix()
		return (This.Name() = "unix")

	# TRUE if this program runs on a generic 32-bit Unix system.
	#
	#   returns    TRUE or FALSE
	#   see        IsUnix, Is32Bit
	def IsUnix32()
		return (This.IsUnix() and This.Is32Bit())

	# TRUE if this program runs on a generic 64-bit Unix system.
	#
	#   returns    TRUE or FALSE
	#   see        IsUnix, Is64Bit
	def IsUnix64()
		return (This.IsUnix() and This.Is64Bit())

	# TRUE if this program runs on Linux.
	#
	#   returns    TRUE or FALSE
	#   see        IsLinux64, IsUnixLike
	def IsLinux()
		return (This.Name() = "linux")

	# TRUE if this program runs on 32-bit Linux.
	#
	#   returns    TRUE or FALSE
	#   see        IsLinux, Is32Bit
	def IsLinux32()
		return (This.IsLinux() and This.Is32Bit())

	# TRUE if this program runs on 64-bit Linux.
	#
	#   returns    TRUE or FALSE
	#   see        IsLinux, Is64Bit
	def IsLinux64()
		return (This.IsLinux() and This.Is64Bit())

	# TRUE if this program runs on FreeBSD.
	#
	#   returns    TRUE or FALSE
	#   see        IsUnixLike, Name
	def IsFreeBSD()
		return (This.Name() = "freebsd")

	# TRUE if this program runs on 32-bit FreeBSD.
	#
	#   returns    TRUE or FALSE
	#   see        IsFreeBSD, Is32Bit
	def IsFreeBSD32()
		return (This.IsFreeBSD() and This.Is32Bit())

	# TRUE if this program runs on 64-bit FreeBSD.
	#
	#   returns    TRUE or FALSE
	#   see        IsFreeBSD, Is64Bit
	def IsFreeBSD64()
		return (This.IsFreeBSD() and This.Is64Bit())

	# TRUE if this program runs on macOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsMacOS64, IsUnixLike
	def IsMacOS()
		return (This.Name() = "macos")

		def IsMacOSX()
			return This.IsMacOS()

	# TRUE if this program runs on 32-bit macOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsMacOS, Is32Bit
	def IsMacOS32()
		return (This.IsMacOS() and This.Is32Bit())

		def IsMacOSX32()
			return This.IsMacOS32()

	# TRUE if this program runs on 64-bit macOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsMacOS, Is64Bit
	def IsMacOS64()
		return (This.IsMacOS() and This.Is64Bit())

		def IsMacOSX64()
			return This.IsMacOS64()

	# TRUE if this program runs on Android, which is also what IsMobile asks.
	#
	#   returns    TRUE or FALSE
	#   see        IsAndroid64, IsDesktop
	def IsAndroid()
		return (This.Name() = "android")

	# TRUE if this program runs on 32-bit Android.
	#
	#   returns    TRUE or FALSE
	#   see        IsAndroid, Is32Bit
	def IsAndroid32()
		return (This.IsAndroid() and This.Is32Bit())

	# TRUE if this program runs on 64-bit Android.
	#
	#   returns    TRUE or FALSE
	#   see        IsAndroid, Is64Bit
	def IsAndroid64()
		return (This.IsAndroid() and This.Is64Bit())

	#-----------------------#
	#  OS FAMILY CHECKS     #
	#-----------------------#

	# TRUE if the system follows the Unix tradition: Unix, Linux, macOS or FreeBSD.
	#
	#   returns    TRUE or FALSE
	#   note       IsPOSIX asks the same; Android is not counted
	#   see        IsMicrosoft, Name
	def IsUnixLike()
		return (This.IsUnix() or This.IsLinux() or 
		        This.IsMacOS() or This.IsFreeBSD())

		def IsPOSIX()
			return This.IsUnixLike()

	# TRUE if the system is Windows or MS-DOS.
	#
	#   returns    TRUE or FALSE
	#   see        IsUnixLike, Name
	def IsMicrosoft()
		return (This.IsWindows() or This.IsMSDOS())

	def IsMobile()
		return This.IsAndroid()

	# TRUE if the system is not a mobile one, that is not Android.
	#
	#   returns    TRUE or FALSE
	#   note       a system whose family is unknown also answers TRUE
	#   see        IsAndroid, Name
	def IsDesktop()
		return NOT This.IsMobile()

	#-----------------------#
	#  SYSTEM INFO          #
	#-----------------------#

	# Returns a summary of the system as a list of [ key, value ] pairs.
	#
	#   returns    a list of pairs: name, architecture, bits, fullname, isunixlike, ismicrosoft,
	#              ismobile
	#   note       SystemInfo and Details are the same call
	#   see        Show, Name
	def Info()
		_aInfo_ = [
			:name = This.Name(),
			:architecture = This.Architecture(),
			:bits = This.BitSize(),
			:fullname = This.FullName(),
			:isUnixLike = This.IsUnixLike(),
			:isMicrosoft = This.IsMicrosoft(),
			:isMobile = This.IsMobile()
		]
		return _aInfo_

		def SystemInfo()
			return This.Info()

		def Details()
			return This.Info()

	# Prints a summary of the system, one fact per line, under a heading.
	#
	#   returns    nothing; it prints
	#   note       Print and Display are the same call
	#   see        Info
	def Show()
		_aInfo_ = This.Info()
		? "Operating System Information:"
		? "  Name: " + _aInfo_[:name]
		? "  Architecture: " + _aInfo_[:architecture]
		? "  Bits: " + _aInfo_[:bits]
		? "  Full Name: " + _aInfo_[:fullname]
		? "  Unix-like: " + _aInfo_[:isUnixLike]
		? "  Microsoft: " + _aInfo_[:isMicrosoft]
		? "  Mobile: " + _aInfo_[:isMobile]

		# Prints a summary of the system, one fact per line, as Show does.
		#
		#   returns    nothing; it prints
		#   see        Show, Info
		def Print()
			This.Show()

		# Prints a summary of the system, one fact per line, as Show does.
		#
		#   returns    nothing; it prints
		#   see        Show, Info
		def Display()
			This.Show()

	#-----------------------#
	#  UTILITIES            #
	#-----------------------#

	# Returns the character that separates the parts of a file path on this system.
	#
	#   returns    a text, "\" on Windows and "/" elsewhere
	#   see        NormalizePath, LineEnding
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

	# Returns the end-of-line marker of this system.
	#
	#   returns    a text, a carriage return then a line feed on Windows and a line feed elsewhere
	#   see        PathSeparator
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

	# Returns a path with its separators changed to this system's own.
	#
	#   _cPath_    the path to convert, as text
	#   returns    a text; backslashes on Windows, slashes elsewhere
	#   note       the path is not checked against the disk; NormalizePathQ is the same call and
	#              returns the same text
	#   see        PathSeparator
	def NormalizePath(_cPath_)
		_cSep_ = This.PathSeparator()
		if This.IsWindows()
			_cPath_ = StzReplace(_cPath_, "/", "\")
		else
			_cPath_ = StzReplace(_cPath_, "\", "/")
		ok
		return _cPath_

		def NormalizePathQ(_cPath_)
			return This.NormalizePath(_cPath_)

	# Returns the suffix that names a program file on this system.
	#
	#   returns    a text, ".exe" on Windows and an empty text elsewhere
	#   see        PathSeparator, IsWindows
	def ExecutableExtension()
		if This.IsWindows()
			return ".exe"
		else
			return ""
		ok

		def ExeExtension()
			return This.ExecutableExtension()

	# TRUE if the console can be assumed to show ANSI colours.
	#
	#   returns    TRUE or FALSE
	#   note       it is a guess by operating system, not a test of the console: it answers TRUE on
	#              every system
	#   see        Info
	def SupportsColor()
		# Basic check - can be enhanced
		if This.IsWindows()
			return 1  # Windows 10+ supports ANSI
		else
			return 1  # Unix-like systems typically support color
		ok

		def HasColorSupport()
			return This.SupportsColor()
