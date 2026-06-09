# Narrative
# --------
# GETTiNG INFORMATION ABOUT FILES
#
# Extracted from stzfiletest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

FileInfo("stzFileTest.ring") {

    ? Exists()			#--> TRUE
    ? IsWritable()		#--> TRUE
    ? SizeInBytes()		#--> 140
    ? LastModified()	#--> 18/07/2025 20:28:51
    ? IsExecutable()	#--> FALSE

}

pf()
# Executed in 0.02 second(s) in Ring 1.22
