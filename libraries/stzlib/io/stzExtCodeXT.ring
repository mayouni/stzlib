#===============================
# StzExtCode Class
# 
# Purpose: Provides a unified interface for executing code in external
# programming languages, supporting both interpreted and compiled languages,
# with flexible deployment options and efficient data exchange.
#
# Features:
# - Supports both interpreted (Python, Julia) and compiled (C, C++) languages
# - Dynamic and precompiled modes for compiled languages
# - Automated library generation and management
# - Performance tracking and error handling
# - File-based data exchange (with plans for shared memory)
#===============================

$cBatchCode = '
@echo off
g++ %1 -o %2
echo Compilation completed with status: %ERRORLEVEL%'

$cPyToRingDataTransFunc = '

def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"[\'+char(39)+'{key}\'+char(39)+', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            return f"\'+char(39)+'{obj}\'+char(39)+'"
        elif isinstance(obj, (int, float)):
            return str(obj)
        else:
            return f"\'+char(39)+'{str(obj)}\'+char(39)+'"
    return _transform(data)
'

$cJuliaToRingDataTransFunc = '

function transform_to_ring(data)
    if isa(data, Dict)
        items = []
        for (key, value) in data
            push!(items, "['+char(39)+'" * string(key) * "'+char(39)+', " * transform_to_ring(value) * "]")
        end
        return "[" * join(items, ", ") * "]"
    elseif isa(data, Array)
        return "[" * join([transform_to_ring(item) for item in data], ", ") * "]"
    elseif isa(data, String)
        return "'+char(39)+'" * replace(data, "'+char(39)+'" => "\\'+char(39)+'") * "'+char(39)+'"
    elseif isa(data, Number)
        return string(data)
    elseif isa(data, Bool)
        return string(data)
    else
        return "'+char(39)+'" * string(data) * "'+char(39)+'"
    end
end
'

$cCToRingDataTransFunc = ''
$cCPPToRingDataTransFunc = ''

class StzExtCodeXT
    
	# Supported languages configuration

	@aLanguages = []

	# Execution tracking

	@aCallTrace = []
    
	# State management

	@cLanguage = ""
	@cCode = ""
	@cSourceFile = ""
	@cOutputFile = ""
	@cDataFile = ""
	@nStartTime = 0
	@nEndTime = 0
    
	# Compilation mode control

	@cCompilationMode = "dynamic"
	@cPrecompiledPath = ""

	# Batch file (used mainly for building with compiled langs)

	@cBatchFile = "compile.bat"


	def Init(cLang)
		This.Configure()
 
		if NOT This.IsLanguageSupported(cLang)
			stzraise("Language '" + cLang + "' is not supported")
		ok

		@cLanguage = lower(cLang)
		@cSourceFile = "temp" + @aLanguages[@cLanguage][:extension]
        
		if @aLanguages[@cLanguage][:type] = "compiled"
			@cOutputFile = "temp" + @aLanguages[@cLanguage][:outputExt]
		end
        
		@cDataFile = @aLanguages[@cLanguage][:datafile]

	# Check if a language is supported

	def IsLanguageSupported(cLang)
		return @aLanguages[lower(cLang)] != NULL

		# @FunctionAlternativeForm

		def IsSupportedLanguage(cLang)
			return IsLanguageSupported(cLang)

	# Set custom runtime path

	def SetRuntimePath(cPath)
		@aLanguages[@cLanguage][:customPath] = cPath

	# Set source code to execute

	def SetCode(cNewCode)
		@cCode = cNewCode

	# Set compilation mode and optional library path

	def SetCompilationMode(cMode, cPath)

		if ring_find(["dynamic", "precompiled"], cMode) = 0
			stzraise("Invalid compilation mode. Use 'dynamic' or 'precompiled'")
		ok
        
		if @aLanguages[@cLanguage][:type] != "compiled"
			raise("Compilation mode only applies to compiled languages")
		ok
        
		@cCompilationMode = cMode
		@aLanguages[@cLanguage][:currentMode] = cMode
        
		if cPath != ""
			@cPrecompiledPath = cPath
			@aLanguages[@cLanguage][:precompiledPath] = cPath
		ok

		# @FunctionAlternativeForm

		def SetCompilMode(cMode, cPath)
			This.SetCompilationMode(cMode, cPath)

	# Compile current code as a shared library

	def Compile(cOutputName)

		if @aLanguages[@cLanguage][:type] != "compiled"
			stzraise("Can't proceed! Library compilation only available for compiled languages.")
		ok
        
		# Ensure libs directory exists

		cLibDir = @aLanguages[@cLanguage][:precompiledPath]
		This.EnsureDirectoryExists(cLibDir)
        
		# Construct library name

		cLibName = @aLanguages[@cLanguage][:libPrefix] + 
				cOutputName + 
				@aLanguages[@cLanguage][:libExtension]
        
		cFullLibPath = cLibDir + cLibName
        
		# Compile as shared library

		cCmd = @aLanguages[@cLanguage][:compileLibCmd]
		cCmd = ring_substr2(cCmd, "%source%", @cSourceFile)
		cCmd = ring_substr2(cCmd, "%output%", cFullLibPath)
        
		SystemSilent(cCmd) # يا ربّي و رضاية الوالدين
		return cFullLibPath

		# @FunctionAlternativeForm

		def CompileAsLibrary(cOutputName)
			This.Compile(cOutputName)

	# Prepare code for execution

	def Prepare()

		# Write source code to file

		This.writeToFile(@cSourceFile, This.PrepareSourceCode())
        
		if @aLanguages[@cLanguage][:type] = "compiled"

			if @cCompilationMode = "dynamic"
				This.Compile(This.PrecompiledLibraryPath())

			else
				cLibPath = This.PrecompiledLibraryPath() #TODO Not implemented!
				if cLibPath = NULL
					stzraise("Precompiled library not found in " + 
						@aLanguages[@cLanguage][:precompiledPath])
				ok
			ok
		ok

		# @functionFluentForm

		def PrepareQ()
			This.Prepare()
			return This

	# Preparing the batch file (for building with compiled langs)

	def PrepareBatchFile()
		cBatchContent = '@echo off' + NL
        
		# Add compiler path based on language

		if @cLanguage = "cpp"
			cCompilerPath = This.GetCompilerPath("g++.exe")
			cBatchContent += '"' + cCompilerPath + '" %1 -o %2 2>&1' + NL

		but @cLanguage = "c"
			cCompilerPath = This.GetCompilerPath("gcc.exe")
			cBatchContent += '"' + cCompilerPath + '" %1 -o %2 2>&1' + NL
		ok
        
		cBatchContent += 'echo %ERRORLEVEL%'
		write(@cBatchFile, cBatchContent)

	# Getting compiler in common installation paths

	 def GetCompilerPath(cCompiler) #TODO // Generalize it to OSes other than Windows
		aCommonPaths = [
			"C:\msys64\ucrt64\bin\",
			"C:\MinGW\bin\",
			"C:\msys64\mingw64\bin\"
		]
        
		for cPath in aCommonPaths
			if fexists(cPath + cCompiler)
				return cPath + cCompiler
			ok
        	next
        
		return cCompiler  # Return just the compiler name if not found in common paths

	# Execute the prepared code

	def Execute()

		This.Prepare()

		if @cCode = ""
			return
		end
    
		@nStartTime = clock()
    
		# Set the working directory to the location of the executable
		cWorkDir = ring_substr2(@cSourceFile, "\\" + @aLanguages[@cLanguage][:extension], "")
		chdir(cWorkDir)

		cCmd = This.BuildCommand()
		cOutput = SystemSilent(cCmd)

		@nEndTime = clock()
    
		This.RecordExecution(cOutput)
		This.CleanupCompiledFiles()

		def ExecuteQ()
			This.Execute()
			return This

	# Get the output from the last execution

	def Output()
		if len(@aCallTrace) = 0
			return ""
		ok

		return @aCallTrace[len(@aCallTrace)][:output]

	# Get execution duration of last call

	def LastCallDuration()
		if len(@aCallTrace) > 0
			return @aCallTrace[len(@aCallTrace)][:duration]
		end

		return 0

		def Duration()
			return This.LastCallDuration()

	# Get data from the exchange file

	def FileData()

		if NOT fexists(@cDataFile)
			stzraise("File does not exist!")
		ok
    
		cContent = This.ReadFile(@cDataFile)
    
		if cContent = NULL or cContent = ""
			return ""
		end

		# Evaluating the file content

		try
			cCode = 'result = ' + cContent
			eval(cCode)
			return result
		catch
			? "Eval error: " + cCatchError
			return cContent
		end

	# Get complete execution history

	def CallTrace()
		return @aCallTrace

	# Get the file name

	def FileName()
		return @cDataFile

		def DataFileName()
			return This.FileName()

	#--------------------------#
	#  Private helper methods  #
	#--------------------------#

	PRIVATE

        # Initialize configuration for supported languages

	def Configure()

		cOutputExt = ""

		if isWindows()
			cOutputExt = ".exe"
		ok
        
		cLibExtension = ""

		if isWindows()
			cLibExtension = ".dll"
		else
			cLibExtension = ".so"
		ok
        
		cLibPrefix = ""

		if NOT isWindows()
			cLibPrefix = "lib"
		ok
        
		cCompileLibCmdC = ""

		if isWindows()
			cCompileLibCmdC = "gcc -shared -o %output% %source%"
		else
			cCompileLibCmdC = "gcc -shared -fPIC -o %output% %source%"
		ok
        
		cCompileLibCmdCPP = ""

		if isWindows()
			cCompileLibCmdCPP = "g++ -shared -o %output% %source%"
		else
			cCompileLibCmdCPP = "g++ -shared -fPIC -o %output% %source%"
		ok
        
		@aLanguages = [

			# Interpreted languages

			:python = [
				:name = "Python",
				:type = "interpreted",
				:extension = ".py",
				:runtime = "python",
				:alternateRuntimes = ["python3", "py"],
				:datafile = "pydata.txt",
				:customPath = "",
				:transformFunction = $cPyToRingDataTransFunc

			],

			:julia = [
				:name = "Julia",
				:type = "interpreted",
				:extension = ".jl",
				:runtime = "julia",
				:datafile = "jldata.txt",
				:customPath = "",
				:transformFunction = $cJuliaToRingDataTransFunc
			],

			# Compiled languages

			:C = [
				:name = "C",
				:type = "compiled",
				:extension = ".c",
				:compiler = "gcc",
				:outputExt = cOutputExt,
				:datafile = "cdata.txt",
				:compileCmd = "gcc %source% -o %output%",
				:cleanup = TRUE,
				:libExtension = cLibExtension,
				:libPrefix = cLibPrefix,
				:compileLibCmd = cCompileLibCmdC,
				:precompiledPath = "libs/",
				:currentMode = "dynamic",
				:transformFunction = $cCToRingDataTransFunc
			],

			:Cpp = [
				:name = "C++",
				:type = "compiled",
				:extension = ".cpp",
				:compiler = "g++",
				:outputExt = cOutputExt,
				:datafile = "cppdata.txt",
				:compileCmd = "g++ %source% -o %output%",
				:cleanup = TRUE,
				:libExtension = cLibExtension,
				:libPrefix = cLibPrefix,
				:compileLibCmd = cCompileLibCmdCPP,
				:precompiledPath = "libs/",
				:currentMode = "dynamic",
				:transformFunction = $cCPPToRingDataTransFunc
			]
		]

		#TODO // Add Haxe language (useful for code cross-translation

		# @FunctionAlternativeName

		def ConfitureLanguages()
			This.Configure()

	def WriteToFile(cFile, cContent)
		fp = fopen(cFile, "w")
		fwrite(fp, cContent)
		fclose(fp)

        def ReadFile(cFile)
		if NOT fexists(cFile)
			return NULL
		ok
     
		fp = fopen(cFile, "r")
		if fp = NULL
			return NULL
		end
            
		cContent = fread(fp, fsize(fp))
		fclose(fp)

		return cContent

	def EnsureDirectoryExists(cPath)
		if NOT This.IsDirectory(cPath)
			makedir(cPath)
		end

	def IsDirectory(cPath)
		try
			chdir(cPath)
			return TRUE
		catch
			return FALSE
		end

	def PrecompiledLibraryPath()
		cLibDir = @aLanguages[@cLanguage][:precompiledPath]

		if NOT This.IsDirectory(cLibDir)
			return NULL
		ok
            
		cBaseName = replace(@cSourceFile, "." + @aLanguages[@cLanguage][:extension], "")
		cLibName = @aLanguages[@cLanguage][:libPrefix] + cBaseName + @aLanguages[@cLanguage][:libExtension]

		cFullPath = cLibDir + cLibName

		if This.FileExists(cFullPath)
			return cFullPath
		ok
            
		return NULL

	def BuildCommand()

		if @aLanguages[@cLanguage][:type] = "interpreted"

			cCmd = ""

			if @aLanguages[@cLanguage][:customPath] != ""
				cCmd = @aLanguages[@cLanguage][:customPath] + " " + @cSourceFile
			else
				cCmd = @aLanguages[@cLanguage][:runtime] + " " + @cSourceFile
			ok

		        // Suppress the console window on Windows
			#TODO // Is it necessar since we are using SystemSilen()

		        if isWindows()
		            cCmd = "START /B " + cCmd + " > NUL 2>&1"
		        ok

			return cCmd

		else # Compiled languages

			if @cCompilationMode = "dynamic"

				# Use the batch file for compilation
	
				cCompileCmd = @cBatchFile + " " + @cSourceFile + " " + @cOutputFile
				cOutput = SystemSilent(cCompileCmd)
	                
				# Check compilation status
	
				nStatus = @number(@trim(cOutput))
	
				if nStatus != 0
					stzraise("Compilation failed with status: " + nStatus)
				ok
	                
				# Return the path to execute
	
				if isWindows()
					return @cOutputFile
				else
					return "./" + @cOutputFile
				ok
			ok

			return This.PrecompiledLibraryPath()
		ok

        def RecordExecution(cOutput)

		cMode = ""

		if @aLanguages[@cLanguage][:type] = "compiled"
			cMode = @cCompilationMode
		else
			cMode = "interpreted"
		ok
            
		@aCallTrace + [
			:language = @cLanguage,
			:timestamp = TimeStamp(),
			:duration = (@nEndTime - @nStartTime) / clockspersecond(),
			:output = cOutput,
			:mode = cMode
		]

	def CleanupCompiledFiles()

		if @aLanguages[@cLanguage][:type] = "compiled" and
		   @aLanguages[@cLanguage][:cleanup]

			ring_file_remove(@cOutputFile)
		ok

        def FileExists(cFile)
            return fexists(cFile)


def PrepareSourceCode()

    cTransformFunction = @aLanguages[@cLanguage][:transformFunction]

    # Create properly formatted external language code

    if @cLanguage = "python"

        cFullCode = NL + cTransformFunction + '

# Main code

' +
@cCode + '

transformed = transform_to_ring(data)

with open("'+char(39)+' + @cDataFile + '+char(39)+'", "w") as f:
    f.write(transformed)
'

    but @cLanguage = "julia"

    cFullCode = NL + cTransformFunction + '

# Main code

' +
@cCode + '

transformed = transform_to_ring(data)

# Write data to file without printing to console
open("'+char(39)+' + @cDataFile + '+char(39)+'", "w") do f
    write(f, transformed)
end
'

    return cFullCode

    but @cLanguage = "cpp"
        # For C++, just return the code directly
        return @cCode

    else
        stzraise("Not implemented yet for this language!")
    ok

    return cFullCode
