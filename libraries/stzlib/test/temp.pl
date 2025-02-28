
:- use_module(library(http/json)).

% Main function to transform Prolog term to Ring format and save to file
transform_to_ring(Term, Filename) :-
    transform(Term, ResultStr),
    open(Filename, write, Stream),
    write(Stream, ResultStr),
    close(Stream).

% Transform an atom or string
transform(Term, Result) :-
    (atom(Term) ; string(Term)),
    !,
    format(atom(Result), "\'~w\'", [Term]).

% Transform a number, handling scientific notation
transform(Term, Result) :-
    number(Term),
    !,
    format(atom(StrVal), "~w", [Term]),
    (   sub_atom(StrVal, _, _, _, e) 
    ->  format(atom(Result), "\'~w\'", [Term])
    ;   Result = StrVal
    ).

% Transform boolean true value
transform(true, "TRUE") :- !.

% Transform boolean false value
transform(false, "FALSE") :- !.

% Transform a list
transform(List, Result) :-
    is_list(List),
    !,
    transform_list(List, Result).

% Transform a compound term
transform(Term, Result) :-
    compound(Term),
    !,
    Term =.. [Functor|Args],
    transform_compound(Functor, Args, Result).

% Default case for variables or other terms
transform(_, "NULL").

% Transform a list into a flat string
transform_list(List, Result) :-
    transform_list_items(List, Items),
    format(atom(Result), "[~w]", [Items]).

% Transform list items into a comma-separated string
transform_list_items([], "").
transform_list_items([H], Result) :-
    transform(H, HResult),
    format(atom(Result), "~w", [HResult]).
transform_list_items([H|T], Result) :-
    transform(H, HResult),
    transform_list_items(T, TResult),
    (   TResult = "" -> format(atom(Result), "~w", [HResult])
    ;   format(atom(Result), "~w, ~w", [HResult, TResult])
    ).

% Handle key-value pairs (Term = Key-Value), including numeric keys
transform_compound(-, [Key, Value], Result) :-
    transform(Key, KeyResult),
    transform(Value, ValueResult),
    format(atom(Result), "[~w, ~w]", [KeyResult, ValueResult]).

% Default handling for other compound terms
transform_compound(_, Args, Result) :-
    transform_list(Args, Result).


:- use_module(library(lists)).
:- use_module(library(apply)).



    % Solve the N-Queens problem
    queens(N, Queens) :-
        length(Queens, N),
        queens_domain(Queens, N),
        safe_queens(Queens).

    queens_domain([], _).
    queens_domain([Q|Queens], N) :-
        between(1, N, Q),  % Using between/3 instead of domain/3
        queens_domain(Queens, N).

    safe_queens([]).
    safe_queens([Q|Queens]) :-
        safe_queens(Queens, Q, 1),
        safe_queens(Queens).

    safe_queens([], _, _).
    safe_queens([Q|Queens], Q0, D0) :-
        Q =\= Q0,           % Different row
        Q =\= Q0 + D0,      % Different diagonal
        Q =\= Q0 - D0,      % Different diagonal
        D1 is D0 + 1,
        safe_queens(Queens, Q0, D1).

    % Find solutions to the 4-Queens problem
    solve_queens(Result) :-
        findall(
            Solution,
            queens(4, Solution),
            Solutions
        ),
        Result = Solutions.

    % Define result
    res(Result) :- solve_queens(Result).



% Main predicate called by the runtime
main :-
    writeln("SWI-Prolog program starting..."),
    res(Result),
    writeln("Transforming result..."),
    transform_to_ring(Result, "plresult.txt"),
    writeln("Data written to file").
