

func XDot()
	return new stzDotCode

	func GraphvizQ()
		return new stzDotCode()


class stzDotCode
	@cDotCode = ""
	@cOutputFile = "output.svg"
	@cOutputFormat = "svg"  # svg, png, pdf, etc.
	@cDotPath = "D:\Graphviz\bin\dot.exe"
	@cTempDotFile = "temp.dot"
	@cLogFile = "dotlog.txt"
	@bVerbose = 0
	@nStartTime = 0
	@nEndTime = 0
	@cTempDir = "temp"
	@cOutputDir = "output"

	# Initializing the dot code

	def Init()
		# Create directories if they don't exist
		This.EnsureDirectories()

	def EnsureDirectories()
		CreateFolderIfInexistant(@cTempDir)
		CreateFolderIfInexistant(@cOutputDir)

	def SetCode(pcDotCode)
		@cDotCode = pcDotCode

		def @(pcDotCode)
			This.SetCode(pcDotCode)

	# Setting output options

	def SetOutputFile(cFile)
		# Prepend output directory if not already included
		if NOT substr(cFile, @cOutputDir)
			@cOutputFile = @cOutputDir + "\" + cFile
		else
			@cOutputFile = cFile
		ok

	def SetOutputFormat(cFormat)
		# Supported: svg, png, pdf, jpg, gif, ps, etc.
		@cOutputFormat = lower(cFormat)

	def SetTempDir(cDir)
		@cTempDir = cDir
		This.EnsureDirectories()

	def SetOutputDir(cDir)
		@cOutputDir = cDir
		This.EnsureDirectories()

	def TempDir()
		return @cTempDir

	def OutputDir()
		return @cOutputDir

	def SetDotPath(cPath)
		@cDotPath = cPath

	def SetVerbose(bVerbose)
		@bVerbose = bVerbose

	# Running the dot code

	def Execute()
		This.EnsureDirectories()
		This.Cleanup()
		
		if @cDotCode = ""
			return
		ok

		@nStartTime = clock()

		# Build full paths with directories
		cTempDotPath = @cTempDir + "\" + @cTempDotFile
		cLogPath = @cTempDir + "\" + @cLogFile

		# Write dot code to temp file
		This.WriteToFile(cTempDotPath, @cDotCode)

		# Build command with full paths
		cCmd = @cDotPath + " -T" + @cOutputFormat + " " + 
		       cTempDotPath + " -o " + @cOutputFile + 
		       " > " + cLogPath + " 2>&1"

		# Execute
		system(cCmd)

		@nEndTime = clock()

		if @bVerbose
			? "Command: " + cCmd
			? "Output file: " + @cOutputFile
			? "Log: " + @@(This.Log())
		ok

		if NOT fexists(@cOutputFile)
			stzraise("Output file '" + @cOutputFile + "' not created. Log: " + This.Log())
		ok

		def Run()
			This.Execute()

		def Exec()
			This.Execute()

	# View the generated output

	def View()
		if NOT fexists(@cOutputFile)
			stzraise("Output file does not exist: " + @cOutputFile)
		ok
		system(@cOutputFile)

		def Show()
			This.View()

		def Display()
			This.View()

	# Execute and view in one call

	def ExecuteAndView()
		This.Execute()
		This.View()

		def RunAndView()
			This.ExecuteAndView()

		def ExecAndShow()
			This.ExecuteAndView()

		def RunXT()
			This.ExecuteAndView()

		def ExecuteXT()
			This.ExecuteAndView()

		def ExecXT()
			This.ExecuteAndView()

	# Get information

	def OutputFile()
		return @cOutputFile

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
		if NOT fexists(@cLogFile)
			return ""
		ok
		return This.ReadFile(@cLogFile)

	def IsVerbose()
		return @bVerbose

	# Cleanup

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
			# Silent cleanup
		done

	def CleanupAll()
		This.Cleanup()
		try
			if fexists(@cOutputFile)
				remove(@cOutputFile)
			ok
		catch
			# Silent cleanup
		done

	# Private methods

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
