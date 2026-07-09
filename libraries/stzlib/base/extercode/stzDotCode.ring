
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


class stzDotCode from stzObject
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

	def SetOutputFormat(_cFormat_)

		_cFormat_ = trim(_cFormat_)
		if _cFormat_ = "" or StzLower(_cFormat_) = 'null'
			_cFormat_ = $cDefaultDotOutputFormat
		else
			if StzFindFirst($acDotOutputFormats, _cFormat_) = 0
				stzraise("Unsupported output formats! Only these are supported: " + @@($acDotOutputFormats) + ".")
			ok
		ok

		@cOutputFormat = StzLower(_cFormat_)

		def SetOutput(_cFormat_)
			@cOutputFormat = StzLower(_cFormat_)

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
		_cTimestamp_ = "" + clock()
		_cOutputFile_ = NormalizePath(@cOutputDir + "/diagram_" + _cTimestamp_ + "." + @cOutputFormat)
		_cTempDotPath_ = NormalizePath(@cTempDir + "/" + @cTempDotFile)
	
		# Store for View() to use
		@cLastOutputFile = _cOutputFile_
	
		# Write dot code to temp file
		This.WriteToFile(_cTempDotPath_, @cDotCode)
	
		# Build arguments list
		_aArgs_ = [
			"-T" + @cOutputFormat,
			_cTempDotPath_,
			"-o",
			_cOutputFile_
		]
	
		# Execute using stzSystemCall
		_oCall_ = new stzSystemCall(@cDotPath)
		_oCall_.SetArgs(_aArgs_)
		_oCall_.HideConsole()
		_oCall_.WithTimeout(30000)
		_oCall_.Run()
	
		@nEndTime = clock()
	
		if @bVerbose
			? "Dot path: " + @cDotPath
			? "Output format: " + @cOutputFormat
			? "Output file: " + _cOutputFile_
			? "Exit code: " + _oCall_.ExitCode()
			if _oCall_.HasError()
				? "Error: " + _oCall_.Error()
			ok
		ok
	
		if NOT _oCall_.Succeeded() or NOT fexists(_cOutputFile_)
			_cError_ = "Graphviz dot command failed."
			if _oCall_.HasError()
				_cError_ += " Error: " + _oCall_.Error()
			ok
			if NOT fexists(_cOutputFile_)
				_cError_ += " Output file not created: " + _cOutputFile_
			ok
			stzraise(_cError_)
		ok
	
		@bWasExtecutedAtLeastOnce = 1

		def Run()
			This.Execute()

		def Exec()
			This.Execute()

		def View()
			if NOT @bWasExtecutedAtLeastOnce
				This.Execute()
			ok
		
			if @cLastOutputFile = "" or NOT fexists(@cLastOutputFile)
				stzraise("Output file does not exist: " + @cLastOutputFile)
			ok
			
			_oSysCal_ = new stzSystemCall("cmd.exe")
			_oSysCal_.OpenFile(@cLastOutputFile)

		def Display()
			This.View()

		def Visualise()
			This.View()

	def ExecuteAndView()
		This.Execute()
		This.View()

		def RunAndView()
			This.ExecuteAndView()

		def ExecAndView()
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
		_cLogPath_ = @cTempDir + "/" + @cLogFile
		if NOT fexists(_cLogPath_)
			return ""
		ok
		return This.ReadFile(_cLogPath_)

	def IsVerbose()
		return @bVerbose

	def Cleanup()
		try
			_cTempDotPath_ = @cTempDir + "/" + @cTempDotFile
			_cLogPath_ = @cTempDir + "/" + @cLogFile
			
			if fexists(_cTempDotPath_)
				remove(_cTempDotPath_)
			ok
			if fexists(_cLogPath_)
				remove(_cLogPath_)
			ok
		catch
		done

	def CleanupAll()
		This.Cleanup()
		try
			_cOutputFile_ = @cOutputDire + "/" + "diagram." + @cOutputFormat
			if fexists(_cOutputFile_)
				remove(_cOutputFile_)
			ok
		catch
		done

	def WriteToFile(cFile, _cContent_)
		_fp_ = fopen(cFile, "w")
		fwrite(_fp_, _cContent_)
		fclose(_fp_)

	def ReadFile(cFile)
		if NOT fexists(cFile)
			return ""
		ok
		_fp_ = fopen(cFile, "r")
		if _fp_ = NULL
			return ""
		ok
		_cContent_ = fread(_fp_, fsize(_fp_))
		fclose(_fp_)
		return _cContent_
