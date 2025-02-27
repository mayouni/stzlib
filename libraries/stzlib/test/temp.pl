NULL
:- use_module(library(lists)).
:- use_module(library(apply)).

% Main predicate called by the runtime
main :-
    writeln("SWI-Prolog program starting..."),
    
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

% Define the main result - this will be transformed
res(Result) :- get_factorials(Result).

    writeln("Transforming result..."),
    transform_to_ring(res, _),
    writeln("Data written to file").
