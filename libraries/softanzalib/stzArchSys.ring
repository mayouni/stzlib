load "stzGlobSys.ring"

func Arch()
	return getArch()

	func Architecture()
		return getArch()

	func SystemArch()
		return GetArch()

	func SystemArchitecture()
		return GetArch()

func Is32Bit()
	cArch = Arch()
	if cArch = "x86" or cArch = "arm"
		return TRUE
	else
		return FALSE
	ok

func Is64Bit()
	cArch = Arch()
	if cArch = "x64" or cArch = "arm64"
		return TRUE
	else
		return FALSE
	ok

func Is32Or54Bit()
	cArch = Arch()
	if cArch = "x86" or cArch = "arm"
		return :32
	but cArch = "x64" or cArch = "arm64"
		return :64
	else
		return :Unknown
	ok

func IsARM()
	cArch = GetArch()
	if cArch = "arm" or cArch = "arm64"
		return TRUE
	else
		return FALSE
	ok

func IsARM32()
	cArch = GetArch()
	if cArch = "arm"
		return TRUE
	else
		return FALSE
	ok

func IsARM64()
	cArch = GetArch()
	if cArch = "arm64"
		return TRUE
	else
		return FALSE
	ok

func IsX86()
	cArch = GetArch()
	if cArch = "x86"
		return TRUE
	else
		return FALSE
	ok

func IsX64()
	cArch = GetArch()
	if cArch = "x64"
		return TRUE
	else
		return FALSE
	ok

func OperatingSystem()
	if isWindows() or isWindows64()
		return "windows"

	but isMSDOS()
		return "msdos"

	but isUnix()
		return "unix"

	but isLinux()
		return "linux"

	but isMacOSX()
		return "macosx"

	but isFreeBSD()
		return "freebsd"

	but isAndroid()
		return "android"

	else
		retur "unknown"
	ok

	func OS()
		return OperatingSystem()

func OperatingSystemXT() // returns the OS and its architecture (32 or 64 bits)
	aResult = [ OperatingSystem(), Architecture() ]
	return aResult

	func OSXT()
		return OperatingSystemXT()

	func OperatingSystemAndItsArchitecture()
		return OperatingSystemXT()

	func OSAndArch()
		return OperatingSystemXT()

func @IsWindows() # Redefines the behaviour of Ring isWindows() returning 32-bit only
	if OperatingSystem() = "windows"
		return TRUE
	else
		return FALSE
	ok

	func StzIsWindows()
		return @IsWindows()

func IsWindows32()
	if @IsWindows() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

func IsWindows64()
	if @IsWindows() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

#--

func @IsMSDOS()
	if OperatingSystem() = "dos"
		return TRUE
	else
		return FALSE
	ok

	func StzIsMSDOS()
		return @IsMSDOS()

func IsMSDOS32()
	if @IsMSDOS() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsMOSDOS32()
		return IsMSDOS32()

func IsMSDOS64()
	if @IsMSDOS() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsMSDOS64()
		return IsMSDOS64()

#--

func @IsUnix()
	if OperatingSystem() = "unix"
		return TRUE
	else
		return FALSE
	ok

	func StzUnix()
		return @IsUnix()

func IsUnix32()
	if @IsUnix() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsUnix32()
		return IsUnix32()

func IsUnix64()
	if IsUnix() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsUnix64()
		return IsUnix64()


#--

func @IsLinux()
	if OperatingSystem() = "linux"
		return TRUE
	else
		return FALSE
	ok

	func StzLinux()
		return @IsLinux()

func IsLinux32()
	if @IsLinux() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsLinux32()
		return IsLinux32()

func IsLinux64()
	if @IsLinux() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsLinux64()
		return IsLinux64()


#--

func @IsFreeBSD()
	if OperatingSystem() = "freebsd"
		return TRUE
	else
		return FALSE
	ok

	func StzFreeBSD()
		return @IsFreeBSD()

func IsFreeBSD32()
	if @IsFreeBSD() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsFreeBSD32()
		return IsFreeBSD32()

func IsFreeBSD64()
	if IsFreeBSD() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsFreeBSD64()
		return IsFreeBSD64()


#==

func @IsMacOSX()
	if OperatingSystem() = "macosx"
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func StzMacOSX()
		return @IsMacOSX()

	func IsMacOS()
		return @IsMacOSX()

	func @IsMacOS()
		return @IsMacOSX()

	#>

func IsMacOSX32()
	if @IsMacOSX() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func @IsMacOSX32()
		return IsMacOSX32()

	func IsMacOS32()
		return IsMacOSX32()

	#>

func IsMacOSX64()
	if @IsMacOSX() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

	#< @FunctionAlternativeForms

	func @IsMacOSX64()
		return IsMacOSX64()

	#--

	func IsMacOS64()
		return IsMacOSX64()

	func @IsMacOS64()
		return IsMacOSX64()

	#>

#==

func @IsAndroid()
	if OperatingSystem() = "android"
		return TRUE
	else
		return FALSE
	ok

	func StzIsAndroid()
		return @IsAndroid()

func IsAndroid32()
	if @IsAndroid() and Is32Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsAndroid32()
		return IsAndroid32()
		
func IsAndroid64()
	if @IsAndroid() and Is64Bit()
		return TRUE
	else
		return FALSE
	ok

	func @IsAndroid64()
		return IsAndroid64()
