#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSYSTEMCALL              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : System call -- Engine-backed (Zig DLL).     #
#                  Runs external commands without showing a    #
#                  console window. Captures stdout/stderr.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

ShellBuiltInCommands = [
	# Windows built-ins
	"echo", "cd", "dir", "type", "set", "if", "for", "date", "time",
	"copy", "move", "del", "ren", "md", "rd", "cls", "exit", "call",
	"start", "pushd", "popd", "assoc", "ftype", "mklink",

	# Unix/Linux built-ins
	"export", "source", "alias", "unalias", "pwd", "test", "read",
	"eval", "exec", "shift", "wait", "ulimit", "umask", "bg", "fg",
	"jobs", "kill", "trap", "hash", "getopts"
]

# GLOBAL FUNCTIONS
#==================

# Open a file or folder in the application the system associates with it --
# the safe form of system('start "" "' + path + '"'), which hands the path to
# a shell: a `"` in it ends the quoting and the rest is RUN (threat-model R11).
# Here no shell sees the path (ShellExecuteW on Windows; `open` / `xdg-open`
# with the path as one argument elsewhere), and anything that is not an
# EXISTING file or folder is refused before anything is launched.
# Returns 1 when the viewer was launched, 0 when the launch failed.
func StzOpenInDefaultApp(pcPath)
	if NOT isString(pcPath) or ring_trim(pcPath) = ""
		stzraise("StzOpenInDefaultApp: a path is required.")
	ok
	if NOT ( fexists(pcPath) or direxists(pcPath) )
		stzraise("StzOpenInDefaultApp: '" + pcPath + "' is not an existing file or folder -- nothing is launched.")
	ok
	return StzEngineSystemOpenDefault(pcPath) = 0

func StzSystemCallQ(pcProgram)
	return new stzSystemCall(pcProgram)

func StzSystemCallQXT(pcProgram, cReturnType)
	_oCall_ = new stzSystemCall(pcProgram)
	_oCall_.SetReturnType(cReturnType)
	return _oCall_

func StzSystem(pcCommand)
	pcCommand = StzNormalizePathsInCommand(pcCommand)

	_oSysCall_ = new stzSystemCall(pcCommand)
	_oSysCall_.HideConsole()
	return _oSysCall_.RunAndGetOutput()

func StzSystemSilent(pcCommand)
	pcCommand = StzNormalizePathsInCommand(pcCommand)

	_oSysCall_ = new stzSystemCall(pcCommand)
	_oSysCall_.HideConsole()
	_oSysCall_.RunSilently()

func StzNormalizePathsInCommand(pcCommand)
	# Convert slashes in paths only, not in command flags
	_cResult_ = ""
	_aTokens_ = split(pcCommand, " ")
	_nLen_ = len(_aTokens_)
	for i = 1 to _nLen_
		_cToken_ = _aTokens_[i]

		if isWindows()
			# Convert / to \ only if not a flag (doesn't start with /)
			if StzFindFirst("/", _cToken_) > 0 and _cToken_[1] != "/"
				_cToken_ = StzReplace(_cToken_, "/", "\")
			ok
		else
			# Convert \ to / for Unix paths
			if StzFindFirst("\", _cToken_) > 0
				_cToken_ = StzReplace(_cToken_, "\", "/")
			ok
		ok

		_cResult_ += _cToken_
		if i < len(_aTokens_)
			_cResult_ += " "
		ok
	next

	return _cResult_

	func NormalizePathsInCommand(pcCommand)
		return StzNormalizePathsInCommand(pcCommand)

func StzSystemXT(pcProgram, pacArgs)
	_oSysCall_ = new stzSystemCall(pcProgram)
	_oSysCall_.SetArgs(pacArgs)
	_oSysCall_.HideConsole()
	return _oSysCall_.RunAndGetOutput()

func StzSystemSilentXT(pcProgram, pacArgs)
	_oSysCall_ = new stzSystemCall(pcProgram)
	_oSysCall_.SetArgs(pacArgs)
	_oSysCall_.RunSilently()


# THE CLASS
#===========

# Runs an external program from a command line or from a program and a list of arguments, and keeps its output and exit code.
#
# Build the call, run it, then read Output, Error and ExitCode. The command is run by the engine
# with no console window. A list of arguments given with SetArgs reaches a program that is not a
# shell one by one, with no shell parsing them; a command line that starts with a shell word such as
# echo or holds a pipe is wrapped to run through the shell. ReturnType asks for the output as text,
# as lines or as a number. Set the program and arguments only from values you trust, since the call
# starts a real process.
#
#   receiver   o1 = new stzSystemCall("echo hello world")
#   example    o1.Run()
#              ? o1.Succeeded()
#              #--> 1
#              ? o1.OutputAsLines()[1]
#              #--> hello world
#              ? o1.ExitCode()
#              #--> 0
#   see        StzSystem, StzSystemCallQ, StzOpenInDefaultApp, stzProcess
class stzSystemCall from stzObject
	@cCommandString = ""
	@cProgram = ""
	@acArgs = []

	@nTimeout = 30000
	@bCaptureOutput = 1
	@bCaptureError = 1
	@bShowConsole = 0
	@cOutput = ""
	@cError = ""
	@nExitCode = -1
	@bExecuted = 0
	@bRunSilentMode = 0

	# 1 when the arguments came as a LIST to a program that is not itself a
	# shell: the call then runs through StzEngineSystemRunArgv, and no shell
	# ever parses an argument. See SetArgs().
	@bArgvMode = 0

	# Return type control for Sys() commands
	@cReturnType = "string"  # "string", "number", or "list"

	# Builds a call from a command line, splitting it into a program and arguments; nothing runs yet.
	#
	#   pcCommandString   the command line, as text
	#   returns           nothing; the object is built
	#   note              on Windows a command that starts with a shell word such as echo, or holds
	#                     a pipe, an ampersand or a redirection, is wrapped to run through cmd.exe
	#                     /c, so Program answers cmd.exe
	#   warning           anything but a text raises the error Command must be a string!
	#   see               Run, SetArgs, SetReturnType
	def init(pcCommandString)
		if NOT isString(pcCommandString)
			stzraise("Command must be a string!")
		ok

		@cCommandString = pcCommandString
		This.ParseCommandString(pcCommandString)
		This.UseShellIfNeeded()

	# Splits a command line into the program and its arguments, keeping a double-quoted part as one argument.
	#
	#   _cCmd_     the command line, as text
	#   returns    nothing; Program and Args hold the result
	#   note       the program is the first word, so a program path with spaces must be set with
	#              SetProgram
	#   see        Program, Args
	def ParseCommandString(_cCmd_)
		# Check for return type suffix (@RETURN:type)
		_nReturnPos_ = StzFindFirst("@RETURN:", _cCmd_)
		if _nReturnPos_ > 0
			# Extract return type
			_oCmd_ = new stzString(_cCmd_)
			@cReturnType = trim(_oCmd_.Section(_nReturnPos_ + 8, _oCmd_.NumberOfChars()))
			# Remove suffix from command
			_cCmd_ = trim(_oCmd_.Section(1, _nReturnPos_ - 1))
		ok

		# Handle quoted arguments properly
		@acArgs = []
		_cCmd_ = trim(_cCmd_)

		# Extract first token (program name)
		_nPos_ = StzFindFirst(" ", _cCmd_)
		if _nPos_ = 0
			@cProgram = _cCmd_
			return
		ok

		_oCmd2_ = new stzString(_cCmd_)
		@cProgram = _oCmd2_.Section(1, _nPos_ - 1)
		_cRest_ = trim(_oCmd2_.Section(_nPos_ + 1, _oCmd2_.NumberOfChars()))

		# Parse remaining arguments respecting quotes
		_bInQuote_ = 0
		_cCurrent_ = ""

		_oRest_ = new stzString(_cRest_)
		_acChars_ = _oRest_.Chars()
		_nLen_ = len(_acChars_)

		for i = 1 to _nLen_
			_c_ = _acChars_[i]

			if _c_ = '"'
				_bInQuote_ = NOT _bInQuote_
			but _c_ = " " and NOT _bInQuote_
				if _cCurrent_ != ""
					@acArgs + _cCurrent_
					_cCurrent_ = ""
				ok
			else
				_cCurrent_ += _c_
			ok
		next

		if _cCurrent_ != ""
			@acArgs + _cCurrent_
		ok

	#-------------------#
	#  MAIN EXECUTION  #
	#-------------------#

	# Runs the command and keeps its output, error text and exit code in the object.
	#
	#   returns    nothing; read Output, Error and ExitCode afterwards
	#   note       RunQ is the same call and returns the object; Execute and Exec are the same call;
	#              the Timeout is stored but not applied, see SetTimeout
	#   warning    an empty program raises the error No program specified!
	#   see        RunAndGetOutput, RunSilently, Succeeded
	def Run()

		if @cProgram = ""
			stzraise("No program specified!")
		ok

		# Use shell if command contains shell operators -- never for a
		# program given its arguments as a list (see SetArgs)
		if NOT @bArgvMode
			This.UseShellIfNeeded()
		ok

		# Handle silent mode
		if @bRunSilentMode
			This.RunEngineSilent()
			return ""
		ok

		_cFullCmd_ = _BuildCommandLine()

		# Use engine for hidden console execution
		if NOT @bShowConsole
			# Engine-backed: ONE spawn returns stdout, the exit code, AND
			# stderr together.
			#
			# This used to call StzEngineSystemRun (stdout only), hardcode
			# @nExitCode = 0, and -- when the output happened to be empty --
			# RE-RUN the whole command via StzEngineSystemExec just to read
			# the exit code. So a side-effecting command with no stdout
			# (mkdir, a redirect, an HTTP POST) executed TWICE, the exit code
			# was wrong (0) whenever the command failed but printed something,
			# and stderr was thrown away. All three are fixed by reading the
			# one run's real results.
			if @bArgvMode
				_aRun_ = StzEngineSystemRunArgv(This._PackedArgv())
			else
				_aRun_ = StzEngineSystemRunXT(_cFullCmd_)
			ok
			@cOutput = _aRun_[1]
			@nExitCode = _aRun_[2]

			if @bCaptureError
				@cError = _aRun_[3]
			ok

			@bExecuted = 1

			if @bCaptureOutput
				This.ConvertOutputByType()
			ok
		else
			# Fallback to Ring system() when console is explicitly shown
			_cOutFile_ = ""
			_cErrFile_ = ""

			if @bCaptureOutput or @bCaptureError
				_cTmpBase_ = tempname()
				_cOutFile_ = _cTmpBase_ + "_out.tmp"
				_cErrFile_ = _cTmpBase_ + "_err.tmp"
				_cFullCmd_ += ' >"' + _cOutFile_ + '" 2>"' + _cErrFile_ + '"'
			ok

			@nExitCode = system(_cFullCmd_)
			@bExecuted = 1

			if @bCaptureOutput and _cOutFile_ != ""
				try
					@cOutput = read(_cOutFile_)
					remove(_cOutFile_)
				catch
					@cOutput = ""
				done
				This.ConvertOutputByType()
			ok

			if @bCaptureError and _cErrFile_ != ""
				try
					@cError = read(_cErrFile_)
					remove(_cErrFile_)
				catch
					@cError = ""
				done
			ok
		ok

		def RunQ()
			This.Run()
			return This

		# Runs the command and keeps its output, error text and exit code in the object.
		#
		#   returns    nothing; read Output, Error and ExitCode afterwards
		#   see        Run, Exec
		def Execute()
			This.Run()

		def ExecuteQ()
			This.Execute()
			return This

		# Runs the command and keeps its output, error text and exit code in the object.
		#
		#   returns    nothing; read Output, Error and ExitCode afterwards
		#   see        Run, Execute
		def Exec()
			This.Run()

		def ExecQ()
			This.Exec()
			return This

	#-----------------------#
	#  RETURN TYPE CONTROL  #
	#-----------------------#

	# Chooses how the output is read after a run: as text, as a number or as a list of lines.
	#
	#   _cType_    string, number or list
	#   returns    the object itself, so calls chain
	#   note       with list or number the output is turned into that type by Run, and then
	#              OutputAsLines raises an error; a number is read only from output made of digits,
	#              see ParseOutputAsNumber
	#   warning    any other word raises the error Return type must be 'string', 'number', or 'list'
	#   see        ReturnType, Run
	def SetReturnType(_cType_)
		_cType_ = StzLower(_cType_)
		if NOT (_cType_ = "string" or _cType_ = "number" or _cType_ = "list")
			stzraise("Return type must be 'string', 'number', or 'list'")
		ok
		@cReturnType = _cType_
		return This

		def SetReturnTypeQ(_cType_)
			This.SetReturnType(_cType_)
			return This

	# Returns how the output is read after a run: string, number or list.
	#
	#   returns    a text, "string" by default
	#   see        SetReturnType, ConvertOutputByType
	def ReturnType()
		return @cReturnType

	def _BuildCommandLine()
		_cCmd_ = ""
		if @cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[1] = "/c"
			_cCmd_ = "cmd.exe /c "
			_cCommand_ = ""
			_nArgsLen_3 = len(@acArgs)
			for i = 2 to _nArgsLen_3
				_cArg_ = @acArgs[i]
				if i > 2
					_cCommand_ += " "
				ok
				if _cArg_ = "&" or _cArg_ = "&&" or _cArg_ = "|" or _cArg_ = "||"
					_nCmdLen_ = StzLen(_cCommand_)
					if _nCmdLen_ > 0
						_oTmp_ = new stzString(_cCommand_)
						_acTmpChars_ = _oTmp_.Chars()
						if _acTmpChars_[_nCmdLen_] != " "
							_cCommand_ += " "
						ok
					ok
					_cCommand_ += _cArg_
				else
					_cCommand_ += _cArg_
				ok
			next
			_cCmd_ += _cCommand_
		else
			if StzFindFirst(" ", @cProgram) > 0
				_cCmd_ = '"' + @cProgram + '"'
			else
				_cCmd_ = @cProgram
			ok
			_nArgsLen_2 = len(@acArgs)
			for i = 1 to _nArgsLen_2
				if StzFindFirst(" ", @acArgs[i]) > 0
					_cCmd_ += ' "' + @acArgs[i] + '"'
				else
					_cCmd_ += " " + @acArgs[i]
				ok
			next
		ok
		return _cCmd_

	# Turns the text output into a list of lines or a number according to the return type; text stays as it is.
	#
	#   returns    nothing; Output holds the converted value
	#   note       Run calls it for you when the output is captured; calling it again on an already
	#              converted output does nothing
	#   see        SetReturnType, ParseOutputAsLines, ParseOutputAsNumber
	def ConvertOutputByType()
		if NOT isString(@cOutput)
			return  # Already converted or empty
		ok

		if @cReturnType = "list"
			@cOutput = This.ParseOutputAsLines()
		but @cReturnType = "number"
			@cOutput = This.ParseOutputAsNumber()
		ok
	# Returns the output split into its non-empty lines, each trimmed.
	#
	#   returns    a list of text; an empty list when there is no output
	#   see        OutputAsLines, ParseOutputAsNumber
	#@ aka  "string" type needs no conversion
	def ParseOutputAsLines()
		if NOT isString(@cOutput) or @cOutput = ""
			return []
		ok

		_acLines_ = split(@cOutput, char(10))
		_aResult_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ != ""
				_aResult_ + _cLine_
			ok
		next
		return _aResult_

	# Returns the first number found in the output.
	#
	#   returns    a number; 0 when the output is empty
	#   note       it works only on output made of digits
	#   warning    raises the error R41 Invalid numeric string when the output holds a character
	#              that is not a digit, so "12" is read and "42 apples", "3.5", "-8" and "none" all
	#              raise (its character test compares each character with "0" and raises on a
	#              letter, a space after the digits, a sign or a point)
	#   see        ParseOutputAsLines, SetReturnType
	def ParseOutputAsNumber()
		if NOT isString(@cOutput) or @cOutput = ""
			return 0
		ok

		_cOut_ = trim(@cOutput)
		_oOut_ = new stzString(_cOut_)
		_acChars_ = _oOut_.Chars()
		_nLen_ = len(_acChars_)

		# Try to extract first number from output
		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if (_c_ >= "0" and _c_ <= "9") or _c_ = "-" or _c_ = "."
				# Found start of number, extract it
				_cNum_ = ""
				for j = i to _nLen_
					_c2_ = _acChars_[j]
					if (_c2_ >= "0" and _c2_ <= "9") or _c2_ = "." or _c2_ = "-"
						_cNum_ += _c2_
					else
						exit
					ok
				next
				return 0 + _cNum_  # Convert to number
			ok
		next
		return 0

	#-----------------------#
	#  CONFIGURATION        #
	#-----------------------#

	# Returns the program the call will run.
	#
	#   returns    a text
	#   see        SetProgram, Args
	def Program()
		return @cProgram

	# Sets the program the call will run.
	#
	#   pcProgram   the program name or path, as text
	#   returns     nothing; use SetProgramQ to chain
	#   see         Program, SetArgs
	def SetProgram(pcProgram)
		@cProgram = pcProgram

		def SetProgramQ(pcProgram)
			This.SetProgram(pcProgram)
			return This

	# Returns the arguments the call will pass to the program.
	#
	#   returns    a list of text
	#   see        SetArgs, AddArg
	def Args()
		return @acArgs

	# Sets the argument list and, for a program that is not a shell, makes the call run them without any shell parsing.
	#
	#   pacArgs    the arguments, as a list of text
	#   returns    nothing; use SetArgsQ to chain
	#   note       WithArgs is the same call; a shell program such as cmd.exe, sh, bash or
	#              powershell keeps shell parsing
	#   warning    a list holding a non-text raises the error Args must be a list of strings! when
	#              parameter checking is on
	#   see        Args, AddArg, SetParam
	def SetArgs(pacArgs)
		if CheckingParams()
			if NOT (isList(pacArgs) and IsListOfStrings(pacArgs))
				stzraise("Args must be a list of strings!")
			ok
		ok
		@acArgs = pacArgs

		# Arguments given as a LIST reach the program one by one, with no
		# shell between -- unless the program is itself a shell. They used
		# to be joined into one string for cmd.exe /c, quoted only when they
		# held a space, so an argument holding &, a double quote, %VAR% or
		# $(...) was parsed as shell syntax.
		if This._IsShellProgram()
			@bArgvMode = 0
		else
			@bArgvMode = 1
		ok

		# Sets the argument list, as SetArgs does.
		#
		#   pacArgs    the arguments, as a list of text
		#   returns    nothing; use WithArgsQ to chain
		#   see        SetArgs, Args
		def WithArgs(pacArgs)
			This.SetArgs(pacArgs)

		def SetArgsQ(pacArgs)
			This.SetArgs(pacArgs)
			return This

		def WithArgsQ(pacArgs)
			return This.SetArgsQ(pacArgs)

	# Replaces {name} in every argument by a value.
	#
	#   cParam     the placeholder name, written without braces
	#   _cValue_   the text to put in its place
	#   returns    nothing
	#   note       on Windows a value holding / or \ gets its slashes turned into backslashes
	#   see        SetParams, SetArgs
	def SetParam(cParam, _cValue_)
		# Convert forward slashes to backslashes on Windows for path-like values
		if isWindows() and (StzFindFirst("/", _cValue_) > 0 or StzFindFirst("\", _cValue_) > 0)
			_cValue_ = StzReplace(_cValue_, "/", "\")
		ok

		_nArgsLen_ = len(@acArgs)
		for i = 1 to _nArgsLen_
			@acArgs[i] = StzReplace(@acArgs[i], "{" + cParam + "}", _cValue_)
		next

	# Replaces several {name} placeholders in the arguments, one pair after another.
	#
	#   aParams    a list of [ name, value ] pairs
	#   returns    nothing; use SetParamsQ to chain
	#   note       WithParams is the same call
	#   see        SetParam, SetArgs
	def SetParams(aParams)
		_nLen_ = len(aParams)
		for i = 1 to _nLen_
			This.SetParam(aParams[i][1], aParams[i][2])
		next

		# Replaces several {name} placeholders in the arguments, as SetParams does.
		#
		#   aParams    a list of [ name, value ] pairs
		#   returns    nothing; use WithParamsQ to chain
		#   see        SetParams, SetArgs
		def WithParams(aParams)
			This.SetParams(aParams)

		def SetParamsQ(aParams)
			This.SetParams(aParams)
			return This

		def WithParamsQ(aParams)
			return This.SetParamsQ(aParams)

	# Appends one argument to the list.
	#
	#   pcArg      the argument to append, as text
	#   returns    nothing; use AddArgQ to chain
	#   note       WithArg is the same call
	#   see        Args, SetArgs
	def AddArg(pcArg)
		@acArgs + pcArg

		# Appends one argument to the list, as AddArg does.
		#
		#   pcArg      the argument to append, as text
		#   returns    nothing; use WithArgQ to chain
		#   see        AddArg, Args
		def WithArg(pcArg)
			This.AddArg(pcArg)

		def AddArgQ(pcArg)
			This.AddArg(pcArg)
			return This

		def WithArgQ(pcArg)
			return This.AddArgQ(pcArg)

	# Empties the argument list.
	#
	#   returns    nothing; use ClearArgsQ to chain
	#   see        Args, Reset
	def ClearArgs()
		@acArgs = []

		def ClearArgsQ()
			This.ClearArgs()
			return This

	# Stores a timeout in milliseconds for the call.
	#
	#   nMilliseconds   the timeout, in milliseconds
	#   returns         nothing; use SetTimeoutQ to chain
	#   note            WithTimeout is the same call
	#   warning         the value is only stored: nothing reads it when the command runs, so a call
	#                   set to 1 ms still ran a 2-second command to its end (ping -n 3 on 127.0.0.1,
	#                   2083 ms, exit 0, tried also with echo)
	#   see             Timeout
	def SetTimeout(nMilliseconds)
		@nTimeout = nMilliseconds

		# Stores a timeout in milliseconds, as SetTimeout does; like it, the value is not applied when the command runs.
		#
		#   nMilliseconds   the timeout, in milliseconds
		#   returns         nothing; use WithTimeoutQ to chain
		#   see             SetTimeout, Timeout
		def WithTimeout(nMilliseconds)
			This.SetTimeout(nMilliseconds)

		def SetTimeoutQ(nMilliseconds)
			This.SetTimeout(nMilliseconds)
			return This

		def WithTimeoutQ(nMilliseconds)
			return This.SetTimeoutQ(nMilliseconds)

	# Returns the stored timeout, in milliseconds; 30000 by default.
	#
	#   returns    a number
	#   note       it is a stored value that Run does not apply
	#   see        SetTimeout
	def Timeout()
		return @nTimeout

	#-----------------------#
	#  OUTPUT CONTROL       #
	#-----------------------#

	# Asks for the output to be kept after a run, which is the default.
	#
	#   returns    nothing; use CaptureOutputQ to chain
	#   see        DontCaptureOutput, Output
	def CaptureOutput()
		@bCaptureOutput = 1

		def CaptureOutputQ()
			This.CaptureOutput()
			return This

	# Asks for the output not to be kept after a run.
	#
	#   returns    nothing; use DontCaptureOutputQ to chain
	#   warning    with the console hidden, which is the default, Output still holds the text (tried
	#              with echo, twice): only the conversion to a list or a number is skipped; with
	#              ShowConsole the output is really dropped
	#   see        CaptureOutput, Output
	def DontCaptureOutput()
		@bCaptureOutput = 0

		def DontCaptureOutputQ()
			This.DontCaptureOutput()
			return This

	# Asks for the error text to be kept after a run, which is the default.
	#
	#   returns    nothing; use CaptureErrorQ to chain
	#   see        DontCaptureError, Error
	def CaptureError()
		@bCaptureError = 1

		def CaptureErrorQ()
			This.CaptureError()
			return This

	# Asks for the error text not to be kept after a run.
	#
	#   returns    nothing; use DontCaptureErrorQ to chain
	#   see        CaptureError, Error
	def DontCaptureError()
		@bCaptureError = 0

		def DontCaptureErrorQ()
			This.DontCaptureError()
			return This

	# Makes the next run go through Ring's own system call, with the output and error redirected to temporary files.
	#
	#   returns    nothing; use ShowConsoleQ to chain
	#   see        HideConsole, Run
	def ShowConsole()
		@bShowConsole = 1

		def ShowConsoleQ()
			This.ShowConsole()
			return This

	# Makes the next run use the engine, with no console window, which is the default.
	#
	#   returns    nothing; use HideConsoleQ to chain
	#   note       Silent and Silently are the same call
	#   see        ShowConsole, RunSilently
	def HideConsole()
		@bShowConsole = 0

		# Makes the next run use the engine, with no console window.
		#
		#   returns    nothing; use SilentQ to chain
		#   see        HideConsole, RunSilently
		def Silent()
			This.HideConsole()

		# Makes the next run use the engine, with no console window.
		#
		#   returns    nothing; use SilentlyQ to chain
		#   see        HideConsole, RunSilently
		def Silently()
			This.HideConsole()

		def HideConsoleQ()
			This.HideConsole()
			return This

		def SilentQ()
			return This.HideConsoleQ()

		def SilentlyQ()
			return This.HideConsoleQ()

	#-----------------------#
	#  SILENT EXECUTION     #
	#-----------------------#

	# Runs the command through the engine and keeps only its exit code.
	#
	#   returns    nothing; read ExitCode afterwards
	#   note       the command's own output is not kept but is not hidden either: it appears in the
	#              console that started the program
	#   see        RunSilently, Run
	def RunEngineSilent()
		if @bArgvMode
			_aRun_ = StzEngineSystemRunArgv(This._PackedArgv())
			@nExitCode = _aRun_[2]
			@bExecuted = 1
			return
		ok
		_cFullCmd_ = _BuildCommandLine()
		# Engine exec: no console, no output capture, just exit code
		@nExitCode = StzEngineSystemExec(_cFullCmd_)
		@bExecuted = 1

	# Program + arguments joined by char(0), the form the engine's argv
	# runner takes. A NUL cannot occur inside an argument.
	def _PackedArgv()
		_cPacked_ = @cProgram
		_nLen_ = len(@acArgs)
		for i = 1 to _nLen_
			_cPacked_ += char(0) + @acArgs[i]
		next
		return _cPacked_

	# 1 when the program IS a shell -- its arguments are shell syntax on
	# purpose (cmd.exe /c ..., sh -c ...), so they keep the shell path.
	def _IsShellProgram()
		_cP_ = StzLower(StzReplace(@cProgram, char(92), "/"))
		_acParts_ = split(_cP_, "/")
		if len(_acParts_) > 0  _cP_ = _acParts_[len(_acParts_)]  ok
		if find([ "cmd", "cmd.exe", "sh", "bash", "zsh", "dash",
			  "powershell", "powershell.exe", "pwsh", "pwsh.exe" ], _cP_) > 0
			return 1
		ok
		return 0

	# Runs the command and keeps only its exit code, with no output or error captured.
	#
	#   returns    nothing; read ExitCode afterwards
	#   note       RunSilentlyQ is the same call and returns the object; RunSilent is the same call
	#   warning    the command's own output is not kept but it still appears in the console that
	#              started the program (echo printed its text, tried 4 times)
	#   see        Run, RunEngineSilent
	def RunSilently()
		@bRunSilentMode = 1
		@bShowConsole = 0
		@bCaptureOutput = 0
		@bCaptureError = 0
		This.Run()
		@bRunSilentMode = 0

		def RunSilentlyQ()
			This.RunSilently()
			return This

		# Runs the command and keeps only its exit code, with no output or error captured.
		#
		#   returns    nothing; read ExitCode afterwards
		#   see        RunSilently, Run
		def RunSilent()
			This.RunSilently()

		def RunSilentQ()
			This.RunSilent()
			return This

	#-----------------------#
	#  RESULTS              #
	#-----------------------#

	# Returns the text the command wrote to its output, as read after the last run.
	#
	#   returns    a text; an empty text before a run; a list or a number when the return type asked
	#              for one
	#   note       Result and StdOut are the same call; on Windows echo adds a line feed at the end
	#   see        OutputAsLines, Error, RunAndGetOutput
	def Output()
		return @cOutput

		def Result()
			return This.Output()

		def StdOut()
			return This.Output()

	# Returns the output as a list of its non-empty lines, each trimmed.
	#
	#   returns    a list of text; an empty list when there is no output
	#   note       OutputAsList, ResultAsLines and ResultAsList are the same call
	#   warning    raises an error (Bad parameter type for list, Incorrect param type for number)
	#              when the return type is list or number, because the output was already converted
	#   see        Output, ParseOutputAsLines
	def OutputAsLines()
		if @cOutput = ""
			return []
		ok

		_acLines_ = split(@cOutput, char(10))
		# Remove empty lines
		_aResult_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ != ""
				_aResult_ + _cLine_
			ok
		next
		return _aResult_

		def OutputAsList()
			return This.OutputAsLines()

		def ResultAsLines()
			return This.OutputAsLines()

		def ResultAsList()
			return This.OutputAsLines()

	# Returns the text the command wrote to its error stream, as read after the last run.
	#
	#   returns    a text; an empty text before a run
	#   note       StdErr is the same call
	#   see        HasError, Output
	def Error()
		return @cError

		def StdErr()
			return This.Error()

	# Returns the exit code of the last run; -1 before any run.
	#
	#   returns    a number; 0 usually means success
	#   see        Succeeded, Failed
	def ExitCode()
		return @nExitCode

	# TRUE if the command has been run since the call was built or reset.
	#
	#   returns    TRUE or FALSE
	#   see        Run, Reset
	def WasExecuted()
		return @bExecuted

	# TRUE if the command ran and ended with the exit code 0.
	#
	#   returns    TRUE or FALSE; FALSE before any run
	#   note       Success is the same call
	#   see        Failed, ExitCode
	def Succeeded()
		return @bExecuted and @nExitCode = 0

		def Success()
			return This.Succeeded()

	# TRUE if the command did not run or ended with an exit code other than 0.
	#
	#   returns    TRUE or FALSE
	#   see        Succeeded, ExitCode
	def Failed()
		return NOT This.Succeeded()

	# TRUE if the output is not empty.
	#
	#   returns    TRUE or FALSE
	#   see        Output, HasError
	def HasOutput()
		if isString(@cOutput)
			return StzLen(@cOutput) > 0
		ok
		return 1

	# TRUE if the error text is not empty.
	#
	#   returns    TRUE or FALSE
	#   see        Error, HasOutput
	def HasError()
		return StzLen(@cError) > 0

	# Runs the command and returns its output in one step.
	#
	#   returns    a text, or the converted value for the return type
	#   note       GetOutput is the same call
	#   see        Run, Output
	def RunAndGetOutput()
		This.Run()
		return @cOutput

		def GetOutput()
			return This.RunAndGetOutput()

	#-----------------------#
	#  ENVIRONMENT          #
	#-----------------------#

	# Returns the value of an environment variable of this process.
	#
	#   pcVarName   the name of the environment variable
	#   returns     a text; an empty text when the variable does not exist
	#   note        GetEnv and EnvironmentVariable are the same call
	#   see         EngineIsWindows
	def Env(pcVarName)
		return StzEngineSystemEnv(pcVarName)

		def GetEnv(pcVarName)
			return This.Env(pcVarName)

		def EnvironmentVariable(pcVarName)
			return This.Env(pcVarName)

	#-----------------------#
	#  OS DETECTION         #
	#-----------------------#

	# TRUE if the engine reports that this machine runs Windows.
	#
	#   returns    TRUE or FALSE
	#   see        EngineIsLinux, EngineIsMacos
	def EngineIsWindows()
		return StzEngineSystemIsWindows()

	# TRUE if the engine reports that this machine runs Linux.
	#
	#   returns    TRUE or FALSE
	#   see        EngineIsWindows, EngineIsMacos
	def EngineIsLinux()
		return StzEngineSystemIsLinux()

	# TRUE if the engine reports that this machine runs macOS.
	#
	#   returns    TRUE or FALSE
	#   see        EngineIsWindows, EngineIsLinux
	def EngineIsMacos()
		return StzEngineSystemIsMacos()

	#-----------------------#
	#  UTILITIES            #
	#-----------------------#

	# Opens a file in the program the system associates with it, by setting cmd.exe, open or xdg-open as the program and running it silently.
	#
	#   _cFilePath_   the file or folder to open
	#   returns       nothing; use OpenFileQ to chain
	#   warning       not run here: it starts a viewer on the machine; it overwrites the program and
	#                 arguments of the call, and StzOpenInDefaultApp is the safe form that refuses a
	#                 path that does not exist
	#   see           StzOpenInDefaultApp, RunSilently
	def OpenFile(_cFilePath_)
		if isWindows()
			_cFilePath_ = StzReplace(_cFilePath_, "\", "/")
			This.SetProgram("cmd.exe")
			This.SetArgs(["/c", "start", "", _cFilePath_])
		but isMacOS()
			This.SetProgram("open")
			This.SetArgs([_cFilePath_])
		else
			This.SetProgram("xdg-open")
			This.SetArgs([_cFilePath_])
		ok
		This.RunSilently()

		def OpenFileQ(_cFilePath_)
			This.OpenFile(_cFilePath_)
			return This

	# Forgets the results of the last run and the arguments, so the call can be reused.
	#
	#   returns    nothing; use ResetQ to chain
	#   note       the program stays set, so after a Reset the call still holds the program (cmd.exe
	#              for a command that was wrapped)
	#   see        Run, ClearArgs
	def Reset()
		@acArgs = []
		@bArgvMode = 0
		@cOutput = ""
		@cError = ""
		@nExitCode = -1
		@bExecuted = 0
		@bRunSilentMode = 0

		def ResetQ()
			This.Reset()
			return This

	# Wraps the command to run through the shell when it holds a shell operator or starts with a shell built-in such as echo or dir.
	#
	#   returns    the object itself, so calls chain
	#   note       init and Run call it for you; the shell is cmd.exe /c on Windows and sh -c
	#              elsewhere; UseShellIfNeededQ is the same call
	#   see        init, Run
	def UseShellIfNeeded()
		# Detect if command needs shell wrapper
		_cCmd_ = @cCommandString

		# Handle empty command
		if _cCmd_ = "" or trim(_cCmd_) = ""
			return This
		ok

		_bNeedsShell_ = 0

		# Check for shell operators
		if StzFindFirst(" > ", _cCmd_) > 0 or StzFindFirst(" < ", _cCmd_) > 0 or
		   StzFindFirst("|", _cCmd_) > 0 or StzFindFirst("&&", _cCmd_) > 0 or
		   StzFindFirst("||", _cCmd_) > 0
			_bNeedsShell_ = 1
		ok

		# Check for single & (but not &&)
		if StzFindFirst("&", _cCmd_) > 0 and StzFindFirst("&&", _cCmd_) = 0
			_bNeedsShell_ = 1
		ok

		# Check for shell built-in commands
		_aWords_ = split(_cCmd_, " ")
		if len(_aWords_) > 0
			_cFirstWord_ = StzLower(trim(_aWords_[1]))
			if find(ShellBuiltInCommands, _cFirstWord_) > 0
				_bNeedsShell_ = 1
			ok
		ok

		if _bNeedsShell_
			# Rebuild command with shell wrapper
			if isWindows()
				@cCommandString = "cmd.exe /c " + _cCmd_
			else
				@cCommandString = "sh -c " + _cCmd_
			ok
			# Re-parse with new command string
			This.ParseCommandString(@cCommandString)
		ok

		return This

		def UseShellIfNeededQ()
			This.UseShellIfNeeded()
			return This
