# Narrative
# --------
# pr()
#
# Extracted from stzsystemcalltest.ring, block #14.

load "../../stzBase.ring"

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
