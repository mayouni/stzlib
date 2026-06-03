# Narrative
# --------
# TEST 12: File operations in systest/
#
# Extracted from stzsystemcalltest.ring, block #13.

load "../../stzBase.ring"


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
