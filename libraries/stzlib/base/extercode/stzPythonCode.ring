func XPy()
	return new stzPythonCode

	func py()
		return new stzPythonCode

class stzPyCode from stzPythonCode
# Runs a snippet of Python from Ring and brings its answer back as a Ring value, through a result file.
#
# You set the code, which must assign its answer to a variable named res; Execute wraps it with a
# translator, runs it with the language's program in the current folder and writes the answer as
# Ring text, and Result reads that text back, so numbers, texts and nested lists cross the boundary.
# The files temp.<ext>, a run script, the result file and log.txt are written in the current folder.
# It is a thin face over stzExterCode, which has the full set of controls (runtime path, result
# variable, log file). The Python program is the one configured in $aStzLibConfig[:PythonPath],
# d:/python/python-3.13.7/python.exe by default, which is not installed on every machine. Where the
# environment variable NoDefaultCurrentDirectoryInExePath is 1 the run script is not found and
# Execute raises an error.
#
#   receiver   o1 = new stzPythonCode
#   example    o1.SetCode("res = sum([1, 2, 3])")
#              o1.Execute()
#              ? o1.Result()
#              #--> 6
#   see        stzExterCode, stzRCode, stzJuliaCode
class stzPythonCode from stzObject
	@oPyCode = new stzExterCode(:python)

	# Stores the Python source text to run; nothing is written to disk until Execute.
	#
	#   pcPyCode   the Python program text, which must assign its answer to a variable named res
	#   returns    nothing
	#   see        Execute, Code
	#@ aka  Initializing the external code
	def SetCode(pcPyCode)
		@oPyCode.setCode(pcPyCode)

		# Stores the Python source text to run, as the call with the longer name does.
		#
		#   pcPyCode   the Python program text, which must assign its answer to a variable named res
		#   returns    nothing
		#   see        SetCode, Execute
		def @(pcPyCode)
			This.SetCode(pcPyCode)

	# Writes the source behind a translator, runs it with the Python program and saves the answer for Result.
	#
	#   returns    nothing; the answer is kept in a result file
	#   note       run with a snippet that sets res, from a scratch folder, with that variable unset
	#              for the process
	#   warning    it runs real code with a real program and writes temp.py, runpython.bat,
	#              pyresult.txt and log.txt in the current folder; the run script is started by its
	#              bare name, so it fails where the environment variable
	#              NoDefaultCurrentDirectoryInExePath is 1; an error in your code leaves no result
	#              file and raises an error that quotes the log
	#   see        Result, Log, Duration
	#@ aka  Running the exteranl code
	def Execute()
		@oPyCode.Execute()

		# Writes the source behind a translator and runs it with the Python program, as the call with the other name does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same warning as Execute: it runs real code with a real program in the current
		#              folder
		#   see        Execute, Result
		def Run()
			@oPyCode.Execute()

		# Writes the source behind a translator and runs it with the Python program, as the call with the other name does.
		#
		#   returns    nothing; the answer is kept in a result file
		#   warning    same warning as Execute: it runs real code with a real program in the current
		#              folder
		#   see        Execute, Result
		def Exec()
			@oPyCode.Execute()

	# Reads the answer the Python code saved and turns it into a Ring value: a number, a text or nested lists.
	#
	#   returns    the value
	#   note       checked with a number, a text, a list and a dictionary, which comes back as a
	#              list of [ key, value ] pairs
	#   warning    evaluates the text of the result file as Ring code, so run only code you trust;
	#              reads the result file left by the last run in the current folder, so on a new
	#              object it can return the answer of an earlier run
	#   see        Execute, Log
	#@ aka  Reading the result of the computation
	def Result()
		return @oPyCode.Result()

	# Returns the source text that was set, or, when none is set, the source file left on disk by an earlier run.
	#
	#   returns    a text
	#   warning    it returns your own code, not the wrapped source that is written to disk
	#   see        SetCode, Execute
	#@ aka  Debugging methods
	def Code()
		return @oPyCode.Code()

	# Returns how long the last run took, in seconds; 0 before any run.
	#
	#   returns    a number
	#   see        Execute, Trace
	def Duration()
		return @oPyCode.Duration()

	# Returns what the Python program printed during the last run, errors included.
	#
	#   returns    a text; empty when there is no log file
	#   warning    on a new object it can return the log of an earlier run left in the current
	#              folder
	#   see        Execute, Trace
	def Log()
		return @oPyCode.Log()

	# Returns the history of runs of this object, oldest first, each a hashlist of language, timestamp, duration, log, exitcode and mode.
	#
	#   returns    a list of hashlists
	#   warning    the exit code is always recorded as 0, even for a run that failed
	#   see        Log, Duration
	def Trace()
		return @oPyCode.Trace()
