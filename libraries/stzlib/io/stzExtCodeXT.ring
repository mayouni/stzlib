

# StzExtCode Class
# ----------------

# Provides a unified interface for executing code in external
# programming languages, from inside Ring code, working currently
# for Python, but made for easy extension to other languages.


# A function in Python tha ttranforms Python output to
# Ring-freindly stringified format (stored in a file)
#~> Embedded automatically with the user code provided
# in Pyhton to the class (transparent to the user)

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

class StzExtCodeXT
    
	# Supported languages configuration

	@aLanguages = [] # Only Python is supported currently

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

	# Supported langauges (only Python is supported currently)

	@aLanguages = [

		:python = [
			:name = "Python",
			:type = "interpreted",
			:extension = ".py",
			:runtime = "python",
			:alternateRuntimes = ["python3", "py"],
			:datafile = "pydata.txt",
			:customPath = "",
			:transformFunction = $cPyToRingDataTransFunc,
			:cleanup = TRUE

		]

	]

	def Init(cLang)
 
		if NOT This.IsLanguageSupported(cLang)
			stzraise("Language '" + cLang + "' is not supported")
		ok

		@cLanguage = lower(cLang)
		@cSourceFile = "temp" + @aLanguages[@cLanguage][:extension]
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

	# Prepare code for execution

	def Prepare()

		remove(@cSourceFile)
		remove(@cDataFile)

		# Write source code to file

		This.WriteToFile(@cSourceFile, This.PrepareSourceCode())

		# @functionFluentForm

		def PrepareQ()
			This.Prepare()
			return This

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
		cOutput = system(cCmd)

		@nEndTime = clock()
    
		This.RecordExecution(cOutput)

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

	# Get data from the exchange file

	def Result()

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

		def FileData()
			return This.Result()

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

	def BuildCommand()

		if @aLanguages[@cLanguage][:type] = "interpreted"

			cCmd = ""

			if @aLanguages[@cLanguage][:customPath] != ""
				cCmd = @aLanguages[@cLanguage][:customPath] + " " + @cSourceFile
			else
				cCmd = @aLanguages[@cLanguage][:runtime] + " " + @cSourceFile
			ok

			return cCmd

		else # Compiled languages

			stzraise("Only intrepreted langauges, namely Python, are currently supported!")
		ok

        def RecordExecution(cOutput)

		cMode = ""

		if @aLanguages[@cLanguage][:type] = "interpreted"
			cMode = "interpreted"
		else
			stzraise("Only intrepreted langauges, namely Python, are currently supported!")
		ok
            
		@aCallTrace + [
			:language = @cLanguage,
			:timestamp = TimeStamp(),
			:duration = (@nEndTime - @nStartTime) / clockspersecond(),
			:output = cOutput,
			:mode = cMode
		]

        def FileExists(cFile)
            return fexists(cFile)


	def PrepareSourceCode()

		cTransformFunction = @aLanguages[@cLanguage][:transformFunction]

		# Create properly formatted external language code

		if @cLanguage = "python"

			cFullCode = NL + cTransformFunction + '

# Main code
print("Python script starting...")

' +
@cCode + '

print("Data before transformation:", data)
transformed = transform_to_ring(data)
print("Data after transformation:", transformed)

with open("' + @cDataFile + '", "w") as f:
    f.write(transformed)

print("Data written to file")
'

			return cFullCode

		else
			
			stzraise("Not implemented yet for this language!")
		ok
