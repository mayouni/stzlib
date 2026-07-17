# Narrative
# --------
# Graph Traversal
#
# Extracted from stzextercodetest.ring, block #29.
#ERR needs SWI-Prolog INSTALLED -- runprolog.bat points at
#    d:/prolog/swipl-9.9.9/bin/swipl.exe, which is absent here, so the run
#    dies at "Result file 'plresult.txt' not created". The RING side is green:
#    PrepareSourceCode() builds the driver and names the right predicate.
#    (It used to die before that, on R24 'cmainpredicate' -- fixed.)

load "../../stzBase.ring"


pr()

# All paths from a to e in a graph

oProlog = new stzExterCode(:Prolog)
oProlog.SetCode('

	% Define a simple graph

	edge(a, b).
	edge(a, c).
	edge(b, d).
	edge(c, d).
	edge(d, e).
	
	% Define path finding

	path(X, X, [X]).
	path(X, Y, [X|Path]) :-
	    edge(X, Z),
	    path(Z, Y, Path).
	
	% Find all paths from a to e

	find_paths(Result) :-
	    findall(
	        Path,
	        path(a, e, Path),
	        Paths
	    ),
	    Result = Paths.
	
	% Define result

	res(Result) :- find_paths(Result).
')

oProlog.Run()

? @@( oProlog.Result() )
#--> [ [ "a", "b", "d", "e" ], [ "a", "c", "d", "e" ] ]

pf()
# Executed in 0.21 second(s) in Ring 1.22
