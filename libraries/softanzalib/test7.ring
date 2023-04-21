load "stzlib.ring"

/*----------

pron()

# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
?: @@S( o1.FindXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ 6, 14 ]

proff()

/*----------
*/
pron()

# 		           8
o1 = new stzString("...<<--*-->>...")
? @@S( o1.FindXT( "*", :InBetween = [ "<<", ">>" ]) ) # or :InSubStringsBetween

proff()

/*----------

# FindXT( "*", :BoundedBy = '"' )

/*----------

# FindXT( "*", :InSection = [10 , 14 ] )

/*----------

# FindXT( "*", :Before = "--")

/*----------

# FindXT( "*", :BeforePosition = 10)

/*----------

# FindXT( "*", :After = "--")

/*----------

# FindXT( "*", :AfterPosition = 3)

/*----------

# FindXT( :3rd = "*", :Between = [ "<<", ">>" ])

/*----------

# FindXT( :3rd = "*", :BoundedBy = '"' ])

/*----------

# FindXT( :3rd = "*", :InSection = [5, 24] ])

/*----------

# FindXT( :3rd = "*", :Before = '!' ])

/*----------

# FindXT( :3rd = "*", :BeforePosition = 12 ])

/*----------

# FindXT( :3rd = "*", :After = '!' ])

/*----------

# FindXT( :3rd = "*", :AfterPosition = 12 ])

/*----------

# FindXT( :AnySubString, :Between = ["<<", ">>" )

/*----------

# FindXT( :Any, :BoundedBy = '"' )

/*----------

# FindXT( "*", :InSection = [5, 24] )
