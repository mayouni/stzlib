load "../max/systems/stzarchsys.ring"
load "../max/systems/stzprofsys.ring"

pron()

? Arch()
#--> "x64"

? Is64Bit()
#--> TRUE

? Is32Bit()
#--> FALSE

? Is32Or54Bit()
#--> "64"

? IsARM()
#--> FALSE

? IsARM32()
#--> FALSE

? IsARM64()
#--> FALSE

? IsX86()
#--> FALSE

? IsX64()
#--> TRUE

? OperatingSystem() # Same as OS()
#--> "windows"

? OperatingSystemXT() // returns the OS and its architecture (32 or 64 bits)
#--> [ "windows", "x64" ]

? IsWindows32()
#--> FALSE

? IsWindows64()
#--> TRUE

? IsMSDOS32()
#--> FALSE

? IsMSDOS64()
#--> FALSE

? IsUnix32()
#--> FALSE

? IsUnix64()
#--> FALSE

? IsLinux32()
#--> FALSE

? IsLinux64()
#--> FALSE

? IsFreeBSD32()
#--> FALSE

? IsFreeBSD64()
#--> FALSE

? IsMacOS32()
#--> FALSE

? IsMacOS64()
#--> FALSE

? IsAndroid32()
#--> FALSE

? IsAndroid64()
#--> FALSE

proff()
# Executed in almost 0 second(s).
