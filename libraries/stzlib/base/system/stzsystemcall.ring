#------------------------------#
#  SOFTANZA SYSTEM CALL CLASS  #
#------------------------------#

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

func StzSystemCallQ(pcProgram)
	return new stzSystemCall(pcProgram)

func StzSystemCallQXT(pcProgram, cReturnType)
	oCall = new stzSystemCall(pcProgram)
	oCall.SetReturnType(cReturnType)
	return oCall

func stzsystem(pcCommand)
	pcCommand = NormalizePathsInCommand(pcCommand)
	
	_oSysCall_ = new stzSystemCall(pcCommand)
	_oSysCall_.HideConsole()
	return _oSysCall_.RunAndGetOutput()

func NormalizePathsInCommand(pcCommand)
	# Convert slashes in paths only, not in command flags
	cResult = ""
	aTokens = split(pcCommand, " ")
	
	for i = 1 to len(aTokens)
		cToken = aTokens[i]
		
		if isWindows()
			# Convert / to \ only if not a flag (doesn't start with /)
			if substr(cToken, "/") > 0 and cToken[1] != "/"
				cToken = substr(cToken, "/", "\")
			ok
		else
			# Convert \ to / for Unix paths
			if substr(cToken, "\") > 0
				cToken = substr(cToken, "\", "/")
			ok
		ok
		
		cResult += cToken
		if i < len(aTokens)
			cResult += " "
		ok
	next
	
	return cResult


func stzsystemXT(pcProgram, pacArgs)
	_oSysCall_ = new stzSystemCall(pcProgram)
	_oSysCall_.SetArgs(pacArgs)
	_oSysCall_.HideConsole()
	return _oSysCall_.RunAndGetOutput()

func stzsystemSilent(pcProgram, pacArgs)
	_oSysCall_ = new stzSystemCall(pcProgram)
	_oSysCall_.SetArgs(pacArgs)
	_oSysCall_.RunSilently()


# THE CLASS
#===========

class stzSystemCall
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

	def ParseCommandString(cCmd)
		# Check for return type suffix (@RETURN:type)
		nReturnPos = substr(cCmd, "@RETURN:")
		if nReturnPos > 0
			# Extract return type
			cReturnPart = substr(cCmd, nReturnPos + 8)  # After "@RETURN:"
			@cReturnType = trim(cReturnPart)
			# Remove suffix from command
			cCmd = trim(left(cCmd, nReturnPos - 1))
		ok
		
		# Handle quoted arguments properly
		@acArgs = []
		cCmd = trim(cCmd)
		
		# Extract first token (program name)
		nPos = substr(cCmd, " ")
		if nPos = 0
			@cProgram = cCmd
			return
		ok
		
		@cProgram = left(cCmd, nPos - 1)
		cRest = trim(substr(cCmd, nPos + 1))
		
		# Parse remaining arguments respecting quotes
		bInQuote = FALSE
		cCurrent = ""
		
		for i = 1 to len(cRest)
			c = cRest[i]
			
			if c = '"'
				bInQuote = NOT bInQuote
			but c = " " and NOT bInQuote
				if cCurrent != ""
					@acArgs + cCurrent
					cCurrent = ""
				ok
			else
				cCurrent += c
			ok
		next
		
		if cCurrent != ""
			@acArgs + cCurrent
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
		if @bRunSilentMode and isWindows() and NOT (@cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[2] = "start")
			This.RunWindowsSilent()
			return NULL
		ok
	
		_oQStrList_ = new QStringList()

		# Special handling for cmd.exe /c - combine everything after /c into single command
		if @cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[1] = "/c"
			_oQStrList_.append("/c")
			# Combine all remaining args into one command string
			cCommand = ""
			for i = 2 to len(@acArgs)
				if i > 2
					cCommand += " "
				ok
				cArg = @acArgs[i]
				# Don't quote shell operators
				if cArg = "&" or cArg = "&&" or cArg = "|" or cArg = "||"
					cCommand += cArg
				# Quote paths with spaces
				elseif substr(cArg, " ") > 0
					cCommand += '"' + cArg + '"'
				else
					cCommand += cArg
				ok
			next
			_oQStrList_.append(cCommand)
		else
			# Normal argument passing
			for i = 1 to len(@acArgs)
				_oQStrList_.append(@acArgs[i])
			next
		ok

		_oQProcess_ = new QProcess("")
		_oQProcess_.setProcessChannelMode(0)
		_oQProcess_.start(@cProgram, _oQStrList_, 3)
		
		if NOT _oQProcess_.waitForFinished(@nTimeout)
			@bExecuted = FALSE
			@nExitCode = -1
			return NULL
		ok
		
		@bExecuted = TRUE
		@nExitCode = _oQProcess_.ExitCode()
		
		if @bCaptureOutput
			@cOutput = QByteArraytoString(_oQProcess_.ReadAllStandardOutput())
			# Auto-convert output based on return type
			This.ConvertOutputByType()
		ok
		
		if @bCaptureError
			@cError = QByteArraytoString(_oQProcess_.ReadAllStandardError())
			if @cError = "" and @nExitCode != 0 and isString(@cOutput) and @cOutput != ""
				@cError = @cOutput
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

	def SetReturnType(cType)
		cType = lower(cType)
		if NOT (cType = "string" or cType = "number" or cType = "list")
			stzraise("Return type must be 'string', 'number', or 'list'")
		ok
		@cReturnType = cType
		return This

		def SetReturnTypeQ(cType)
			This.SetReturnType(cType)
			return This

	def ReturnType()
		return @cReturnType

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
		
		aLines = split(@cOutput, NL)
		aResult = []
		for cLine in aLines
			cLine = trim(cLine)
			if cLine != ""
				aResult + cLine
			ok
		next
		return aResult

	def ParseOutputAsNumber()
		if NOT isString(@cOutput) or @cOutput = ""
			return 0
		ok
		
		cOutput = trim(@cOutput)
		# Try to extract first number from output
		for i = 1 to len(cOutput)
			c = cOutput[i]
			if (c >= "0" and c <= "9") or c = "-" or c = "."
				# Found start of number, extract it
				cNum = ""
				for j = i to len(cOutput)
					c2 = cOutput[j]
					if (c2 >= "0" and c2 <= "9") or c2 = "." or c2 = "-"
						cNum += c2
					else
						exit
					ok
				next
				return 0 + cNum  # Convert to number
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
		if CheckParam()
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
	
	def SetParam(cParam, cValue)
		# Convert forward slashes to backslashes on Windows for any path-like value
		if isWindows() and (substr(cValue, "/") > 0 or substr(cValue, "\") > 0)
			# If it looks like a path (contains slashes), convert to backslashes
			cValue = substr(cValue, "/", "\")
		ok
		
		for i = 1 to len(@acArgs)
			@acArgs[i] = substr(@acArgs[i], "{" + cParam + "}", cValue)
		next
	
	def SetParams(aParams)
		for aParam in aParams
			This.SetParam(aParam[1], aParam[2])
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

	def RunWindowsSilent()
		cOriginalProgram = @cProgram
		aOriginalArgs = @acArgs
		
		cCmd = '"' + cOriginalProgram + '"'
		for arg in aOriginalArgs
			if substr(arg, " ") > 0
				cCmd += ' "' + arg + '"'
			else
				cCmd += " " + arg
			ok
		next
		
		_oQStrList_ = new QStringList()
		_oQStrList_.append("/c")
		_oQStrList_.append(cCmd + " >NUL 2>&1")
		
		_oQProcess_ = new QProcess("")
		_oQProcess_.setProcessChannelMode(2)
		_oQProcess_.start("cmd.exe", _oQStrList_, 3)
		_oQProcess_.waitForFinished(@nTimeout)
		
		@bExecuted = TRUE
		@nExitCode = _oQProcess_.ExitCode()

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
		
		aLines = split(@cOutput, NL)
		# Remove empty lines
		aResult = []
		for cLine in aLines
			cLine = trim(cLine)
			if cLine != ""
				aResult + cLine
			ok
		next
		return aResult

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
		return len(@cOutput) > 0

	def HasError()
		return len(@cError) > 0

	def RunAndGetOutput()
		This.Run()
		return @cOutput

		def GetOutput()
			return This.RunAndGetOutput()

	#-----------------------#
	#  UTILITIES            #
	#-----------------------#

	def OpenFile(cFilePath)
		if isWindows()
			cFilePath = substr(cFilePath, "\", "/")
			This.SetProgram("cmd.exe")
			This.SetArgs(["/c", "start", "", cFilePath])
		but isMacOS()
			This.SetProgram("open")
			This.SetArgs([cFilePath])
		else
			This.SetProgram("xdg-open")
			This.SetArgs([cFilePath])
		ok
		This.RunSilently()

		def OpenFileQ(cFilePath)
			This.OpenFile(cFilePath)
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
		cCmd = @cCommandString
		bNeedsShell = FALSE
		
		# Check for shell operators (but not command-line flags)
		# Look for > or < only when followed by space or filename (not part of flag)
		if substr(cCmd, " > ") > 0 or substr(cCmd, " < ") > 0 or
		   substr(cCmd, ">") = 1 or substr(cCmd, "<") = 1 or
		   substr(cCmd, "|") > 0 or substr(cCmd, "&&") > 0 or
		   substr(cCmd, "||") > 0
			bNeedsShell = TRUE
		ok
		
		# Check for single & (but not &&)
		if substr(cCmd, "&") > 0 and substr(cCmd, "&&") = 0
			bNeedsShell = TRUE
		ok
		
		# Check for shell built-in commands
		cFirstWord = lower(trim(split(cCmd, " ")[1]))
		if find(ShellBuiltInCommands, cFirstWord) > 0
			bNeedsShell = TRUE
		ok
		
		if bNeedsShell
			# Rebuild command with shell wrapper
			if isWindows()
				@cCommandString = "cmd.exe /c " + cCmd
			else
				@cCommandString = "sh -c " + cCmd
			ok
			# Re-parse with new command string
			This.ParseCommandString(@cCommandString)
		ok
		
		return This
	
		def UseShellIfNeededQ()
			This.UseShellIfNeeded()
			return This
