load "../stzbase.ring"

/*==== #narration SQL SUPPORT IN SOFTANZA EXTERNAL CODE
*/
pr()

# SQL code to create a table with three columns

'
	CREATE TABLE persons (
		id	SMALLINT,
		name	VARCHAR(30),
		score	SMALLINT,
	);
'

# The Softanza code for creating the same table inside a stzTable object

	@CREATE_TABLE( :persons ) {

		@([

		:id    = SMALLINT, 	// #TODO // SQL datatypes are not supported yet
		:name  = VARCHAR(30),
		:score = SMALLINT

		])

	};

	# At this level, and in the background, Softanza creates a named stzTable
	# oject we can call using the small function v() and check its structure:

	v(:persons).Show() + NL
	#-->
	'
	╭────┬──────┬───────╮
	│ Id │ Name │ Score │
	├────┼──────┼───────┤
	│    │      │       │
	╰────┴──────┴───────╯
	'

# SQL code to insert data into the table

'
	INSERT INTO persons ( id, name, score )

	VALUES 	( 1, "Bob",  89 );
		( 2, "Dan", 120 );
		( 3, "Tim",  56 );
'
# Ring code to insert data into the person stzTable object

	@INSERT_INTO( :persons, [ :id, :name, :score ] )

	@VALUES([
		[ 1, 'Bob',  89 ],
		[ 2, 'Dan', 120 ],
		[ 3, 'Tim',  56 ]
	]);

	# Let's check the stzTable object again

	? v(:persons).Show()
	#-->
	'
	╭────┬──────┬───────╮
	│ Id │ Name │ Score │
	├────┼──────┼───────┤
	│  1 │ Bob  │    89 │
	│  2 │ Dan  │   120 │
	│  3 │ Tim  │    56 │
	╰────┴──────┴───────╯
	'

	# Let's add more rows

	@VALUES([
		[ 4, 'Roy', 100 ],
		[ 5, 'Sam', 78 ]
	])

	? v(:persons).Show()
	#--> 
	'
	╭────┬──────┬───────╮
	│ Id │ Name │ Score │
	├────┼──────┼───────┤
	│  1 │ Bob  │    89 │
	│  2 │ Dan  │   120 │
	│  3 │ Tim  │    56 │
	│  4 │ Roy  │   100 │
	│  5 │ Sam  │    78 │
	╰────┴──────┴───────╯
	'

# SQL code to select data from the table in a query called sql

'
	WITH sql AS (

	SELECT name, score
	FROM persons
	WHERE score > 99

	)
'

# The same thing written in Ring code, where sql is a named variable
# containing the list of data returned by the query

	@WITH(:sql).AS([

	@SELECT([ :name, :score ]),
	@FROM( :persons ),
	@WHERE( 'score > 80' ) // #TODO // check WHERE_( 'name = "Dan"' );

	])

	? v(:sql) # Or you can say ? v(:sqlData)
	#--> [
	# 	[ "Bob",  89 ],
	# 	[ "Dan", 120 ],
	# 	[ "Roy", 100 ]
	# ]

	# To get the stzTable object you can say:

	? v(:sqlTable).Show() # Or ? v(:sqlObject)
	#-->
	'
	╭──────┬───────╮
	│ Name │ Score │
	├──────┼───────┤
	│ Bob  │    89 │
	│ Dan  │   120 │
	│ Roy  │   100 │
	╰──────┴───────╯
	'

# SQL code to sort the table by score (on the column score of the stzTable object)

'
	WITH sql AS (

	SELECT * FROM persons
	ORDER BY Name DESC; # or ASC

	)
'

# In Ring with Softanza

	@WITH(:sql).AS([

	@SELECT('*'), @FROM(:persons),
	@ORDER_BY(:SCORE, :DESC)

	])

	? v(:sqlTable).Show()
	#-->
	'
	╭──────┬───────╮
	│ Name │ Score │
	├──────┼───────┤
	│ Dan  │   120 │
	│ Roy  │   100 │
	│ Bob  │    89 │
	╰──────┴───────╯
	'

pf()
# Executed in 0.22 second(s) in Ring 1.23
# Executed in 0.32 second(s) in Ring 1.21
# Executed in 2.07 second(s) in Ring 1.20
