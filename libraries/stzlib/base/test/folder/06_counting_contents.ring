# Narrative
# --------
# Counting Contents
#
# Extracted from stzfoldertest.ring, block #6.
#ERR exit 1: 36

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Program Files")
o1 {

	# Counting files and forlders at the current level

    ? Count() # Or CountFilesAndFolders()
    #--> 42
    
    ? CountFiles()
    #--> 1
    
    ? CountFolders() + NL # Or CountDirs()
    #--> 41

	# Counting files and folders indepth/recursively

	? DeepCount()
	#--> 16309

	? DeepCountFiles()
	#--> 14392

	? DeepCountFolders()
	#--> 1917

}

pf()
# Executed in 0.74 second(s) in Ring 1.22
