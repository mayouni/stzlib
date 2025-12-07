load "../stzbase.ring"

#==================================#
#   SANDBOX SAFETY DEMONSTRATION   #
#==================================#

# By default, ALL system calls execute in an isolated sandbox (./systest/).
# This prevents accidental damage to your real filesystem.

# How it works:
# 1. Creates temporary workspace: ./systest/ws_<timestamp>/
# 2. Copies referenced files into workspace
# 3. Executes command ONLY in workspace
# 4. Shows you what changed
# 5. Asks approval before applying to real system
# 6. Cleans up workspace

# Try these examples to see it in action:
# =======================================

/*-- EXAMPLE 1: See sandbox in action with file copy
*/
pr()


# Watch how the sandbox protects your filesystem...

Sy = new stzSystemCall(Sys(:CopyFile)) # Sys() or SysCmdData()
Sy {

    # This will execute in ./systest/ws_xxx/, NOT in current directory
    SetParam(:source, "txtfiles/test.txt")
    SetParam(:dest, "txtfiles/backup.txt")
    Run()
    
    # After execution, you'll see:
    # - Files created: backup.txt
    # - Prompt: "Apply to real system? (y/n/i)"
    # - Choose 'i' to inspect workspace before deciding

    # y = Apply changes to your real files
    # n = Discard (delete workspace)
    # i = Open the workspace folder in File Explorer so
    # you can manually examine what the command created/modified before deciding

}

pf()

/*-- EXAMPLE 2: Dangerous command made safe

pr()

? "=== SANDBOX DEMO: Directory Removal ==="

Sy = new stzSystemCall(:RemoveDir)
Sy {
    SetParam(:path, "important_folder")
    Run()
    
    # The folder is removed ONLY in sandbox
    # You can inspect and reject if it's wrong
    # No real damage until you approve with 'y'
}

pf()

/*-- EXAMPLE 3: Auto-approve for safe commands (CI/CD)

pr()

? "=== AUTO-APPROVE MODE ==="

Sy = new stzSystemCall(:ListFiles)
Sy {
    SetAutoApprove(TRUE)  # Skip approval prompt
    Run()
    ? Output()
}

pf()

/*-- EXAMPLE 4: Production mode (disable sandbox)

pr()

? "=== PRODUCTION MODE (DANGEROUS!) ==="

Sy = new stzSystemCall(:MakeDir)
Sy {
    SetParam(:path, "real_folder")
    Run()
}

pf()

/*-- EXAMPLE 5: Inspect workspace before deciding

pr()

Sy = new stzSystemCall(:CopyFile)
Sy {
    SetParam(:source, "data.txt")
    SetParam(:dest, "backup.txt")
    Run()
    
    # When prompted, type 'i' to open File Explorer
    # Examine the workspace, then decide y/n
}

pf()

#==============#
#  OTHE TESTS  #
#==============#

/*-- Quick command with output

/*-- INTENT 1: Quick command with output

pr()

oCall = new stzSystemCall("cmd.exe")
oCall.SetArgs(["/c", "echo", "Hello World"])
oCall.Run()

? oCall.Output()
#--> Hello World

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*-- INTENT 2: Fluent one-liner

pr()

? StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "dir", "/B"]).
	RunAndGetOutput()

#--> (file listing)

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*-- INTENT 3: Check success/failure

pr()

oCall = StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "dir", "nonexistent"]).
	RunQ()

if oCall.Failed()
	? "Command failed!"
	? "Exit code: " + oCall.ExitCode()
	? "Error: " + oCall.Error()
ok
#-->
`
Command failed!
Exit code: 1
Error: File not found
`

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*-- INTENT 4: Build command step by step

pr()

oCall = new stzSystemCall("cmd.exe")
oCall {
	AddArg("/c")
	AddArg("echo")
	AddArg("Step by step")
	HideConsole()
	Run()

	? Output()
	#--> "Step by step"
}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*-- INTENT 5: Reuse same object for multiple commands

pr()

StzSystemCallQ("cmd.exe") {
	# First command

	SetArgs(["/c", "echo", "First"])
	Run()

	? "1: " + Output()

	# Reset and run second command

	Reset()
	SetArgs(["/c", "echo", "Second"])
	Run()

	? "2: " + Output()
}
#--> #ERR Output() returns nothing!
`
1: First

2: Second
`

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*-- INTENT 6: Open file with default application

pr()

# Create a test file
write("txtfiles/test_output.txt", "This is a test file")

# Open it
StzSystemCallQ("").
OpenFile("txtfiles\test_output.txt")
# File opened with default application

pf()
# Executed in 0.20 second(s) in Ring 1.24

/*-- INTENT 7: Silent execution (no output capture)

pr()

StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "echo", "You won't see this"]).
	RunSilently()

? "Command executed silently"
#-->
`
Command executed silently
`

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*-- INTENT 8: Graphviz DOT rendering

pr()

cDotCode = '
digraph Test {
	A -> B;
	B -> C;
}
'

# Write DOT file
write("temp/test.dot", cDotCode)

# Render to PNG
oCall = StzSystemCallQ("d:/graphviz/bin/dot.exe")
oCall {
	WithArgs(["-Tpng", "temp/test.dot", "-o", "output/graph.png"])
	WithTimeout(5000)
	Silent()
	Run()

	if Succeeded()
		? "Graph generated successfully!"
		? "Opening..."
		OpenFile("output/graph.png")
	else
		? "Failed: " + oCall.Error()
	ok
}
#--> #ERR same error as sample above, although the graph is correctly created
`
Graph generated successfully!
Opening...
`

pf()
# Executed in 0.47 second(s) in Ring 1.24

/*-- INTENT 9: Conditional output capture

pr()

# Capture only errors
oCall = StzSystemCallQ("cmd.exe").
	WithArgsQ(["/c", "dir", "badpath"]).
	DontCaptureOutputQ().
	CaptureErrorQ().
	RunQ()

if oCall.HasError()
	? "Error occurred: " + oCall.Error()
ok
#-->
`
Error occurred: File not found
`

pf()
# Executed in 0.04 second(s) in Ring 1.24

/*-- INTENT 10: Legacy function compatibility

pr()

# Using old stzsystem() function (still works)
cOutput = stzsystem("cmd.exe", ["/c", "echo", "Legacy call"])
? cOutput
#--> "Legacy call"

# Using old stzsystemSilent() function
stzsystemSilent("cmd.exe", ["/c", "echo", "Silent legacy"])
#--> Nothing (silent)

pf()
# Executed in 0.08 second(s) in Ring 1.24

/*-- Test sandbox with auto-approve for CI

pr()

StzSystemCallQ("cmd.exe") {
	SetAutoApprove(TRUE)  # Skip approval for automated tests
	SetArgs(["/c", "echo", "Test"])
	Run()
	? Output()
}

pf()

/*-- Test with manual approval
pr()

Sy = new stzSystemCall(:CopyFile)
Sy {
	SetParam(:source, "test.txt")
	SetParam(:dest, "backup.txt")
	Run()  # Will ask for approval
}

pf()

/*-- Disable sandbox for production
pr()

Sy = new stzSystemCall(:MakeDir)
Sy {
	SetParam(:path, "real_folder")
	Run()
}

pf()
