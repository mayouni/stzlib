func XJl()
	return new stzJuliaCode

	func Jl()
		return new stzJuliaCode

# Runs a snippet of Julia from Ring and brings its answer back as a Ring value, through a result file.
#
# You set the code, which must assign its answer to a variable named res; Execute wraps it with a
# translator, runs it with the language's program in the current folder and writes the answer as
# Ring text, and Result reads that text back, so numbers, texts and nested lists cross the boundary.
# The files temp.<ext>, a run script, the result file and log.txt are written in the current folder.
# It is a thin face over stzExterCode, which has the full set of controls (runtime path, result
# variable, log file). The Julia program is the one configured in $aStzLibConfig[:JuliaPath],
# d:/julia/julia-1.11.7/bin/julia.exe by default. It was absent on the machine of this documentation
# run, so only the failure path was seen: Execute raised the not-created error.
#
#   receiver   o1 = new stzJuliaCode
#   see        stzExterCode, stzPythonCode, stzRCode
class stzJuliaCode from stzExterCode
	@ojlCode = new stzExterCode(:Julia)

	# Stores the Julia source text to run; nothing is written to disk until Execute.
	#
	#   pcJuliaCode   the Julia program text, which must assign its answer to a variable named res
	#   returns       nothing
	#   see           Execute, Code
	#@ aka  Initializing the external code
	def SetCode(pcJuliaCode)
		@ojlCode.setCode(pcJuliaCode)

		# Stores the Julia source text to run, as the call with the longer name does.
		#
		#   pcJuliaCode   the Julia program text, which must assign its answer to a variable named
		#                 res
		#   returns       nothing
		#   see           SetCode, Execute
		def @(pcJuliaCode)
			This.SetCode(pcJuliaCode)

	# Writes the source behind a translator, runs it with the Julia program and saves the answer for Result.
	#
	#   returns    nothing; the answer is kept in a result file
	#   note       not run to completion: the Julia program is absent here, so only the failure path
	#              was seen
	#   warning    it runs real code with a real program and writes temp.jl, runjulia.bat and
	#              log.txt in the current folder; the Julia program configured by default is not
	#              installed on the machine of this run, so Execute raised the not-created error
	#              with a path-not-found log
	#   see        Result, Log, Duration
	#@ aka  Running the exteranl code
	def Execute()
		@ojlCode.Execute()

		# Writes the source behind a translator and runs it with the Julia program, as the call with the other name does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same warning as Execute: it runs real code with a real program in the current
		#              folder
		#   see        Execute, Result
		def Run()
			@ojlCode.Execute()

		# Writes the source behind a translator and runs it with the Julia program, as the call with the other name does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same warning as Execute: it runs real code with a real program in the current
		#              folder
		#   see        Execute, Result
		def Exec()
			@ojlCode.Execute()

	# Reads the answer the Julia code saved and turns it into a Ring value: a number, a text or nested lists.
	#
	#   returns    the value
	#   note       not run: needs a successful Execute
	#   warning    evaluates the text of the result file as Ring code, so run only code you trust;
	#              reads the result file of the last run, which does not exist here because the run
	#              failed, so it raises an error that quotes the log
	#   see        Execute, Log
	#@ aka  Reading the result of the computation
	def Result()
		return @ojlCode.Result()

	# Returns the source text that was set, or, when none is set, the source file left on disk by an earlier run.
	#
	#   returns    a text
	#   warning    it returns your own code, not the wrapped source that is written to disk
	#   see        SetCode, Execute
	#@ aka  Debugging methods
	def Code()
		return @ojlCode.Code()

	# Returns how long the last run took, in seconds; 0 before any run.
	#
	#   returns    a number
	#   see        Execute, Trace
	def Duration()
		return @ojlCode.Duration()

	# Returns what the Julia program printed during the last run, errors included.
	#
	#   returns    a text; empty when there is no log file
	#   warning    on a new object it can return the log of an earlier run left in the current
	#              folder
	#   see        Execute, Trace
	def Log()
		return @ojlCode.Log()

	# Returns the history of runs of this object, oldest first, each a hashlist of language, timestamp, duration, log, exitcode and mode.
	#
	#   returns    a list of hashlists
	#   warning    the exit code is always recorded as 0, even for a run that failed
	#   see        Log, Duration
	def Trace()
		return @ojlCode.Trace()
