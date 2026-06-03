# Narrative
# --------
# Simple List Processing
#
# Extracted from stzextercodetest.ring, block #26.

load "../../stzBase.ring"


pr()

oProlog = new stzExterCode(:prolog)

oProlog.SetCode('
% Define a predicate to add 10 to each element
add_ten([], []).
add_ten([H|T], [H10|T10]) :-
    H10 is H + 10,
    add_ten(T, T10).

% Main computation predicate that main/0 will call
compute_result(Result) :-
    InputList = [1, 2, 3, 4, 5],
    add_ten(InputList, TransformedList),
    Result = [input_list-InputList, transformed_list-TransformedList].
')

oProlog.Run()

? @@( oProlog.Result() )
#--> [
#     [ "input_list", [ 1, 2, 3, 4, 5 ] ],
#     [ "transformed_list", [ 11, 12, 13, 14, 15 ] ]
# ]

pf()
# Executed in 0.32 second(s) in Ring 1.22
