# Narrative
# --------
# List of factorials in Prolog
#
# Extracted from stzextercodetest.ring, block #27.

load "../../stzBase.ring"


pr()

oProlog = new stzExterCode(:Prolog)

oProlog.SetCode('
% Compute factorial
factorial(0, 1).
factorial(N, F) :-
    N > 0,
    N1 is N - 1,
    factorial(N1, F1),
    F is N * F1.

% Create a list with factorials from 1 to 10
get_factorials(Result) :-
    findall(
        N-Fact,
        (between(1, 10, N), factorial(N, Fact)),
        Result
    ).
')

oProlog.Run()
? @@(oProlog.Result())
#--> [
#	[ 1, 1 ],
#	[ 2, 2 ],
#	[ 3, 6 ],
#	[ 4, 24 ],
#	[ 5, 120 ],
#	[ 6, 720 ],
#	[ 7, 5040 ],
#	[ 8, 40320 ],
#	[ 9, 362880 ],
#	[ 10, 3628800 ]
# ]

pf()
# Executed in 0.20 second(s) in Ring 1.22
