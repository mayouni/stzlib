# Narrative
# --------
# Family Relationships Database ERR
#
# Extracted from stzextercodetest.ring, block #30.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oProlog = new stzExterCode(:Prolog)
oProlog.SetCode('

	% Define family relationships

	parent(john, bob).
	parent(john, lisa).
	parent(mary, bob).
	parent(mary, lisa).
	parent(bob, ann).
	parent(bob, mike).
	parent(lisa, carol).
	
	% Define gender

	male(john).
	male(bob).
	male(mike).
	female(mary).
	female(lisa).
	female(ann).
	female(carol).
	
	% Define rules

	father(X, Y) :- parent(X, Y), male(X).
	mother(X, Y) :- parent(X, Y), female(X).
	grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
	sibling(X, Y) :- parent(P, X), parent(P, Y), X \= Y.
	
	% Query the family tree

	query_family(Result) :-

	    findall([father, Child], father(john, Child), Fathers),
	    findall([mother, Child], mother(mary, Child), Mothers),
	    findall([grandparent, Child], grandparent(john, Child), GrandChildren),
	    findall([sibling, Sib], sibling(bob, Sib), Siblings),

	    Result = [
		fathers-Fathers,
		mothers-Mothers,
		grandchildren-GrandChildren,
		siblings-Siblings
	    ].
	
	% Define result

	res(Result) :- query_family(Result).
')

oProlog.Run()

# Family relationships

? @@( oProlog.Result() )
#--> [
#	[
#		"fathers",
#		[ [ "father", "bob" ], [ "father", "lisa" ] ]
#	],
#	[
#		"mothers",
#		[ [ "mother", "bob" ], [ "mother", "lisa" ] ]
#	],
#	[
#		"grandchildren",
#		[ [ "grandparent", "ann" ], [ "grandparent", "mike" ], [ "grandparent", "carol" ] ]
#	],
#	[
#		"siblings",
#		[ [ "sibling", "lisa" ], [ "sibling", "lisa" ] ]
#	]
# ]

pf()
# Executed in 0.21 second(s) in Ring 1.22
