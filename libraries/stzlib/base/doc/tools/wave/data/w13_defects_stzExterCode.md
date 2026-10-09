# Wave 13 defects (stzExterCode, stzDotCode, stzSuperApp, stzHttpSandbox, stzReactorHttpClient)

Found while calling each method with invented data; none fixed (comments only). Each is a warning in the method's block.

| class.method | symptom | cause | evidence |
|---|---|---|---|
| stzExterCode.Execute (language r) | raises "Result file 'rresult.txt' not created", log is an R syntax error | the R translator names a variable `_items_` (and `_transformed_`), and R 4.5.1 does not accept a name that starts with an underscore | two runs with different code (`res <- sum(1:4)`, `res <- 'hello'`) gave the same log: unexpected symbol at `_items_`; PrepareSourceCode contains `_items_ <-` |
| stzExterCode.Execute (any language, some environments) | raises "Result file ... not created. Log: Log file 'log.txt' not found or unreadable" | the run script is started by its bare name (`runnodejs.bat`); where the environment variable NoDefaultCurrentDirectoryInExePath is 1 the command shell refuses a bare name in the current folder | with the variable set: error and no log; the same script run as `.\runnodejs.bat`, or the Ring process started with the variable unset, works and Result gave 42 |
| stzExterCode.CallTrace | the exit code of a failed run is recorded as 0 | Execute passes a literal 0 to RecordExecution | read from the code (Execute: `This.RecordExecution(_cLog_, 0)`) |
| stzExterCode.SetRuntimePath | a path with a space breaks the run | the path is written into the batch file without quotes | read from the code; the Python found on this machine lives under a folder with spaces, and its 8.3 short path was used instead |
| stzDotCode.SetOutputFormat | "PNG", "SVG", "Jpg" raise "Unsupported output formats"; " png " is accepted | the check looks the name up in a lower-case list before the code lower-cases it, so the later lower-casing can never matter | six names tried: SVG, Jpg, Png raised; pdf, null, NULL accepted (the last two as svg) |
| stzDotCode.SetOutput | accepts "docx", which Graphviz does not know, and Execute then fails | the alias is nested in SetOutputFormat but only does the assignment, with no trim, no default and no check | SetOutput("DOCX") then OutputFormat gave docx; SetOutputFormat("docx") raised |
| stzDotCode.CleanupAll | removes only the working files, never a picture | the body reads `@cOutputDire` (a typo for `@cOutputDir`), the error is swallowed by the empty catch, and it looks for `diagram.<format>` while Execute names files `diagram_<clock>.<format>` | with `output/diagram.svg` written by hand, CleanupAll left it in place |
| stzDotCode.Log | always empty after a run | nothing in the class writes `<tempdir>/dotlog.txt` (Execute does not redirect Graphviz output to it) | Log read empty after a good run and after a failed one; it returned "my log" once the file was written by hand |
| stzReactorHttpClient.Request | never reports a real status | the reactor's client returns only a body | stated by the file's own comment; a closed port and an unanswered listener both gave status 0; the 200 path was not run |

Not defects, but worth knowing: stzSuperApp.Why only explains CallAcross; the reason a RegisterIdentity returns FALSE is in CommonsQ().Why().
