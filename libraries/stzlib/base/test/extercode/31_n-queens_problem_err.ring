# Narrative
# --------
# N-Queens Problem ERR
#
# Extracted from stzextercodetest.ring, block #31.
#ERR needs SWI-Prolog INSTALLED -- runprolog.bat points at
#    d:/prolog/swipl-9.9.9/bin/swipl.exe, which is absent here, so the run
#    dies at "Result file 'plresult.txt' not created". The RING side is green:
#    PrepareSourceCode() builds the driver and names the right predicate.
#    (It used to die before that, on R24 'cmainpredicate' -- fixed.)

load "../../stzBase.ring"


pr()

oProlog = new stzExterCode(:Prolog)

oProlog.SetCode('

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
')

oProlog.Run()
? @@( oProlog.Result() )
#--> [ [ 2, 4, 1, 3 ], [ 3, 1, 4, 2 ] ]

#~> Two valid solutions to the 4-Queens problem,
# where each list describes a valid placement
# of queens on the chessboard.

pf()
# Executed in 0.36 second(s) in Ring 1.23
