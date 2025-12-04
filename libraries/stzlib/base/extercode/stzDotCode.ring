
#NOTE You should install Graphiz diagram engine to use this class

# Also, you need to specify the path of the dot.exe command line tool
# in a gloabl hashlist you name $aStzLibConfig that you populate like this:
#    $aStzLibConfig = [
#	:DotPath = "...",
#	...
# ]

if Haskey($aStzLibConfig, :DotPath) and $aStzLibConfig[:DotPath] != ""
    $cDotPath = $aStzLibConfig[:DotPath]
else
    $cDotPath = "d:/Graphviz/bin/dot.exe"
ok

$acDotOutputFormats = [
	"bmp", "canon", "cmap", "cmapx", "cmapx_np",
	"dot", "dot_json", "emf", "emfplus", "eps",
	"fig", "gd", "gd2", "gif", "gv", "imap", "imap_np",
	"ismap", "jpe", "jpeg", "jpg", "json", "json0",
	"kitty", "kittyz", "metafile", "pdf", "pic",
	"plain", "plain-ext", "png", "pov", "ps",
	"ps2", "svg", "svg_inline", "svgz", "tif",
	"tiff", "tk", "vrml", "vt", "vt-24bit", "vt-4up",
	"vt-6up", "vt-8up", "wbmp", "webp", "xdot",
	"xdot1.2", "xdot1.4", "xdot_json"
]

$cDefaultDotOutputFormat = "svg"

func DefaultDiagramOutputFormat()
	return $cDefaultDiagramOutputFormat

func StzDotCodeQ()
	return new stzDotCode

	func XDot()
		return new stzDotCode()

	func GraphvizQ()
		return new stzDotCode()


class stzDotCode
	@cDotCode = ""
	@cOutputFormat = $cDefaultDotOutputFormat
	@cDotPath = $cDotPath
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

		cFormat = trim(cFormat)
		if cFormat = "" or lower(cFormat) = 'null'
			cFormat = $cDefaultDotOutputFormat
		else
			if ring_find($acDotOutputFormats, cFormat) = 0
				stzraise("Unsupported output formats! Only these are supported: " + @@($acDotOutputFormats) + ".")
			ok
		ok

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
		cOutputFile = @cOutputDir + "\diagram_" + cTimestamp + "." + @cOutputFormat
		cTempDotPath = @cTempDir + "\" + @cTempDotFile
	
		# Store for View() to use
		@cLastOutputFile = cOutputFile
	
		# Write dot code to temp file
		This.WriteToFile(cTempDotPath, @cDotCode)
	
		# Build arguments list
		aArgs = [
			"-T" + @cOutputFormat,
			cTempDotPath,
			"-o",
			cOutputFile
		]
	
		# Execute using stzSystemCall
		_oCall_ = new stzSystemCall(@cDotPath)
		_oCall_.SetArgs(aArgs)
		_oCall_.HideConsole()
		_oCall_.WithTimeout(30000)
		_oCall_.Run()
	
		@nEndTime = clock()
	
		if @bVerbose
			? "Dot path: " + @cDotPath
			? "Output format: " + @cOutputFormat
			? "Output file: " + cOutputFile
			? "Exit code: " + _oCall_.ExitCode()
			if _oCall_.HasError()
				? "Error: " + _oCall_.Error()
			ok
		ok
	
		if NOT _oCall_.Succeeded() or NOT fexists(cOutputFile)
			cError = "Graphviz dot command failed."
			if _oCall_.HasError()
				cError += " Error: " + _oCall_.Error()
			ok
			if NOT fexists(cOutputFile)
				cError += " Output file not created: " + cOutputFile
			ok
			stzraise(cError)
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
		oSysCall = new stzSystemCall("")
		oSysCall.OpenFile(@cLastOutputFile)

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
		cLogPath = @cTempDir + "/" + @cLogFile
		if NOT fexists(cLogPath)
			return ""
		ok
		return This.ReadFile(cLogPath)

	def IsVerbose()
		return @bVerbose

	def Cleanup()
		try
			cTempDotPath = @cTempDir + "/" + @cTempDotFile
			cLogPath = @cTempDir + "/" + @cLogFile
			
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
