func StzSystemCallQ(pcProgram)
	return new stzSystemCall(pcProgram)

# Convenience functions using the class

func stzsystem(pcProgram, pacArgs)
	_oSysCall_ = new stzSystemCall(pcProgram)
	_oSysCall_.SetArgs(pacArgs)
	_oSysCall_.HideConsole()
	return _oSysCall_.RunAndGetOutput()

func stzsystemSilent(pcProgram, pacArgs)
	_oSysCall_ = new stzSystemCall(pcProgram)
	_oSysCall_.SetArgs(pacArgs)
	_oSysCall_.RunSilently()

#-------------#
#  THE CLASS  #
#-------------#

class stzSysCall for stzSystemCall

class stzSystemCall
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

	def init(pcProgramOrCommand)
		if CheckParam()
			if NOT isString(pcProgramOrCommand)
				stzraise("Program must be a string!")
			ok
		ok
		
		# Check if it's a named command from syscmd()
		if substr(pcProgramOrCommand, 1, 1) = ":"
			cCommandName = substr(pcProgramOrCommand, 2)
			This.LoadFromSysCmd(cCommandName)
		else
			@cProgram = pcProgramOrCommand
		ok
	
	def LoadFromSysCmd(cCommandName)
		aCmd = syscmd(":" + cCommandName)
		
		# Get platform-specific command
		aPlatformCmd = NULL
		if isWindows() and haskey(aCmd, :windows)
			aPlatformCmd = aCmd[:windows]
		but isMacOS() and haskey(aCmd, :mac)
			aPlatformCmd = aCmd[:mac]
		but haskey(aCmd, :unix)
			aPlatformCmd = aCmd[:unix]
		ok
		
		if aPlatformCmd = NULL
			stzraise("Command not supported on this platform: " + cCommandName)
		ok
		
		@cProgram = aPlatformCmd[1]
		@acArgs = aPlatformCmd[2]

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
		# Replace {param} placeholders in args
		for i = 1 to len(@acArgs)
			@acArgs[i] = substr(@acArgs[i], "{" + cParam + "}", cValue)
		next
		
		def SetParamQ(cParam, cValue)
			This.SetParam(cParam, cValue)
			return This
	
	def SetParams(aParams)
		# aParams = [[:source, "file.txt"], [:dest, "backup.txt"]]
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

	def Run()
		if @cProgram = ""
			stzraise("No program specified!")
		ok

		# Handle silent mode with output suppression
		# Skip for cmd.exe start commands (already silent)
		if @bRunSilentMode and isWindows() and NOT (@cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[2] = "start")
			This.RunWindowsSilent()
			return NULL
		ok

		_oQStrList_ = new QStringList()
		nLen = len(@acArgs)
		for i = 1 to nLen
			_oQStrList_.append(@acArgs[i])
		next

		_oQProcess_ = new QProcess("")
		
		# Always use separate channels for proper capture
		_oQProcess_.setProcessChannelMode(0)  # SeparateChannels
		
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
		ok
		
		if @bCaptureError
			@cError = QByteArraytoString(_oQProcess_.ReadAllStandardError())
			# Windows cmd often writes errors to stdout
			if @cError = "" and @nExitCode != 0 and @cOutput != ""
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

	def RunWindowsSilent()
		# Windows-specific silent execution with output suppression
		cOriginalProgram = @cProgram
		aOriginalArgs = @acArgs
		
		# Build command string
		cCmd = '"' + cOriginalProgram + '"'
		for arg in aOriginalArgs
			if substr(arg, " ") > 0
				cCmd += ' "' + arg + '"'
			else
				cCmd += " " + arg
			ok
		next
		
		# Wrap in cmd with output suppression
		_oQStrList_ = new QStringList()
		_oQStrList_.append("/c")
		_oQStrList_.append(cCmd + " >NUL 2>&1")
		
		_oQProcess_ = new QProcess("")
		_oQProcess_.setProcessChannelMode(2)  # Merged
		_oQProcess_.start("cmd.exe", _oQStrList_, 3)
		_oQProcess_.waitForFinished(@nTimeout)
		
		@bExecuted = TRUE
		@nExitCode = _oQProcess_.ExitCode()

	def Output()
		return @cOutput

		def Result()
			return This.Output()

		def StdOut()
			return This.Output()

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

	def OpenFile(cFilePath)
		# Normalize path separators for Windows
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
