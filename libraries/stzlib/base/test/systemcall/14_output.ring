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

# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
	? Output()
#--> backup.txt
#--> file1_copy.txt
#--> file2.txt
#--> file3.txt
#--> newdir
#--> output.txt
#--> source.txt
#--> test.txt
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
