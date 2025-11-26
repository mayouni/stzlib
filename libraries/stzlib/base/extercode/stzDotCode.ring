func StzDotCodeQ()
	return new stzDotCode

	func XDot()
		return new stzDotCode()

	func GraphvizQ()
		return new stzDotCode()


class stzDotCode
	@cDotCode = ""
	@cOutputFormat = "svg"
	@cDotPath = "D:\Graphviz\bin\dot.exe"
	@cTempDotFile = "temp.dot"
	@cLogFile = "dotlog.txt"
	@cOutputDir = "output"
	@bVerbose = 0
	@nStartTime = 0
	@nEndTime = 0
	@cTempDir = "temp"
	@cLastOutputFile = ""
	@bWasExtecutedAtLeastOnce = 0

	def Init()
		This.EnsureDirectories()

	def EnsureDirectories()
		CreateFolderIfInexistant(@cTempDir)
		CreateFolderIfInexistant(@cOutputDir)

	def SetCode(pcDotCode)
		@cDotCode = pcDotCode

		def @(pcDotCode)
			This.SetCode(pcDotCode)

	def SetOutputFormat(cFormat)
		@cOutputFormat = lower(cFormat)

		def SetOutput(cFormat)
			@cOutputFormat = lower(cFormat)

	def SetTempDir(cDir)
		@cTempDir = cDir
		This.EnsureDirectories()

	def TempDir()
		return @cTempDir

	def SetDotPath(cPath)
		@cDotPath = cPath

	def SetVerbose(bVerbose)
		@bVerbose = bVerbose

	def Execute()
		This.EnsureDirectories()
		This.Cleanup()
		
		if @cDotCode = ""
			return
		ok

		@nStartTime = clock()

		# Generate unique filename with timestamp IN OUTPUT FOLDER
		cTimestamp = "" + clock()
		cOutputFile = @cOutputDir + "\diagram_" + cTimestamp + "." + @cOutputFormat  # CHANGED
		cTempDotPath = @cTempDir + "\" + @cTempDotFile
		cLogPath = @cTempDir + "\" + @cLogFile

		# Store for View() to use
		@cLastOutputFile = cOutputFile

		# Write dot code to temp file
		This.WriteToFile(cTempDotPath, @cDotCode)

		# Build command
		cCmd = @cDotPath + " -T" + @cOutputFormat + " " + 
		       cTempDotPath + " -o " + cOutputFile + 
		       " > " + cLogPath + " 2>&1"

		# Execute
		system(cCmd)
		@nEndTime = clock()

		if @bVerbose
			? "Command: " + cCmd
			? "Output file: " + cOutputFile
			? "Log: " + @@(This.Log())
		ok

		if NOT fexists(cOutputFile)
			stzraise("Output file '" + cOutputFile + "' not created. Log: " + This.Log())
		ok

		@bWasExtecutedAtLeastOnce = 1

		def Run()
			This.Execute()

		def Exec()
			This.Execute()

	def View()
		if NOT @bWasExtecutedAtLeastOnce
			stzraise("Can't view the generated visual! You must Run() the DOT code firts.")

		ok

		if @cLastOutputFile = "" or NOT fexists(@cLastOutputFile)
			stzraise("Output file does not exist: " + @cLastOutputFile)
		ok
		system('"' + @cLastOutputFile + '"')

		def Display()
			This.View()

		def Visualise()
			This.View()

	def ExecuteAndView()
		This.Execute()
		This.View()

		def RunAndView()
			This.ExecuteAndView()

		def RunXT()
			This.ExecuteAndView()

		def ExecuteXT()
			This.ExecuteAndView()

		def ExecXT()
			This.ExecuteAndView()

	def OutputFile()
		return @cLastOutputFile

	def OutputFormat()
		return @cOutputFormat

	def Code()
		return @cDotCode

	def Duration()
		if @nEndTime > 0 and @nStartTime > 0
			return (@nEndTime - @nStartTime) / clockspersecond()
		ok
		return 0

	def Log()
		cLogPath = @cTempDir + "\" + @cLogFile
		if NOT fexists(cLogPath)
			return ""
		ok
		return This.ReadFile(cLogPath)

	def IsVerbose()
		return @bVerbose

	def Cleanup()
		try
			cTempDotPath = @cTempDir + "\" + @cTempDotFile
			cLogPath = @cTempDir + "\" + @cLogFile
			
			if fexists(cTempDotPath)
				remove(cTempDotPath)
			ok
			if fexists(cLogPath)
				remove(cLogPath)
			ok
		catch
		done

	def CleanupAll()
		This.Cleanup()
		try
			cOutputFile = @cOutputDire + "/" + "diagram." + @cOutputFormat
			if fexists(cOutputFile)
				remove(cOutputFile)
			ok
		catch
		done

	def WriteToFile(cFile, cContent)
		fp = fopen(cFile, "w")
		fwrite(fp, cContent)
		fclose(fp)

	def ReadFile(cFile)
		if NOT fexists(cFile)
			return ""
		ok
		fp = fopen(cFile, "r")
		if fp = NULL
			return ""
		ok
		cContent = fread(fp, fsize(fp))
		fclose(fp)
		return cContent
