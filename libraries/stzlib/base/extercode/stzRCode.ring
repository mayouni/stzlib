func XR()
	return new stzRCode

	func R()
		return new stzRCode

# Meant to run a snippet of R from Ring and bring its answer back as a Ring value, but Execute always raises today.
#
# You set the code, which must assign its answer to a variable named res; Execute wraps it with a
# translator, runs it with the language's program in the current folder and writes the answer as
# Ring text, and Result reads that text back, so numbers, texts and nested lists cross the boundary.
# The files temp.<ext>, a run script, the result file and log.txt are written in the current folder.
# It is a thin face over stzExterCode, which has the full set of controls (runtime path, result
# variable, log file). WARNING: with R 4.5.1 the translator that Execute puts in front of your code
# is rejected by R (unexpected symbol at the identifier _items_), so every run raises the not-
# created error with that message in its log. The R program is the one configured in
# $aStzLibConfig[:RPath], d:/r/r-4.5.1/bin/rscript.exe by default, which exists on this machine.
#
#   receiver   o1 = new stzRCode
#   see        stzExterCode, stzPythonCode, stzJuliaCode
class stzRCode from stzObject
	@oRCode = new stzExterCode(:R)

	# Stores the R source text to run; nothing is written to disk until Execute.
	#
	#   pcRCode    the R program text, which must assign its answer to a variable named res
	#   returns    nothing
	#   see        Execute, Code
	#@ aka  Initializing the external code
	def SetCode(pcRCode)
		@oRCode.setCode(pcRCode)

		# Stores the R source text to run, as the call with the longer name does.
		#
		#   pcRCode    the R program text, which must assign its answer to a variable named res
		#   returns    nothing
		#   see        SetCode, Execute
		def @(pcRCode)
			This.SetCode(pcRCode)

	# Writes the source behind a translator, runs it with the R program and saves the answer for Result.
	#
	#   returns    nothing; the answer is kept in a result file
	#   note       run with a snippet that sets res: the run failed with the translator error, in a
	#              scratch folder
	#   warning    it runs real code with a real program and writes temp.R, runr.bat and log.txt in
	#              the current folder; with R 4.5.1 it always raises today, because the R translator
	#              that Execute adds in front of your code is rejected by R (unexpected symbol at
	#              the identifier _items_)
	#   see        Result, Log, Duration
	#@ aka  Running the exteranl code
	def Execute()
		@oRCode.Execute()

		# Writes the source behind a translator and runs it with the R program, as the call with the other name does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same warning as Execute: it runs real code with a real program in the current
		#              folder
		#   see        Execute, Result
		def Run()
			@oRCode.Execute()

		# Writes the source behind a translator and runs it with the R program, as the call with the other name does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same warning as Execute: it runs real code with a real program in the current
		#              folder
		#   see        Execute, Result
		def Exec()
			@oRCode.Execute()

	# Reads the answer the R code saved and turns it into a Ring value: a number, a text or nested lists.
	#
	#   returns    the value
	#   note       not run: needs a successful Execute
	#   warning    evaluates the text of the result file as Ring code, so run only code you trust;
	#              reads the result file of the last run, which does not exist here because the run
	#              failed, so it raises an error that quotes the log
	#   see        Execute, Log
	#@ aka  Reading the result of the computation
	def Result()
		return @oRCode.Result()

	# Returns the source text that was set, or, when none is set, the source file left on disk by an earlier run.
	#
	#   returns    a text
	#   warning    it returns your own code, not the wrapped source that is written to disk
	#   see        SetCode, Execute
	#@ aka  Debugging methods
	def Code()
		return @oRCode.Code()

	# Returns how long the last run took, in seconds; 0 before any run.
	#
	#   returns    a number
	#   see        Execute, Trace
	def Duration()
		return @oRCode.Duration()

	# Returns what the R program printed during the last run, errors included.
	#
	#   returns    a text; empty when there is no log file
	#   warning    on a new object it can return the log of an earlier run left in the current
	#              folder
	#   see        Execute, Trace
	def Log()
		return @oRCode.Log()

	# Returns the history of runs of this object, oldest first, each a hashlist of language, timestamp, duration, log, exitcode and mode.
	#
	#   returns    a list of hashlists
	#   warning    the exit code is always recorded as 0, even for a run that failed
	#   see        Log, Duration
	def Trace()
		return @oRCode.Trace()
