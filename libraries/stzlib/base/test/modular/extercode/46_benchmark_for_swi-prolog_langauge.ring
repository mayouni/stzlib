# Narrative
# --------
# #  BENCHMARK FOR SWI-PROLOG LANGAUGE  #
#
# Extracted from stzextercodetest.ring, block #46.

load "../../../stzBase.ring"

#-------------------------------------#

pr()

plg = new stzExterCode(:Prolog)
plg.SetCode('

:- use_module(library(random)).
:- use_module(library(clpfd)).

% Fibonacci calculation (iterative using accumulator)

fib(N, Result) :-
    N =< 1,
    Result #= N.
fib(N, Result) :-
    N > 1,
    fib_iter(N, 0, 1, Result).

fib_iter(2, A, B, Result) :-
    Result #= A + B.
fib_iter(N, A, B, Result) :-
    N > 2,
    N1 is N - 1,
    C #= A + B,
    fib_iter(N1, B, C, Result).

% Matrix multiplication

matrix_multiply([], _, []).
matrix_multiply([Row|Matrix1], Matrix2, [ResultRow|ResultMatrix]) :-
    transpose(Matrix2, Matrix2T),
    row_multiply(Row, Matrix2T, ResultRow),
    matrix_multiply(Matrix1, Matrix2, ResultMatrix).

row_multiply(Row, [Col|Cols], [Sum|Rest]) :-
    dot_product(Row, Col, Sum),
    row_multiply(Row, Cols, Rest).
row_multiply(_, [], []).

dot_product([], [], 0).
dot_product([X|Xs], [Y|Ys], Sum) :-
    dot_product(Xs, Ys, Rest),
    Sum is X * Y + Rest.

% Generate random array with seed

generate_random_array(Size, Seed, Array) :-
    set_random(seed(Seed)),
    length(Array, Size),
    maplist(random(0, 10000), Array).

% Generate random matrix with seed

generate_random_matrix(Size, Seed, Matrix) :-
    set_random(seed(Seed)),
    length(Matrix, Size),
    maplist(generate_matrix_row(Size), Matrix).

generate_matrix_row(Size, Row) :-
    length(Row, Size),
    maplist(random(0, 100), Row).

% Main benchmark predicate

run_benchmarks(Result) :-
    % 1. Fibonacci Benchmark
    statistics(runtime, [StartFib|_]),
    fib(450, FibResult),
    statistics(runtime, [EndFib|_]),
    FibTime is (EndFib - StartFib),

    % 2. Sorting Benchmark

    % Note: Using SWI-Prolog built-in sort/2 instead of manual quicksort.
    % Rationale: The manual quicksort implementation caused stack overflow
    % for a 1,000,000-element list due to deep recursion and list copying.
    % sort/2 is optimized internally (typically a merge sort variation),
    % leveraging Prolog strengths and avoiding stack issues, though it
    % deviates from the battle usual requirement of manual quicksort.
    % This choice aligns with R and Julia use of built-in sort functions
    % for practicality in their respective benchmarks.

    generate_random_array(1000000, 42, Array),
    statistics(runtime, [StartSort|_]),
    sort(Array, _SortedArray),
    statistics(runtime, [EndSort|_]),
    SortTime is (EndSort - StartSort),

    % 3. Matrix Multiplication Benchmark
    generate_random_matrix(250, 42, Matrix1),
    generate_random_matrix(250, 42, Matrix2),
    statistics(runtime, [StartMatrix|_]),
    matrix_multiply(Matrix1, Matrix2, _ResultMatrix),
    statistics(runtime, [EndMatrix|_]),
    MatrixTime is (EndMatrix - StartMatrix),

    % Format results

    Result = [
        [fibonacci, [[n, 450], [result, FibResult], [time_ms, FibTime]]],
        [sorting, [[array_size, 1000000], [time_ms, SortTime]]],
        [matrix, [[matrix_size, 250], [time_ms, MatrixTime]]]
    ].

% Define result
res(Result) :- run_benchmarks(Result).

')

plg.Run()
? @@( plg.Result() )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", 4953967011875066910547013330669507468549271950815257134688446476787412478855327157343790039040.00 ], [ "time_ms", 0 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 110 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 4250 ] ]
#	]
# ]

pf()
# Executed in 5.99 second(s) in Ring 1.23
