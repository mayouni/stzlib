# The harness: the library's own court judges the learner's declaration.
# %SUBMISSION% is replaced by the path of the file the learner handed in.
oEduDecl = StzAgentDeclarationFromFileQ("%SUBMISSION%")
if oEduDecl.IsValid()
	? "admitted"
	? "reversibility: " + oEduDecl.ReversibilityClass()
else
	? "refused"
	? oEduDecl.CiteFindings()
ok
