# Narrative
# --------
# Creating Multiple Folders
#
# Extracted from stzfoldertest.ring, block #9.
#ERR Error (R3) : Calling Function without definition: createfolders

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\TestArea")
o1 {

    aCreated = CreateFolders([ "Docs", "Images", "Videos", "Music" ])
    
    _nCreated1Len_ = ring_len(aCreated)
    for _iLoopCreated1_ = 1 to _nCreated1Len_
    	oFolder = aCreated[_iLoopCreated1_]
        ? oFolder.Name()
    next
    #--> Docs
    #    Images
    #    Videos
    #    Music
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
