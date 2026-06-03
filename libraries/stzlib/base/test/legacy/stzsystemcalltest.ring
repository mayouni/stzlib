load "../stzbase.ring"


#NOTE All file operations run in systest/ folder (safe sandbox)
# To clean up: manually delete systest/ contents when needed

/*----- SETUP: Create test files in systest/

pr()

# Ensure systest exists
if NOT isdir("systest")
	QMkdir("systest")
ok

# Create test files
write("systest/source.txt", "Hello from source file")
write("systest/data.txt", "Sample data for testing")
write("systest/test.txt", "Test content")

? "✓ Test files created in systest/"

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----- TEST 1: Basic command execution

pr()

oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "echo", "Hello World"])
oCall.Run()

? "Output: " + oCall.Output()
? "Exit code: " + oCall.ExitCode()
? "Success: " + oCall.Succeeded()

#--> Output: Hello World #TODO #ERR see why it returned \"Hello World\"
#    Exit code: 0
#    Success: 1

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*----- TEST 2: File operations with parameters

pr()

oCall = new stzSystemCall(Sys(:CopyFile))
oCall.SetParam(:source, "systest/source.txt")
oCall.SetParam(:dest, "systest/backup.txt")
oCall.Run()

if oCall.Succeeded()
	? "✓ File copied successfully"
	? "  Check: " + fexists("systest/backup.txt")
else
	? "✗ Copy failed: " + oCall.Error()
ok

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*----- TEST 3: Multiple parameters

pr()

oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "type", "{file}", "&", "echo.", "&", "type", "{file2}"])
oCall.SetParam(:file, "systest\source.txt")
oCall.SetParam(:file2, "systest\data.txt")
oCall.Run()

# Combined output
? oCall.Output()
#-->
'
Hello from source file 
Sample data for testing
'

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*----- TEST 4: Auto-typed return from Sys()

pr()

# Sys() returns string with @RETURN:list suffix
# stzSystemCall auto-detects and converts

o1 = new stzSystemCall(Sys(:ListFiles))
o1.Run()

# Files in systest/ (auto-converted to list)
acFiles = o1.Output()
? type(acFiles)
#--> LIST

? ShowShortNL( acFiles)
#-->
'
[
	"banking_corporate.stzstyl", 
	"bank_structure.stzorg", 
	"bigtext.txt", 
	"...", 
	"test_diagram.mmd", 
	"test_diagram.stzdiag", 
	"txtfiles"
]
'

pf()
# Executed in 0.12 second(s) in Ring 1.24

/*----- TEST 5: Error handling

pr()

o1 = StzSystemCallQ("cmd.exe")
o1.WithArgs(["/c", "type", "systest/nonexistent.txt"])
o1.Run()

if o1.Failed()
	? "✓ Correctly detected failure"
	? "  Exit code: " + o1.ExitCode()
	? "  Error: " + o1.Error()
ok

#-->
'
✓ Correctly detected failure
  Exit code: 1
  Error: The command syntax is incorrect.
'

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*----- TEST 6: Success/failure checks

pr()

# Successful command
oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "echo", "test"])
oCall.Run()
? "Command 1 succeeded: " + oCall.Succeeded()

# Failed command
oCall.Reset()
oCall.SetArgs(["/c", "type", "badfile.txt"])
oCall.Run()
? "Command 2 failed: " + oCall.Failed()

#-->
'
Command 1 succeeded: 1
Command 2 failed: 1
'

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*----- TEST 7: Output capture control

pr()

# Capture only errors
o1 = StzSystemCallQ("cmd.exe")
o1 {
	WithArgs(["/c", "type", "systest/nonexistent.txt"])

	DontCaptureOutput()
	CaptureError()

	Run()
}

? o1.HasOutput()
#--> FALSE

? o1.HasError()
#--> TRUE

? o1.Error()
#--> The command syntax is incorrect.

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*----- TEST 8: Silent execution

pr()

# This command will run silently : no output returned

StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "echo", "This runs silently"]).
	RunSilently()

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*----- TEST 9: Reuse object for multiple commands

pr()


oCall = new stzSystemCall("cmd.exe")

# First command
oCall.SetArgs(["/c", "echo", "First"])
oCall.Run()
? oCall.Output()
#--> "First"

# Reset and second command
oCall.Reset()
oCall.SetArgs(["/c", "echo", "Second"])
oCall.Run()
? oCall.Output()
#--> "Second"

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*----- TEST 10: Step-by-step building

pr()

oCall = new stzSystemCall("cmd.exe")
oCall {
	AddArg("/c")
	AddArg("echo")
	AddArg("Step")
	AddArg("by")
	AddArg("step")

	HideConsole()
	Run()

	? Output()
}
#--> Step by step

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*----- TEST 11: Timeout handling

pr()

o1 = new stzSystemCall("cmd.exe")
o1.WithArgs(["/c", "ping", "localhost", "-n", "2"])
o1.SetTimeout(5000)  # 5 seconds
o1.Run()

? o1.Timeout()
#--> 5000

? o1.WasExecuted()
#2--> TRUE

? o1.Output()
#-->
'
Sending a ‘ping’ request to DESKTOP-CICEMOO [::1] with 32 bytes of data:
Reply from ::1: time <1ms
Reply from ::1: time <1ms

Ping statistics for ::1:
    Packets: Sent = 2, Received = 2, Lost = 0 (0% loss),
Approximate round-trip times in milliseconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
'

pf()
# Executed in 1.07 second(s) in Ring 1.24

/*----- TEST 12: File operations in systest/

pr()

# Create directory
o1 = new stzSystemCall(Sys(:MakeDir))
o1 {
	SetParam(:path, "systest/newdir")
	Run()
	? "✓ Directory created: " + isdir("systest/newdir")

	# List files
	Reset()
	SetProgram("cmd.exe")
	SetArgs(["/c", "dir", "/B", "systest"])
	Run()

	? NL + "Files in systest/:"
	? Output()
	#-->
	'
	backup.txt
	data.txt
	newdir
	source.txt
	test.txt
	'
}

# Move file "data.txt" from systest folder to newdir subfolder
o2 = new stzSystemCall(Sys(:MoveFile))
o2 {
	SetParam(:source, "systest/data.txt")
	SetParam(:dest, "systest/newdir/moved.txt")
	Run()
	? "✓ File moved: " + fexists("systest/newdir/moved.txt")
	#--> ✓ File moved: TRUE

}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*---

pr()

o1 = new stzSystemCall("cmd.exe")
o1 {
	SetArgs(["/c", "dir", "/B", "{path}"])
	SetParam(:path, "systest")
	Run()

	# Files in systest

	? Output()
	#-->
	'
	backup.txt
	file1_copy.txt
	file2.txt
	file3.txt
	newdir
	output.txt
	source.txt
	test.txt
	'

}

pf()
# Executed in 0.04 second(s) in Ring 1.24


/*----- TEST 13: Legacy function compatibility

pr()

# Using stzsystemXT()
cOutput = stzsystemXT("cmd.exe", ["/c", "echo", "Legacy call"])
? "stzsystem(): " + cOutput

# Using stzsystemSilent()
stzsystemSilentXT("cmd.exe", ["/c", "echo", "Silent legacy"])
? "✓ stzsystemSilent() executed (no output)"

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*----- TEST 14: Open file with default app

pr()

# Create a test file
write("systest/output.txt", "This file will be opened")

? "Opening systest/output.txt..."
StzSystemCallQ('').OpenFile("systest/output.txt")
? "✓ File opened with default application"

pf()
# Executed in 0.18 second(s) in Ring 1.24

/*----- TEST 15: Working with Sys() commands

pr()

# Get current directory
oCall = new stzSystemCall(Sys(:CurrentDir))
oCall.Run()
? oCall.Output()
#-->
'D:\GitHub\stzlib\libraries\stzlib\base\test'

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*--

pr()

# Find files
oCall = new stzSystemCall(Sys(:FindFiles)) 
oCall.SetParam(:pattern, "*.txt")
oCall.Run()

# Text files found:
? ShowShortNL( oCall.Output() ) # when we use Sys() the type oof output is automatic
#-->
'
[
	"D:\GitHub\stzlib\libraries\stzlib\base\test\bigtext.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\config.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\log.txt", 
	"...", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\systest\newdir\moved.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\txtfiles\test.txt", 
	"D:\GitHub\stzlib\libraries\stzlib\base\test\txtfiles\test_output.txt"
]
'

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*--

pr()

# System info (truncated)
oCall = new stzSystemCall(Sys(:SystemInfo))
oCall.Run()
cInfo = oCall.Output()

# System info (first 200 chars):
? left(cInfo, 200) + "..."
#-->
'
Host Name:                             DESKTOP-CICEMOO  
Operating System Name:                 Microsoft Windows 11 Professional  
Operating System Version:              10.0.26...
'

pf()
# Executed in 3.82 second(s) in Ring 1.24

/*----- TEST 16: Error states

pr()

oCall = new stzSystemCall("cmd.exe")

# Command with error
oCall.SetArgs(["/c", "type", "nonexistent.txt"])
oCall.Run()

? oCall.Failed()
#--> TRUE

? oCall.ExitCode()
#--> 1 (Means failure in commandline standard)

? oCall.HasError()
#--> TRUE

# Reset and successful command
oCall.Reset()
oCall.SetArgs(["/c", "echo", "OK"])
oCall.Run()

? NL + "After reset:"

? oCall.Succeeded()
#--> TRUE

? oCall.ExitCode()
#--> 0 (Means successin command line standard)

? oCall.Output()
#--> OK

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*----- TEST 17: Chaining with Q methods

pr()

oCall = StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "echo", "Chained"]).
	SetTimeoutQ(3000).
	HideConsoleQ().
	RunQ()

? oCall.Output() #--> "Chained"

? oCall.Timeout() #--> 3000

pf()
#--> Executed in 0.04 second(s) in Ring 1.24

/*----- TEST 18: Complex file operations
*/
pr()

# Create multiple files
for i = 1 to 3
	write("systest/file" + i + ".txt", "Content " + i)
next
? "✓ Created 3 test files"

# Find them
oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "dir", "/B", "systest/file*.txt"])
oCall.Run()
? NL + "Files found:"
? oCall.Output() + NL

# Copy one
oCall = new stzSystemCall(Sys(:CopyFile))
oCall.SetParam(:source, "systest/file1.txt")
oCall.SetParam(:dest, "systest/file1_copy.txt")
oCall.Run()
? "✓ Copied file1.txt"

# Delete original
oCall = new stzSystemCall(Sys(:DeleteFile))
oCall.SetParam(:file, "systest/file1.txt")
oCall.Run()
? "✓ Deleted original"

# Verify
? "file1.txt exists: " + fexists("systest/file1.txt")
? "file1_copy.txt exists: " + fexists("systest/file1_copy.txt")

#-->
'
✓ Created 3 test files

Files found:

✓ Copied file1.txt
✓ Deleted original
file1.txt exists: 0
file1_copy.txt exists: 1
'

pf()
# Executed in 0.09 second(s) in Ring 1.24
