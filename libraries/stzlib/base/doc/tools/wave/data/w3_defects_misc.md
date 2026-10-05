# W3 misc defects (STZLIB-DOCREFORM-01) -- method: symptom: cause

## stzReactor
- Spawn, SubmitSpawn: a plain text instead of a list ("whoami", "cmd", "") raises R21: the `if isString(acArgv) acArgv = [acArgv]` wrap is skipped inside the method (Ring trap 6), the loop then indexes the text
## stzReactiveSystem
- StopSafe, SafeStopLoop, SafeStopExecution, SafeStopLoopExecution, StopNext, StopNextLoop: raise the STOPPED banner (error from stkProfiler Stop) when the scheduled timer fires: the anonymous func calls bare Stop(), which resolves to the global profiler Stop, not the object's (verified on 6 aliases, each with a fresh system and a running RunEvery)
- BindObjects: changes neither object passed: it wraps COPIES of both in new stzReactiveObject (Ring copies objects on assignment), verified with plain objects and with reactive objects
## stzRegex
- FindMatches, FindCapture (and MatchesZ/MatchesZZ/FindMatchesZZ which they use): skip the char after each match: `_nPos_ = _nEnd_ + 1` where CaptureEnd is already one past; `\d` on "1234" -> [1,3] (Matches -> 4 items), `a` on "aaaa" -> [1,3]; Matches() was fixed, these were not
- HasGroups: TRUE after any successful match even for a pattern with no parentheses (CaptureCount counts the whole match as 1); FALSE before a match even for a pattern with groups
- LastError: stub returning ""; PatternErrorOffset: stub returning -1, also for the invalid pattern "(\d+"
- FindPartialMatch: raises R2 (Array Access, Index out of range) when the text does not match: reads [3][2][1] of an empty section (verified 'abc' on two patterns)
- PartialMatchLength: one too small: "123-" -> 3, "12" for \d{3} -> 1, complete "123" -> 2: end(inclusive) - start without +1
- RecursiveDepth, NestedDepth: count distinct nested matches, not nesting depth: ((x)(y)(z)) -> 4 (nesting 2), ((a)(b)) -> 3, (((x))) -> 3
- MatchWordsIn, MatchFirstWordIn: stack \b..\b on the stored pattern each call ("pre" -> \bpre\b -> \b\bpre\b\b)
- Explain, ExplainXT (not a root): raise R11 class not found stzregexanalyzer for any pattern not in the RegexPatterns catalogue (4 patterns tried); catalogue patterns work
- MatchWordsIn... minor: SetPattern keeps the stale string and last match kind
## stzMatrex
- Match (CheckSize): size(<n), size(>n) never applied (size terms keep their text as value, ParseConstraints is skipped): {size(<2)} matches a 2x2; size with m or n in place of a number (3xn, mx3, nx2, 2xm) matches every matrix (verified 4 forms)
- Match (CheckRows, CheckCols, CheckPattern, CheckSum): stubs returning 1; CheckDeterminant: only squareness ({determinant(5)} matches a matrix of determinant -3); CheckDiagonal: only squareness ({diagonal(1)} matches any square matrix)
- Match: quantifiers + * ? n-m parsed into min/max but never used ({shape(tall)?} rejects a square matrix)
- MatchesNone: returns 1 at the first matching matrix and 0 when none match, the opposite of its name (two data sets)
- Andd: raises R24 (uninitialized oothermatriex): typo in the forwarding argument
- ToJSON, TokensToJSON, TokenToJSON: raise R21 for any pattern with at least one token (tokens are lists of [key,value] pairs, body concatenates them to text); only the empty pattern {} works
- Not_: puts @! in front of the whole inner text, so only the first term is negated: {size(2x2) -> property(symmetric)} negated rejects a 2x3 non-symmetric matrix (whole negation would accept); verified with & and ->
- CommonProperties: never reports "square" (CheckProperty has no square branch; [diag, identity] gives symmetric, diagonal, upper, lower); with no matching matrix every name is returned (vacuous)
- SimilarityScore: wrapped forms ["between", m] / ["and", m] raise (stores the inner matrix in a misspelled variable _aMatix1_ then rejects the list)
- RemoveConstraint: removes the token but leaves Pattern text unchanged (pattern and tokens diverge); RemoveConstraint('a') raises R41
- AnalyzeMatches: empty list raises R1 divide by zero
- SetTarget: unvalidated; SetTarget(5) then Explain raises "Bad parameter type!"; Matrix/Size not changed
## stzTablex
- whole parser (init/ParsePattern/SplitByOperator/ParseAlternation/ParseConjunction/ParseSingleToken, and And_/Or_/Not_): uses @StzMid(s, start, END) but @StzMid is COUNT-based (StzMid changed in 5976bb3de): {cols(3)} -> token type col, no value; SplitByOperator('a->b->(c->d)') -> one garbled text; ParseSingleToken('unique(Name)') value "Name)"; And_/Or_/Not_ patterns end with "}}" ("{cols(3)} & rows(3)}}"). stzMatrex got the end-based _Mid helper, stzTablex did not
- Match: FALSE for every pattern tried (about 90, none TRUE); {cols}, {rows} (term without parentheses) raise R24 uninitialized _ncloseparen_ at init; rows(..) and row(..) terms raise R14 hasrow (garbled type row + stzTable has no HasRow)
- CheckRow: R14 hasrow (stzTable has no HasRow); CheckCell: R2 (reads _aToken_["range"], never written); CheckColPattern: R14 matchesrx; CheckAlphabetic: R14 isalphabetic on a text column; CheckFormat, MatchesFormat: raise "pattern name ... does not exist in stzRegexData" (pat(value) used on a plain text)
- CheckContains: value that reads as a number ("28") raises "container searched must be a string or list" (ContainsCellCS(28,..))
- CheckProperty: unknown property name -> TRUE; CheckSorted, CheckUnique: unknown column -> TRUE
- CheckCols/CheckRows: greater is >=, less is <= (inclusive)
- CountMatchedParts, HowManyMatchedParts: R24 (@MatchedParts uninitialized: missing underscore)
- NumberOfTokens, CountTokens, HowManyTokens: 1 for a two-term -> pattern (splitter)
- IsNumeric: '12','-3' TRUE; '123','1.5','1-2' FALSE (count-based @StzMid(s,i,i)); the matrex copy answers 1.5 and 1-2 correctly
- ExtractParts: property word spelled "hasclculated"
- CheckNulls/CheckCompleteness: treat a real 0 as missing
## stzDataSet
- Percentile (engine path): percent below 0 or far above 100 panics in stz_stats.dll and ENDS the Ring process (-1: "integer part of floating point value out of bounds"; 150 on 3 and on 5 values: "index out of bounds"; 110, 101, 100.5 fine). PercentileXT (Ring path) clamps and survives. Q1/Q3/Deciles use fixed percents and are safe
- WMean: calls itself (R4 stack overflow, two data sets)
- NonParametricCorrelation: R24, reads _oOtherStats_ it does not receive
- PlanSummary: R5, reads oPlan[:title] (undefined variable) instead of _aPlan_
- MutualInformation: pairs joined with "_" and re-split: values containing "_" give 0 instead of the true value ("a_b"/"c_d" vs x/y -> 0, "ab"/"cd" -> 1)
- ValidateData: its null check appends to an undefined aIssues, unreachable today because nulls are dropped at init
- ExecutePlan steps: the Normality step prints p-value taken from element 2 of the test list ([ "skewness", .. ]) instead of the p value
- global tables: AddInsightRule/AddRule/AddWeightedRule/AddPlan write globals ($aDomainInsightRules, $aPlanTemplates) shared by every dataset and process-wide; Insights() ignores added domains, InsightsXT includes them
