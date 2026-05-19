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

func StzSystemCallQ(pcProgram)
	return new stzSystemCall(pcProgram)

func StzSystemCallQXT(pcProgram, cReturnType)
	oCall = new stzSystemCall(pcProgram)
	oCall.SetReturnType(cReturnType)
	return oCall

func StzSystem(pcCommand)
	pcCommand = NormalizePathsInCommand(pcCommand)

	_oSysCall_ = new stzSystemCall(pcCommand)
	_oSysCall_.HideConsole()
	return _oSysCall_.RunAndGetOutput()

func StzSystemSilent(pcCommand) # No output!
	pcCommand = NormalizePathsInCommand(pcCommand)

	_oSysCall_ = new stzSystemCall(pcCommand)
	_oSysCall_.HideConsole()
	_oSysCall_.RunSilently()

func NormalizePathsInCommand(pcCommand)
	# Convert slashes in paths only, not in command flags
	cResult = ""
	aTokens = split(pcCommand, " ")
	nLen = len(aTokens)
	for i = 1 to nLen
		cToken = aTokens[i]

		if isWindows()
			# Convert / to \ only if not a flag (doesn't start with /)
			if StzFind(cToken, "/") > 0 and cToken[1] != "/"
				cToken = StzReplace(cToken, "/", "\")
			ok
		else
			# Convert \ to / for Unix paths
			if StzFind(cToken, "\") > 0
				cToken = StzReplace(cToken, "\", "/")
			ok
		ok

		cResult += cToken
		if i < len(aTokens)
			cResult += " "
		ok
	next

	return cResult


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
		nReturnPos = StzFind(cCmd, "@RETURN:")
		if nReturnPos > 0
			# Extract return type
			oCmd = new stzString(cCmd)
			@cReturnType = trim(oCmd.Section(nReturnPos + 8, oCmd.NumberOfChars()))
			# Remove suffix from command
			cCmd = trim(oCmd.Section(1, nReturnPos - 1))
		ok

		# Handle quoted arguments properly
		@acArgs = []
		cCmd = trim(cCmd)

		# Extract first token (program name)
		nPos = StzFind(cCmd, " ")
		if nPos = 0
			@cProgram = cCmd
			return
		ok

		oCmd2 = new stzString(cCmd)
		@cProgram = oCmd2.Section(1, nPos - 1)
		cRest = trim(oCmd2.Section(nPos + 1, oCmd2.NumberOfChars()))

		# Parse remaining arguments respecting quotes
		bInQuote = FALSE
		cCurrent = ""

		oRest = new stzString(cRest)
		acChars = oRest.Chars()
		nLen = len(acChars)

		for i = 1 to nLen
			c = acChars[i]

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
		if @bRunSilentMode
			This.RunEngineSilent()
			return NULL
		ok

		cFullCmd = _BuildCommandLine()

		# Use engine for hidden console execution
		if NOT @bShowConsole
			# Engine-backed: no console window, direct stdout capture
			@cOutput = StzEngineSystemRun(cFullCmd)
			@nExitCode = 0
			if @cOutput = "" and @bCaptureError
				# If no output, might have failed
				@nExitCode = StzEngineSystemExec(cFullCmd)
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
			cOutFile = ""
			cErrFile = ""

			if @bCaptureOutput or @bCaptureError
				cTmpBase = tempname()
				cOutFile = cTmpBase + "_out.tmp"
				cErrFile = cTmpBase + "_err.tmp"
				cFullCmd += ' >"' + cOutFile + '" 2>"' + cErrFile + '"'
			ok

			@nExitCode = system(cFullCmd)
			@bExecuted = TRUE

			if @bCaptureOutput and cOutFile != ""
				try
					@cOutput = read(cOutFile)
					remove(cOutFile)
				catch
					@cOutput = ""
				done
				This.ConvertOutputByType()
			ok

			if @bCaptureError and cErrFile != ""
				try
					@cError = read(cErrFile)
					remove(cErrFile)
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

	def SetReturnType(cType)
		cType = StzLower(cType)
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

	def _BuildCommandLine()
		cCmd = ""
		if @cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[1] = "/c"
			cCmd = "cmd.exe /c "
			cCommand = ""
			for i = 2 to len(@acArgs)
				cArg = @acArgs[i]
				if i > 2
					cCommand += " "
				ok
				if cArg = "&" or cArg = "&&" or cArg = "|" or cArg = "||"
					nCmdLen = StzLen(cCommand)
					if nCmdLen > 0
						oTmp = new stzString(cCommand)
						acTmpChars = oTmp.Chars()
						if acTmpChars[nCmdLen] != " "
							cCommand += " "
						ok
					ok
					cCommand += cArg
				else
					cCommand += cArg
				ok
			next
			cCmd += cCommand
		else
			if StzFind(@cProgram, " ") > 0
				cCmd = '"' + @cProgram + '"'
			else
				cCmd = @cProgram
			ok
			for i = 1 to len(@acArgs)
				if StzFind(@acArgs[i], " ") > 0
					cCmd += ' "' + @acArgs[i] + '"'
				else
					cCmd += " " + @acArgs[i]
				ok
			next
		ok
		return cCmd

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

		acLines = split(@cOutput, NL)
		aResult = []
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
			if cLine != ""
				aResult + cLine
			ok
		next
		return aResult

	def ParseOutputAsNumber()
		if NOT isString(@cOutput) or @cOutput = ""
			return 0
		ok

		cOut = trim(@cOutput)
		oOut = new stzString(cOut)
		acChars = oOut.Chars()
		nLen = len(acChars)

		# Try to extract first number from output
		for i = 1 to nLen
			c = acChars[i]
			if (c >= "0" and c <= "9") or c = "-" or c = "."
				# Found start of number, extract it
				cNum = ""
				for j = i to nLen
					c2 = acChars[j]
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

	def SetParam(cParam, cValue)
		# Convert forward slashes to backslashes on Windows for path-like values
		if isWindows() and (StzFind(cValue, "/") > 0 or StzFind(cValue, "\") > 0)
			cValue = StzReplace(cValue, "/", "\")
		ok

		for i = 1 to len(@acArgs)
			@acArgs[i] = StzReplace(@acArgs[i], "{" + cParam + "}", cValue)
		next

	def SetParams(aParams)
		nLen = len(aParams)
		for i = 1 to nLen
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
		cFullCmd = _BuildCommandLine()
		# Engine exec: no console, no output capture, just exit code
		@nExitCode = StzEngineSystemExec(cFullCmd)
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

		acLines = split(@cOutput, NL)
		# Remove empty lines
		aResult = []
		nLen = len(acLines)

		for i = 1 to nLen
			cLine = trim(acLines[i])
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

	def OpenFile(cFilePath)
		if isWindows()
			cFilePath = StzReplace(cFilePath, "\", "/")
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

		# Handle empty command
		if cCmd = "" or trim(cCmd) = ""
			return This
		ok

		bNeedsShell = FALSE

		# Check for shell operators
		if StzFind(cCmd, " > ") > 0 or StzFind(cCmd, " < ") > 0 or
		   StzFind(cCmd, "|") > 0 or StzFind(cCmd, "&&") > 0 or
		   StzFind(cCmd, "||") > 0
			bNeedsShell = TRUE
		ok

		# Check for single & (but not &&)
		if StzFind(cCmd, "&") > 0 and StzFind(cCmd, "&&") = 0
			bNeedsShell = TRUE
		ok

		# Check for shell built-in commands
		aWords = split(cCmd, " ")
		if len(aWords) > 0
			cFirstWord = StzLower(trim(aWords[1]))
			if find(ShellBuiltInCommands, cFirstWord) > 0
				bNeedsShell = TRUE
			ok
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
