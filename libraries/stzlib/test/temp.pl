
:- use_module(library(lists)).
:- use_module(library(apply)).


:- use_module(library(http/json)).

% Main function to transform Prolog term to Ring format and save to file
transform_to_ring(Term, Filename) :-
    transform(Term, ResultStr),
    open(Filename, write, Stream),
    write(Stream, ResultStr),
    close(Stream).

% Entry point for transformation, starts with depth 0
transform(Term, Result) :-
    transform_internal(Term, Result, 0).

% Transform an atom or string
transform_internal(Term, Result, _) :-
    (atom(Term) ; string(Term)),
    !,
    format(atom(Result), "\'~w\'", [Term]).

% Transform a number, handling scientific notation
transform_internal(Term, Result, _) :-
    number(Term),
    !,
    format(atom(StrVal), "~w", [Term]),
    (   sub_atom(StrVal, _, _, _, e)
    ->  format(atom(Result), "\'~w\'", [Term])
    ;   Result = StrVal
    ).

% Transform boolean values
transform_internal(true, "TRUE", _) :- !.
transform_internal(false, "FALSE", _) :- !.

% Transform a list
transform_internal(List, Result, Depth) :-
    is_list(List),
    !,
    transform_list(List, Result, Depth).

% Transform a compound term (e.g., key-value pairs)
transform_internal(Term, Result, Depth) :-
    compound(Term),
    !,
    Term =.. [Functor|Args],
    transform_compound(Functor, Args, Result, Depth).

% Default case for variables or other terms
transform_internal(_, "NULL", _).

% Transform an empty list
transform_list([], "[]", _).

% Transform a non-empty list with depth check
transform_list(List, Result, Depth) :-
    Depth < 100,
    !,
    findall(Str, (member(Elem, List), transform_internal(Elem, Str, Depth + 1)), StrList),
    atomic_list_concat(StrList, ", ", ElementsStr),
    format(atom(Result), "[~w]", [ElementsStr]).

% Handle excessive depth
transform_list(_, "TOO_DEEP", Depth) :-
    Depth >= 100.

% Handle key-value pairs (e.g., input_list-[1,2,3,4,5])
transform_compound(-, [Key, Value], Result, Depth) :-
    (atom(Key) ; string(Key)),
    !,
    transform_internal(Value, ValueResult, Depth),
    format(atom(Result), "[\'~w\', ~w]", [Key, ValueResult]).

% Default handling for other compound terms
transform_compound(_, Args, Result, Depth) :-
    transform_list(Args, Result, Depth).



% Define a predicate to add 10 to each element
add_ten([], []).
add_ten([H|T], [H10|T10]) :-
    H10 is H + 10,
    add_ten(T, T10).

% Create an input list and transform it
process_data(Result) :-
    InputList = [1, 2, 3, 4, 5],
    add_ten(InputList, TransformedList),
    Result = [input_list-InputList, transformed_list-TransformedList].

% Define the result variable that will be used by the transform_to_ring function
res(Result) :- process_data(Result).


% Main predicate called by the runtime
main :-
    writeln("SWI-Prolog program starting..."),
    res(Result),
    writeln("Transforming result..."),
    transform_to_ring(Result, "plresult.txt"),
    writeln("Data written to file").
