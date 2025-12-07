#------------------------------#
#  SOFTANZA SYSTEM CALL CLASS  #
#------------------------------#

# GLOAB FUNCTIONS
#=================

func StzSystemCallQ(pcProgram)
	return new stzSystemCall(pcProgram)

func stzsystem(pcProgram, pacArgs)
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
	
	# Sandbox attributes
	@cSandboxRoot = "./systest"
	@cWorkspace = ""
	@bUseSandbox = TRUE
	@bAutoApprove = FALSE
	@aFileSnapshot = []
	@cOriginalDir = ""

	def init(pcCommandString)
		if NOT isString(pcCommandString)
			stzraise("Command must be a string!")
		ok
		
		@cCommandString = pcCommandString
		This.ParseCommandString(pcCommandString)

	def ParseCommandString(cCmd)
		# Split "program arg1 arg2" into parts
		aParts = split(cCmd, " ")
		@cProgram = aParts[1]
		@acArgs = []
		for i = 2 to len(aParts)
			@acArgs + aParts[i]
		next

	#-----------------#
	#  SANDBOX MODES  #
	#-----------------#
	
	def EnableSandbox()
		@bUseSandbox = TRUE
		return This

	def DisableSandbox()
		@bUseSandbox = FALSE
		return This
	
	def SetAutoApprove(bAuto)
		@bAutoApprove = bAuto
		return This
	
	def SetSandboxRoot(cPath)
		@cSandboxRoot = cPath
		return This

	#-------------------#
	#  MAIN EXECUTION  #
	#-------------------#

	def Run()
		if @cProgram = ""
			stzraise("No program specified!")
		ok
	
		# Validate all file references in args BEFORE doing anything
		for cArg in @acArgs
			# Skip command flags
			if left(cArg, 1) = "/" or left(cArg, 1) = "-"
				loop
			ok
			
			# Check if it looks like a file path (has extension)
			if substr(cArg, ".") > 0
				# Extract directory if present
				cPath = substr(cArg, "\", "/")
				nPos = 0
				for i = len(cPath) to 1 step -1
					if cPath[i] = "/"
						nPos = i
						exit
					ok
				next
				
				if nPos > 0
					cDir = left(cPath, nPos - 1)
					if NOT isdir(cDir)
						stzraise("Directory does not exist: " + cDir)
					ok
				ok
			ok
		next
	
		if @bUseSandbox
			return This.RunInSandbox()
		else
			return This.ExecuteDirect()
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

	def ExecuteDirect()
		# Handle silent mode
		if @bRunSilentMode and isWindows() and NOT (@cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[2] = "start")
			This.RunWindowsSilent()
			return NULL
		ok
	
		_oQStrList_ = new QStringList()
		
		# Special handling for cmd.exe - combine args after /c into single string
		if @cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[1] = "/c"
			_oQStrList_.append("/c")
			# Combine remaining args into single command string
			cCommand = ""
			for i = 2 to len(@acArgs)
				if i > 2
					cCommand += " "
				ok
				if substr(@acArgs[i], " ") > 0
					cCommand += '"' + @acArgs[i] + '"'
				else
					cCommand += @acArgs[i]
				ok
			next
			_oQStrList_.append(cCommand)
			
			# DEBUG
			//? "DEBUG ExecuteDirect: Final QStringList:"
			//? "  Arg 0: " + _oQStrList_.at(0)
			//? "  Arg 1: " + _oQStrList_.at(1)
		else
			# Normal argument passing for other programs
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
		ok
		
		if @bCaptureError
			@cError = QByteArraytoString(_oQProcess_.ReadAllStandardError())
			if @cError = "" and @nExitCode != 0 and @cOutput != ""
				@cError = @cOutput
			ok
		ok

	#---------------------#
	#  SANDBOX EXECUTION  #
	#---------------------#

	def CreateWorkspace()
		# Create sandbox root
		if NOT isdir(@cSandboxRoot)
			QMkdir(@cSandboxRoot)
		ok
		
		# Create workspace
		cTimestamp = "" + clock()
		cPath = @cSandboxRoot + "/ws_" + cTimestamp
		
		QMkdir(cPath)  # Changed from system('mkdir...')
		
		return cPath


def RunInSandbox()
		? BoxRound("SANDBOX MODE: Safe Execution Zone") + NL
		
		# Step 1: Create isolated workspace
		? "-> Creating isolated workspace..."
		@cWorkspace = This.CreateWorkspace()
		? "  √ Workspace ready: " + @cWorkspace
		? ""
		
		# Step 2: Prepare environment
		? "-> Preparing workspace environment..."
		This.PrepareWorkspace()
		? "  √ Files copied to sandbox"
		? ""
		
		# Step 3: Convert paths for platform
		if isWindows()
			for i = 1 to len(@acArgs)
				@acArgs[i] = substr(@acArgs[i], "/", "\")
			next
		ok
		
		# Step 4: Execute in sandbox using QProcess
		? "-> Executing command in sandbox..."
		? "  Command: " + @cProgram
		? "  Arguments: " + @@(@acArgs)
		? ""
		
		This.ExecuteInSandbox()
		
		if @nExitCode = 0
			? "  √ Command executed successfully"
		else
			? "  ! Command completed with exit code: " + @nExitCode
			if @cError != ""
				? "  Error: " + @cError
			ok
		ok
		? ""
		
		# Step 5: Analyze changes
		? "-> Analyzing workspace changes..."
		aChanges = This.CaptureChanges()
		? ""
		
		# Step 6: User approval
		if NOT This.UserApproves(aChanges)
			? ""
			? "X Changes discarded, workspace cleaned up"
			This.CleanupWorkspace()
			return FALSE
		ok
		
		# Step 7: Apply to real system
		? ""
		? "-> Applying changes to real filesystem..."
		This.ApplyToRealSystem(aChanges)
		? "  √ Changes applied successfully"
		? ""
		
		# Step 8: Cleanup
		? "-> Cleaning up workspace..."
		This.CleanupWorkspace()
		? "  √ Workspace removed" + NL
		? BoxRound("Operation Completed Successfully")
		
		return TRUE


	def ExecuteInSandbox()
		# Use QProcess with working directory set to workspace
		_oQStrList_ = new QStringList()
		
		# Handle cmd.exe specially for Windows
		if isWindows() and @cProgram = "cmd.exe" and len(@acArgs) > 1 and @acArgs[1] = "\c"
			_oQStrList_.append("/c")
			cCommand = ""
			for i = 2 to len(@acArgs)
				if i > 2
					cCommand += " "
				ok
				cCommand += @acArgs[i]
			next
			_oQStrList_.append(cCommand)
		else
			# Normal argument passing
			for i = 1 to len(@acArgs)
				_oQStrList_.append(@acArgs[i])
			next
		ok
		
		_oQProcess_ = new QProcess("")
		_oQProcess_.setWorkingDirectory(@cWorkspace)
		_oQProcess_.setProcessChannelMode(0)
		_oQProcess_.start(@cProgram, _oQStrList_, 3)
		
		if NOT _oQProcess_.waitForFinished(@nTimeout)
			@bExecuted = FALSE
			@nExitCode = -1
			@cError = "Command timed out after " + @nTimeout + "ms"
			return NULL
		ok
		
		@bExecuted = TRUE
		@nExitCode = _oQProcess_.ExitCode()
		
		if @bCaptureOutput
			@cOutput = QByteArraytoString(_oQProcess_.ReadAllStandardOutput())
		ok
		
		if @bCaptureError
			@cError = QByteArraytoString(_oQProcess_.ReadAllStandardError())
			if @cError = "" and @nExitCode != 0 and @cOutput != ""
				@cError = @cOutput
			ok
		ok

	def PrepareWorkspace()
		aFiles = []
		for cArg in @acArgs
			if substr(cArg, ".") > 0 and fexists(cArg)
				aFiles + cArg  # Keep original relative path
			ok
		next
		
		# Validate files exist
		for cFile in aFiles
			if NOT fexists(cFile)
				This.CleanupWorkspace()
				stzraise("Source file does not exist: " + cFile)
			ok
		next
		
		# Copy files preserving structure
		for cFile in aFiles
			cPath = NormalizePath(cFile)  # Use short form, not XT
			nPos = 0
			for i = len(cPath) to 1 step -1
				if cPath[i] = "/"
					nPos = i
					exit
				ok
			next
			
			cDest = @cWorkspace + "/" + cFile  # Use original relative path
			CopyFileContent(cFile, cDest)
		next
		
		@aFileSnapshot = This.GetDirectorySnapshot(@cWorkspace)

	def ExtractDirectory(cPath)
		cPath = substr(cPath, "\", "/")
		nPos = 0
		for i = len(cPath) to 1 step -1
			if cPath[i] = "/"
				nPos = i - 1
				exit
			ok
		next
		return left(cPath, nPos)

	def ExtractFileReferences()
		aFiles = []
		for i = 1 to len(@acArgs)
			cArg = @acArgs[i]
			# Simple heuristic: if looks like file and exists
			if (substr(cArg, ".") > 0) and fexists(cArg)
				aFiles + cArg
			ok
		next
		return aFiles

	def GetDirectorySnapshot(cDir)
		aSnapshot = []
		
		# Get all entries recursively
		aToProcess = [cDir]
		
		while len(aToProcess) > 0
			cCurrentPath = aToProcess[1]
			del(aToProcess, 1)
			
			_aList_ = @dir(cCurrentPath)
			nLen = len(_aList_)
			
			for i = 1 to nLen
				if _aList_[i][2] = 0  # File
					cFileName = _aList_[i][1]
					cFullPath = cCurrentPath + "/" + cFileName
					cRelativePath = @substr(cFullPath, len(cDir) + 2, len(cFullPath))  # Remove base dir + separator
					aSnapshot + [cRelativePath, len(cFullPath), filemtime(cFullPath)]
					
				but _aList_[i][2] = 1 and _aList_[i][1] != "." and _aList_[i][1] != ".."  # Directory
					aToProcess + (cCurrentPath + "/" + _aList_[i][1])
				ok
			next
		end
		
		return aSnapshot

	def CaptureChanges()
		aAfterSnapshot = This.GetDirectorySnapshot(@cWorkspace)
		
		//? "DEBUG CaptureChanges: Before snapshot = " + @@(@aFileSnapshot)
		//? "DEBUG CaptureChanges: After snapshot = " + @@(aAfterSnapshot)
		
		aCreated = []
		aModified = []
		
		# Find new files (in after but not in before)
		for aFileAfter in aAfterSnapshot
			cFileName = aFileAfter[1]
			bFound = FALSE
			
			for aFileBefore in @aFileSnapshot
				if aFileBefore[1] = cFileName
					bFound = TRUE
					# Check if modified (size changed)
					if aFileBefore[2] != aFileAfter[2]
						aModified + cFileName
					ok
					exit
				ok
			next
			
			if NOT bFound
				aCreated + cFileName
			ok
		next
		
		//? "DEBUG: Created files = " + @@(aCreated)
		//? "DEBUG: Modified files = " + @@(aModified)
		
		return [
			:created = aCreated,
			:modified = aModified,
			:output = @cOutput,
			:exitcode = @nExitCode
		]

	def UserApproves(aChanges)
		if @bAutoApprove
			return TRUE
		ok
		
		? BoxRound("REVIEW CHANGES BEFORE APPLYING") + NL
		? "Workspace: " + @cWorkspace
		? "Exit code: " + aChanges[:exitcode] + NL
		
		nTotalChanges = len(aChanges[:created]) + len(aChanges[:modified])
		
		if nTotalChanges = 0
			? "! No file changes detected"
			if aChanges[:exitcode] != 0
				? "  The command may have failed or produced no output"
			ok
		else
			if len(aChanges[:created]) > 0
				? "√ Files created (" + len(aChanges[:created]) + "):"
				for cFile in aChanges[:created]
					? "  + " + cFile
				next
				? ""
			ok
			
			if len(aChanges[:modified]) > 0
				? "√ Files modified (" + len(aChanges[:modified]) + "):"
				for cFile in aChanges[:modified]
					? "  * " + cFile
				next
				? ""
			ok
		ok
		
		if aChanges[:output] != "" and len(aChanges[:output]) > 0
			cCommandOutput = "(Nothing)"
			cLeft200 = left(aChanges[:output], 200)
			if cLeft200 != ""
				cCommandOutput = cLeft200
			ok

			? "Command output:"
			? "  " + cCommandOutput
			if len(aChanges[:output]) > 200
				? "  ... (truncated)"
			ok
			? ""
		ok
		
		? BoxRound("Options") + NL
		? "  Y = Yes, Apply changes to real filesystem"
		? "  N = No, Discard changes and cleanup workspace"
		? "  I = Inspect workspace contents"
		? ""
		? "Your choice (Y/N/I): "
		give cAnswer
		? ""
		
		if lower(cAnswer) = "i"
			? BoxRound("WORKSPACE CONTENTS") + NL
			This.ShowWorkspaceTree(@cWorkspace, "", 0)
			? ""
			? "Press Enter to continue..."
			give cDummy
			return This.UserApproves(aChanges)
		ok
		
		if lower(cAnswer) != "y" and lower(cAnswer) != "n"
			? "Invalid choice. Please enter y, n, or i"
			return This.UserApproves(aChanges)
		ok
		
		return lower(cAnswer) = "y"


	def ShowWorkspaceTree(cPath, cPrefix, nLevel)
		aList = dir(cPath)
		nLen = len(aList)
		
		for i = 1 to nLen
			if aList[i][1] = "." or aList[i][1] = ".."
				loop
			ok
			
			bIsLast = (i = nLen)
			cIcon = iff(bIsLast, "+-- ", "|-- ")
			
			if aList[i][2] = 1  # Directory
				? cPrefix + cIcon + "[DIR] " + aList[i][1]
				cNewPrefix = cPrefix + iff(bIsLast, "    ", "|   ")
				This.ShowWorkspaceTree(cPath + "/" + aList[i][1], cNewPrefix, nLevel + 1)
			else  # File
				? cPrefix + cIcon + "[FILE] " + aList[i][1]
			ok
		next

	def ApplyToRealSystem(aChanges)
		# Copy created/modified files back
		for cFile in aChanges[:created]
			cSrc = @cWorkspace + "/" + cFile
			if fexists(cSrc)
				CopyFileContent(cSrc, "./" + cFile)
			ok
		next
		
		for cFile in aChanges[:modified]
			cSrc = @cWorkspace + "/" + cFile
			if fexists(cSrc)
				CopyFileContent(cSrc, "./" + cFile)
			ok
		next

	def CleanupWorkspace()
		if @cWorkspace != "" and isdir(@cWorkspace)
			_oQDir_ = new QDir()
			_oQDir_.setPath(@cWorkspace)
			_oQDir_.removeRecursively()
		ok

	#-----------------------#
	#  EXISTING METHODS...  #
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
		// ? "DEBUG before SetParam: " + @@(@acArgs)
		
		# Validate file/folder existence
		if lower(cParam) = "source"
			if substr(cValue, ".") > 0 and NOT fexists(cValue)
				stzraise("Source file does not exist: " + cValue)
			ok
		ok
		
		if lower(cParam) = "dest"
			# Extract directory from destination path
			cPath = substr(cValue, "\", "/")
			nPos = 0
			for i = len(cPath) to 1 step -1
				if cPath[i] = "/"
					nPos = i
					exit
				ok
			next
			
			if nPos > 0
				cDir = left(cPath, nPos - 1)
				if NOT isdir(cDir)
					stzraise("Destination directory does not exist: " + cDir)
				ok
			ok
		ok
		
		for i = 1 to len(@acArgs)
			@acArgs[i] = substr(@acArgs[i], "{" + cParam + "}", cValue)
		next
		//? "DEBUG after SetParam: " + @@(@acArgs)
	
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
