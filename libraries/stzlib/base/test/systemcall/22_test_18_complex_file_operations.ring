# Narrative
# --------
# TEST 18: Complex file operations
#
# Extracted from stzsystemcalltest.ring, block #22.

load "../../stzBase.ring"

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
