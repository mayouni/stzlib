load "../stzmax.ring"

/*-------------------

# You can't add the same entity twice in a stzListOfEntities
# An entity is defined by the pair :name/:type

# The following raises an error because the entity
# :apple/:company is add twice
o1 = new stzListOfEntities() {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Apple", :type = "Company" ])

	Show()

}

/*-------------------
*/
# While this will work
o1 = new stzListOfEntities() {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Apple", :type = "Fruit" ])

	Show()
}

# In fact, the two entities share the same name but they aresult
# not of the same type (one is the name of a company and the other
# is the name of a fruit!)

/*-------------------
*/
o1 = new stzListOfEntities() {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Microsoft", :type = "Company" ])
	AddEntity([ :name = "Google", :type = "Company" ])

	Show()

	? FindEntityByName(:microsoft)
	? ContainsEntity(:google)
}

/*-------------------
*/
o1 = new stzListOfEntities() {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Jobs", :type = "People" ])
	AddEntity([ :name = "MacOS", :type = "Technology" ])

	? NumberOfEntities() #--> 3

	? Entity(2) #--> [ :name = "Jobs", :type = "People" ]

	? Names() #--> [ "Apple", "Jobs", "MacOS" ]
	? Types() #--> [ "Company", "People", "Technology" ]
}

