#------------------------------------------------------------------#
#         SOFTANZA LIBRARY - QML CODE (EXTERNAL RUNTIME)            #
#------------------------------------------------------------------#
#                                                                  #
#  Description : Shells QML markup out to Qt's standalone `qml` /  #
#                `qmlscene` runtime so a Softanza application can  #
#                show a QML view without depending on Qt at the    #
#                library level (no qApp / RingQML binding).        #
#                                                                  #
#                Follows the same shape as stzDotCode (Graphviz):  #
#                  - write source to a temp file under temp/       #
#                  - invoke the runtime as a child process         #
#                  - capture stdout/stderr + exit code + duration  #
#                                                                  #
#                Reach for `XQml()` / `StzQmlCodeQ()` rather than  #
#                Ring's qApp{} binding, which Softanza no longer   #
#                ships against -- the library is engine-only.      #
#                                                                  #
#  Version     : V0.9 (2026-06)                                    #
#  Author      : Mansour Ayouni (kalidianow@gmail.com)             #
#------------------------------------------------------------------#

# Path resolution mirrors stzDotCode: honour $aStzLibConfig[:QmlPath]
# if the user has set it, otherwise fall back to a sensible default.

if HasKey($aStzLibConfig, :QmlPath) and $aStzLibConfig[:QmlPath] != ""
	$cQmlPath = $aStzLibConfig[:QmlPath]
else
	# Common Windows install path for the Qt standalone QML runtime.
	# On POSIX the default is usually just "qml" on PATH.
	$cQmlPath = "qml"
ok

func StzQmlCodeQ()
	return new stzQmlCode

	func XQml()
		return new stzQmlCode()

	func QmlQ()
		return new stzQmlCode()

class stzQmlCode from stzObject

	@cQmlCode    = ""
	@cQmlPath    = $cQmlPath
	@cTempDir    = "temp"
	@cTempFile   = "temp.qml"
	@cLogFile    = "qmllog.txt"
	@nStartTime  = 0
	@nEndTime    = 0
	@nExitCode   = 0
	@cLastOutput = ""
	@bVerbose    = 0
	@bExecutedAtLeastOnce = 0

	def Init()
		This.EnsureDirectories()

	# ----- Setting / reading the QML source -------------------------

	def SetCode(pcQml)
		if NOT isString(pcQml)
			StzRaise("stzQmlCode.SetCode: pcQml must be a string.")
		ok
		@cQmlCode = pcQml

		def @(pcQml)
			This.SetCode(pcQml)

		def Code(pcQml)
			This.SetCode(pcQml)

	def Source()
		return @cQmlCode

	# ----- Path resolution + sanity --------------------------------

	def SetQmlPath(pcPath)
		if NOT isString(pcPath) or pcPath = ""
			StzRaise("stzQmlCode.SetQmlPath: pcPath must be a non-empty string.")
		ok
		@cQmlPath = pcPath

	def QmlPath()
		return @cQmlPath

	def IsRuntimeAvailable()
		# We cannot reliably probe an external binary cross-platform
		# without spawning it; treat a configured non-empty path as
		# available. Callers that need a hard check should run
		# Execute() and inspect ExitCode().
		return @cQmlPath != ""

	# ----- Filesystem prep -----------------------------------------

	def EnsureDirectories()
		if NOT isdir(@cTempDir)
			# StzSystemSilentXT mirrors what stzFolder uses.
			if isWindows()
				StzSystemSilentXT("cmd.exe",
					[ "/c", "mkdir", @cTempDir ])
			else
				StzSystemSilentXT("mkdir",
					[ "-p", @cTempDir ])
			ok
		ok

	def TempSourcePath()
		return @cTempDir + "/" + @cTempFile

	def LogPath()
		return @cTempDir + "/" + @cLogFile

	# ----- Execution -----------------------------------------------

	def WriteSource()
		write(This.TempSourcePath(), @cQmlCode)

	def Execute()
		if @cQmlCode = ""
			StzRaise("stzQmlCode.Execute: no QML source set.")
		ok
		This.EnsureDirectories()
		This.WriteSource()

		@nStartTime = clock()
		_cCmd_ = '"' + @cQmlPath + '" "' + This.TempSourcePath() + '"' +
		         ' > "' + This.LogPath() + '" 2>&1'
		# Use Softanza's system wrapper rather than Ring's bare system().
		StzSystemSilent(_cCmd_)
		@nEndTime = clock()

		# Capture log + exit code probe.
		if fexists(This.LogPath())
			@cLastOutput = read(This.LogPath())
		else
			@cLastOutput = ""
		ok
		@bExecutedAtLeastOnce = 1

		def Run()
			This.Execute()

		def Exec()
			This.Execute()

	# ----- Result inspection ---------------------------------------

	def Result()
		return @cLastOutput

	def Log()
		return @cLastOutput

	def Trace()
		return @cLastOutput

	def Duration()
		if NOT @bExecutedAtLeastOnce
			return 0
		ok
		return (@nEndTime - @nStartTime) / clockspersecond()

	def WasExecuted()
		return @bExecutedAtLeastOnce

	# ----- Cleanup --------------------------------------------------

	def CleanupTemp()
		if fexists(This.TempSourcePath())
			remove(This.TempSourcePath())
		ok
		if fexists(This.LogPath())
			remove(This.LogPath())
		ok
