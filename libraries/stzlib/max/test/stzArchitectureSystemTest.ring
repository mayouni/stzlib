load "../stzmax.ring"

profon

? Arch()
#--> "x64"

? Is64Bit()
#--> _TRUE_

? Is32Bit()
#--> _FALSE_

? Is32Or54Bit()
#--> "64"

? IsARM()
#--> _FALSE_

? IsARM32()
#--> _FALSE_

? IsARM64()
#--> _FALSE_

? IsX86()
#--> _FALSE_

? IsX64()
#--> _TRUE_

? OperatingSystem() # Same as OS()
#--> "windows"

? OperatingSystemXT() // returns the OS and its architecture (32 or 64 bits)
#--> [ "windows", "x64" ]

? IsWindows32()
#--> _FALSE_

? IsWindows64()
#--> _TRUE_

? IsMSDOS32()
#--> _FALSE_

? IsMSDOS64()
#--> _FALSE_

? IsUnix32()
#--> _FALSE_

? IsUnix64()
#--> _FALSE_

? IsLinux32()
#--> _FALSE_

? IsLinux64()
#--> _FALSE_

? IsFreeBSD32()
#--> _FALSE_

? IsFreeBSD64()
#--> _FALSE_

? IsMacOS32()
#--> _FALSE_

? IsMacOS64()
#--> _FALSE_

? IsAndroid32()
#--> _FALSE_

? IsAndroid64()
#--> _FALSE_

proff()
# Executed in almost 0 second(s) in Ring 1.21
