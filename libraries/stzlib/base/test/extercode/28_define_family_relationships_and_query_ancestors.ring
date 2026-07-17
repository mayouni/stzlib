# Narrative
# --------
# Define family relationships and query ancestors
#
# Extracted from stzextercodetest.ring, block #28.
#ERR needs SWI-Prolog INSTALLED -- runprolog.bat points at
#    d:/prolog/swipl-9.9.9/bin/swipl.exe, which is absent here, so the run
#    dies at "Result file 'plresult.txt' not created". The RING side is green:
#    PrepareSourceCode() builds the driver and names the right predicate.
#    (It used to die before that, on R24 'cmainpredicate' -- fixed.)

load "../../stzBase.ring"


pr()

pl = new stzExterCode(:Prolog)

pl.SetCode('

	% Facts: parent(Child, Parent)

	parent(john, mary).
	parent(john, peter).
	parent(mary, alice).
	parent(peter, bob).
	parent(bob, eve).
	
	% Ancestor rule

	ancestor(X, Y) :-
	    parent(X, Y).
	ancestor(X, Y) :-
	    parent(X, Z),
	    ancestor(Z, Y).
	
	% Get all ancestors of "john"

	get_ancestors(Result) :-
	    findall(
	        john-Y,
	        ancestor(john, Y),
	        Result
	    ).
	
	% Main result

	res(Result) :- get_ancestors(Result).
')

pl.Run()
? @@(pl.Result())
#--> [
#	[ "john", "mary" ],
#	[ "john", "peter" ],
#	[ "john", "alice" ],
#	[ "john", "bob" ],
#	[ "john", "eve" ]
# ]

pf()
# Executed in 0.21 second(s) in Ring 1.22
