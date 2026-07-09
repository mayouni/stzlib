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

_ShellBuiltInCommands_ = [
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
			if StzFindFirst(_cToken_, "/") > 0 and _cToken_[1] != "/"
				_cToken_ = StzReplace(_cToken_, "/", "\")
			ok
		else
			# Convert \ to / for Unix paths
			if StzFindFirst(_cToken_, "\") > 0
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

class stzSystemCall from stzObject
	@cCommandString = ""
	@cProgram = ""
	@acArgs = []

	@nTimeout = 30000
	@bCaptureOutput = TRUE
	@bCaptureError = TRUE
	@bShowConsole = FALSE
	@cOutput = ""
	@cError = ""
	@nExitCode = -1
	@bExecuted = FALSE
	@bRunSilentMode = FALSE

	# Return type control for Sys() commands
	@cReturnType = "string"  # "string", "number", or "list"

	def init(pcCommandString)
		if NOT isString(pcCommandString)
			stzraise("Command must be a string!")
		ok

		@cCommandString = pcCommandString
		This.ParseCommandString(pcCommandString)
		This.UseShellIfNeeded()

	def ParseCommandString(_cCmd_)
		# Check for return type suffix (@RETURN:type)
		_nReturnPos_ = StzFindFirst(_cCmd_, "@RETURN:")
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
		_nPos_ = StzFindFirst(_cCmd_, " ")
		if _nPos_ = 0
			@cProgram = _cCmd_
			return
		ok

		_oCmd2_ = new stzString(_cCmd_)
		@cProgram = _oCmd2_.Section(1, _nPos_ - 1)
		_cRest_ = trim(_oCmd2_.Section(_nPos_ + 1, _oCmd2_.NumberOfChars()))

		# Parse remaining arguments respecting quotes
		_bInQuote_ = FALSE
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

	def Run()

		if @cProgram = ""
			stzraise("No program specified!")
		ok

		# Use shell if command contains shell operators
		This.UseShellIfNeeded()

		# Handle silent mode
		if @bRunSilentMode
			This.RunEngineSilent()
			return NULL
		ok

		_cFullCmd_ = _BuildCommandLine()

		# Use engine for hidden console execution
		if NOT @bShowConsole
			# Engine-backed: no console window, direct stdout capture
			@cOutput = StzEngineSystemRun(_cFullCmd_)
			@nExitCode = 0
			if @cOutput = "" and @bCaptureError
				# If no output, might have failed
				@nExitCode = StzEngineSystemExec(_cFullCmd_)
				if @nExitCode != 0
					@cError = "Command failed with exit code " + @nExitCode
				ok
			ok
			@bExecuted = TRUE

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
			@bExecuted = TRUE

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

		def Execute()
			This.Run()

		def ExecuteQ()
			This.Execute()
			return This

		def Exec()
			This.Run()

		def ExecQ()
			This.Exec()
			return This

	#-----------------------#
	#  RETURN TYPE CONTROL  #
	#-----------------------#

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
			if StzFindFirst(@cProgram, " ") > 0
				_cCmd_ = '"' + @cProgram + '"'
			else
				_cCmd_ = @cProgram
			ok
			_nArgsLen_2 = len(@acArgs)
			for i = 1 to _nArgsLen_2
				if StzFindFirst(@acArgs[i], " ") > 0
					_cCmd_ += ' "' + @acArgs[i] + '"'
				else
					_cCmd_ += " " + @acArgs[i]
				ok
			next
		ok
		return _cCmd_

	def ConvertOutputByType()
		if NOT isString(@cOutput)
			return  # Already converted or empty
		ok

		if @cReturnType = "list"
			@cOutput = This.ParseOutputAsLines()
		but @cReturnType = "number"
			@cOutput = This.ParseOutputAsNumber()
		ok
		# "string" type needs no conversion

	def ParseOutputAsLines()
		if NOT isString(@cOutput) or @cOutput = ""
			return []
		ok

		_acLines_ = split(@cOutput, NL)
		_aResult_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if _cLine_ != ""
				_aResult_ + _cLine_
			ok
		next
		return _aResult_

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

	def Program()
		return @cProgram

	def SetProgram(pcProgram)
		@cProgram = pcProgram

		def SetProgramQ(pcProgram)
			This.SetProgram(pcProgram)
			return This

	def Args()
		return @acArgs

	def SetArgs(pacArgs)
		if CheckingParams()
			if NOT (isList(pacArgs) and IsListOfStrings(pacArgs))
				stzraise("Args must be a list of strings!")
			ok
		ok
		@acArgs = pacArgs

		def WithArgs(pacArgs)
			This.SetArgs(pacArgs)

		def SetArgsQ(pacArgs)
			This.SetArgs(pacArgs)
			return This

		def WithArgsQ(pacArgs)
			return This.SetArgsQ(pacArgs)

	def SetParam(cParam, _cValue_)
		# Convert forward slashes to backslashes on Windows for path-like values
		if isWindows() and (StzFindFirst(_cValue_, "/") > 0 or StzFindFirst(_cValue_, "\") > 0)
			_cValue_ = StzReplace(_cValue_, "/", "\")
		ok

		_nArgsLen_ = len(@acArgs)
		for i = 1 to _nArgsLen_
			@acArgs[i] = StzReplace(@acArgs[i], "{" + cParam + "}", _cValue_)
		next

	def SetParams(aParams)
		_nLen_ = len(aParams)
		for i = 1 to _nLen_
			This.SetParam(aParams[i][1], aParams[i][2])
		next

		def WithParams(aParams)
			This.SetParams(aParams)

		def SetParamsQ(aParams)
			This.SetParams(aParams)
			return This

		def WithParamsQ(aParams)
			return This.SetParamsQ(aParams)

	def AddArg(pcArg)
		@acArgs + pcArg

		def WithArg(pcArg)
			This.AddArg(pcArg)

		def AddArgQ(pcArg)
			This.AddArg(pcArg)
			return This

		def WithArgQ(pcArg)
			return This.AddArgQ(pcArg)

	def ClearArgs()
		@acArgs = []

		def ClearArgsQ()
			This.ClearArgs()
			return This

	def SetTimeout(nMilliseconds)
		@nTimeout = nMilliseconds

		def WithTimeout(nMilliseconds)
			This.SetTimeout(nMilliseconds)

		def SetTimeoutQ(nMilliseconds)
			This.SetTimeout(nMilliseconds)
			return This

		def WithTimeoutQ(nMilliseconds)
			return This.SetTimeoutQ(nMilliseconds)

	def Timeout()
		return @nTimeout

	#-----------------------#
	#  OUTPUT CONTROL       #
	#-----------------------#

	def CaptureOutput()
		@bCaptureOutput = TRUE

		def CaptureOutputQ()
			This.CaptureOutput()
			return This

	def DontCaptureOutput()
		@bCaptureOutput = FALSE

		def DontCaptureOutputQ()
			This.DontCaptureOutput()
			return This

	def CaptureError()
		@bCaptureError = TRUE

		def CaptureErrorQ()
			This.CaptureError()
			return This

	def DontCaptureError()
		@bCaptureError = FALSE

		def DontCaptureErrorQ()
			This.DontCaptureError()
			return This

	def ShowConsole()
		@bShowConsole = TRUE

		def ShowConsoleQ()
			This.ShowConsole()
			return This

	def HideConsole()
		@bShowConsole = FALSE

		def Silent()
			This.HideConsole()

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

	def RunEngineSilent()
		_cFullCmd_ = _BuildCommandLine()
		# Engine exec: no console, no output capture, just exit code
		@nExitCode = StzEngineSystemExec(_cFullCmd_)
		@bExecuted = TRUE

	def RunSilently()
		@bRunSilentMode = TRUE
		@bShowConsole = FALSE
		@bCaptureOutput = FALSE
		@bCaptureError = FALSE
		This.Run()
		@bRunSilentMode = FALSE

		def RunSilentlyQ()
			This.RunSilently()
			return This

		def RunSilent()
			This.RunSilently()

		def RunSilentQ()
			This.RunSilent()
			return This

	#-----------------------#
	#  RESULTS              #
	#-----------------------#

	def Output()
		return @cOutput

		def Result()
			return This.Output()

		def StdOut()
			return This.Output()

	def OutputAsLines()
		if @cOutput = ""
			return []
		ok

		_acLines_ = split(@cOutput, NL)
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

	def Error()
		return @cError

		def StdErr()
			return This.Error()

	def ExitCode()
		return @nExitCode

	def WasExecuted()
		return @bExecuted

	def Succeeded()
		return @bExecuted and @nExitCode = 0

		def Success()
			return This.Succeeded()

	def Failed()
		return NOT This.Succeeded()

	def HasOutput()
		if isString(@cOutput)
			return StzLen(@cOutput) > 0
		ok
		return TRUE

	def HasError()
		return StzLen(@cError) > 0

	def RunAndGetOutput()
		This.Run()
		return @cOutput

		def GetOutput()
			return This.RunAndGetOutput()

	#-----------------------#
	#  ENVIRONMENT          #
	#-----------------------#

	def Env(pcVarName)
		return StzEngineSystemEnv(pcVarName)

		def GetEnv(pcVarName)
			return This.Env(pcVarName)

		def EnvironmentVariable(pcVarName)
			return This.Env(pcVarName)

	#-----------------------#
	#  OS DETECTION         #
	#-----------------------#

	def EngineIsWindows()
		return StzEngineSystemIsWindows()

	def EngineIsLinux()
		return StzEngineSystemIsLinux()

	def EngineIsMacos()
		return StzEngineSystemIsMacos()

	#-----------------------#
	#  UTILITIES            #
	#-----------------------#

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

	def Reset()
		@acArgs = []
		@cOutput = ""
		@cError = ""
		@nExitCode = -1
		@bExecuted = FALSE
		@bRunSilentMode = FALSE

		def ResetQ()
			This.Reset()
			return This

	def UseShellIfNeeded()
		# Detect if command needs shell wrapper
		_cCmd_ = @cCommandString

		# Handle empty command
		if _cCmd_ = "" or trim(_cCmd_) = ""
			return This
		ok

		_bNeedsShell_ = FALSE

		# Check for shell operators
		if StzFindFirst(_cCmd_, " > ") > 0 or StzFindFirst(_cCmd_, " < ") > 0 or
		   StzFindFirst(_cCmd_, "|") > 0 or StzFindFirst(_cCmd_, "&&") > 0 or
		   StzFindFirst(_cCmd_, "||") > 0
			_bNeedsShell_ = TRUE
		ok

		# Check for single & (but not &&)
		if StzFindFirst(_cCmd_, "&") > 0 and StzFindFirst(_cCmd_, "&&") = 0
			_bNeedsShell_ = TRUE
		ok

		# Check for shell built-in commands
		_aWords_ = split(_cCmd_, " ")
		if len(_aWords_) > 0
			_cFirstWord_ = StzLower(trim(_aWords_[1]))
			if find(_ShellBuiltInCommands_, _cFirstWord_) > 0
				_bNeedsShell_ = TRUE
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
