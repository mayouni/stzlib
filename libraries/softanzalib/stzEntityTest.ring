load "stzlib.ring"

/*---------------

# If type is provided NULL then it is atotmatically set to "undefined"

o1 = new stzEntity([ :name = "Avionav", :type = "" ])
? o1.content()

/*---------------

# You must provide a name proprty while creating an entity

StzEntityQ([ :type = "Company", :domain = "Technology" ])
# --> ERROR: Can't create the entity object!

/*---------------
*/
# If :type is not provided, then it is automatically
# added and set to :undefined

o1 = new stzEntity([ :Name = "Tahar", :Company = "COALA" ])

? o1.Name() #--> "Tahar"
? o1.Type() #--> :Undefined
? "--"
? o1.Properties() # Or if you want o1.Props()
#--> [ :name, :type, :company ]
? o1.Values()
#--> [ "Tahar", "undefined", "COALA" ]

/*---------------

# names and types must be valid words!
# otherwide Softanza will raise an error:

StzEntityQ([ :name = "", :type = "Company", :domain = "Technology" ])
StzEntityQ([ :name = "*__!", :type = "Company", :domain = "Technology" ])
? StzEntityQ([ :name = "Sun", :type = "*__!" ]).Content()

/*---------------

# Note that if your provide properties in uppercase,
# they are automatically lowercased

? StzEntityQ([ ["NAME" , "Apple"], [ "TYPE", "Company" ] ]).Content()
# --> [ ["name" , "Apple"], [ "type", "Company" ] ]

# which is equivalent to the usual form we use for hashlist:
# -> [ :name = "Apple", :type = "Company" ]


