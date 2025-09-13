
#TODO Move theses test samples in the relevant test files

/*---

pr()

? stzlen("softanza")
#--> 8

? stzleft("softanza", 4)
#--> soft

? stzright("softanza", 4)
#--> anza

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Ring's del(): modifies the list variable bur returns nothing

aList = [ "one", "two", "x", "three" ]
? @@( del(aList, 3) ) #--> NULL
? @@(aList) #--> [ "one", "two", "three" ]

# Softanza alternative: Modidies the list variable and returns it at the same time()
? ""
aList = [ "one", "two", "x", "three" ]
? @@( ring_del(aList, 3) ) #--> [ "one", "two", "three" ]
? @@(aList) #--> [ "one", "two", "three" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--

pr()

# Ring's default substr(): returns new string, str unchanged

str = "I love pizza"
? substr(str, "pizza", "couscous")
#--> I love pizza

? str
#--> I love pizza

# Softanza: updates and returns in one step

str = "I love pizza"
str = ring_substr2(str, "pizza", "couscous")
? str
#--> I love couscous

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- stzExtCode #todo quick-narration

pr()

# Softanza simplifies the use of substr() which has
# many forms in Ring and outside Ring (if you ar generating
# code from LLMs that are ususally influenced by pyhton and
# C syntax of substr()). You only need
# to add @ before substr() and let Softanza manage
# all the possible cases:

# Case 1 : Replacing a substring by an other

? @substr("one five three", "five", "two")
#--> one two three

# Case 2 : Finding the first occurrence of a substring
? @substr("one two three", "two", []) # [] can also be 0
#--> 5

# Case 3 : Getting a section from the string
? @substr("one two three", 6, 8)
#--> two

# Case 4 : Finding the first occurrence of a substring
# starting at a give position

? @substr("one two three two", "two", 10)
#--> 15

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*====

pr()

Q([ 1, 2, "three", 4, "five" ]) {

	? IsMadeOfNumbersOrStrings()
	#--> TRUE

	? IsMadeOfNumbersAndStrings()
	#--> TRUE
}

Q([ 1, 2, 3, 4, 5 ]) {

	? IsMadeOfNumbersOrStrings()
	#--> TRUE

	? IsMadeOfNumbersAndStrings()
	#--> FALSE

}

pf()

# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*------------ #ring #perf

pr()

? @@NL( sort([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]
], 2) )

pf()
#-->
'
[
	[ "Bob", 89 ],
	[ "Roy", 100 ],
	[ "Dan", 120 ]
]

'
# Executed in almost 0 second(s) in Ring 1.21
#--> Executed in 0.03 second(s) in Ring 1.20

/*------------

pr()

? @@NL( StzListOfListsQ([
	[ "Bob",       89 ],
	[ "Dan",      120 ],
	[ "Roy",      100 ]

]).SortedOnDown(2) )
#--> [
#	[ "Dan",      120 ],
#	[ "Roy",      100 ],
#	[ "Bob",       89 ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20

/*------------

pr()

? Min([2, 3])
#--> 2

? Max([2, 3])
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20

/*------------

pr()

CheckParamsOff()

o1 = new stzTable([

	:NAME =  [ "Bob", "Dan", "Roy" ],
	:SCORE = [ 89, 120, 100 ]

])

? o1.Shwo() 	// #NOTE this is a mispelled form of Show()
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

o1.SortOnDown(:SCORE) # Or SortOnInDescending()

? o1.Show()
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
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.10 second(s) in Ring 1.21
