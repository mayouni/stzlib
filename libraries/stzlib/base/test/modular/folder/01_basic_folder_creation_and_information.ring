# Narrative
# --------
# Basic Folder Creation and Information
#
# Extracted from stzfoldertest.ring, block #1.

load "../../../stzBase.ring"


pr()

o1 = new stzFolder("temp")
o1 {

    ? @@NL( Info() )
    #-->
    '[
	[ "name", "temp" ],
	[ "path", "temp" ],
	[
		"absolutepath",
		"d:/github/stzlib/libraries/stzlib/base/test/temp"
	],
	[ "count", 3 ],
	[ "files", 3 ],
	[ "folders", 0 ],
	[ "isempty", 0 ],
	[ "isreadable", 1 ],
	[ "isroot", 0 ]
   ]'
    

    ? Name()
    #--> temp
    
    ? IsEmpty()
    #--> FALSE
    
    ? Count() # Or Size()
    #--> 3
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
