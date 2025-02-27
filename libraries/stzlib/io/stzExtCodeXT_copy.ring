
# IMPORTANT NOTES FOR PYTHON CODE USED WITH RING INTEGRATION
#
# The transformation engine converts Python data structures to Ring format with these limitations:
#
# 1. Supported data types:
#    - Basic types: int, float, str, bool, None
#    - Collections: dict, list
#    - String representations of dictionaries (will be parsed if possible)
#
# 2. Unsupported or potentially problematic types:
#    - Complex objects (classes, custom types)
#    - Numpy arrays (use .tolist() method)
#    - Pandas DataFrames (convert to dict or list first)
#    - Circular references
#    - Special numeric types (Decimal, complex numbers)
#    - Dates/times (convert to strings)
#
# 3. Best practices:
#    - Convert specialized types to basic types before output
#    - Flatten numpy arrays with .tolist()
#    - Convert all dates/times to string format
#    - Use dict/list/string/number for any data to be transferred to Ring
#    - Avoid storing function objects or class instances in the output data

# IMPORTANT NOTES FOR R CODE USED WITH RING INTEGRATION
#
# The transformation engine converts R data structures to Ring format with these limitations:
#
# 1. Supported data types:
#    - Basic types: numeric, character, logical, NULL, NA
#    - Collections: list, data.frame, vector, array
#
# 2. Unsupported or potentially problematic types:
#    - Complex R objects (S3/S4/R6 classes)
#    - Environments
#    - Functions
#    - Factors (convert to character first)
#    - Circular references
#    - Dates/POSIXt objects (convert to character first)
#
# 3. Best practices:
#    - Convert factors to character vectors with as.character()
#    - Convert dates/times to character with format() or as.character()
#    - Convert specialized objects to lists where possible
#    - Simplify complex data structures before output
#    - Ensure vectors have appropriate names for dictionary-like behavior
#    - Use as.list() for complex objects when appropriate


#--------------------------------------------------#
#  TARGET LANGAUGES DATA TRANSFORMATION FUNCTIONS  #
#--------------------------------------------------#
#~> Embedded automatically within the external code you provide.
#~> They transform the result of the external computation in
#   format that is processable by Ring

# Python transformation function

$cPyToRingTransFunc = '
def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"['+char(39)+'{key}'+char(39)+', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            # Check if the string looks like a Python dictionary
            if obj.startswith("{") and obj.endswith("}"):
                try:
                    # Try to convert the string back to a dictionary using eval
                    # This is safe here because we know the source is from get_params()
                    dict_obj = eval(obj)
                    if isinstance(dict_obj, dict):
                        # If successful, transform the dictionary
                        return _transform(dict_obj)
                except:
                    # If eval fails, just treat it as a normal string
                    pass
            return f"'+char(39)+'{obj}'+char(39)+'"
        elif isinstance(obj, (int, float)):
            return str(obj)
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            return f"'+char(39)+'{str(obj)}'+char(39)+'"
    return _transform(data)
'

# R Transformation Function

$cRToRingTransFunc = '
transform_to_ring <- function(data) {
  transform <- function(obj, depth = 0) {
    # Prevent excessive recursion
    if (depth > 100) {
      return("TOO_DEEP")
    }
    
    # Handle NULL and NA values explicitly
    if (is.null(obj)) {
      return("NULL")
    }
    
    # Handle lists or data frames
    if (is.list(obj) || is.data.frame(obj)) {
      items <- lapply(seq_along(obj), function(i) {
        key <- names(obj)[i]
        value <- transform(obj[[i]], depth + 1)
        if (!is.null(key)) {
          sprintf("['+char(39)+'%s'+char(39)+', %s]", key, value)
        } else {
          value
        }
      })
      return(paste0("[", paste(items, collapse=", "), "]"))
    }
    
    # Handle vectors or arrays
    if (is.vector(obj) || is.array(obj)) {
      if (length(obj) > 1) {
        items <- sapply(obj, function(x) {
          if (is.na(x)) return("NULL") # Changed from "NA" to "NULL"
          transform(x, depth + 1)
        })
        return(paste0("[", paste(items, collapse=", "), "]"))
      } else {
        if (is.na(obj)) return("NULL") # Changed from "NA" to "NULL"
      }
    }
    
    # Handle character strings
    if (is.character(obj)) {
      return(sprintf("'+char(39)+'%s'+char(39)+'", obj))
    }
    
    # Handle numeric values
    if (is.numeric(obj)) {
      return(as.character(obj))
    }
    
    # Handle logical values
    if (is.logical(obj)) {
      return(ifelse(obj, "TRUE", "FALSE"))
    }
    
    # Default case
    return(sprintf("'+char(39)+'%s'+char(39)+'", as.character(obj)))
  }
  
  transform(data, depth = 0)
}
'

# Julia transformation function

$cJuliaToRingTransFunc = '
function transform_to_ring(data)
    function _transform(obj, depth=0)
        # Prevent excessive recursion
        if depth > 100
            return "TOO_DEEP"
        end
        
        # Handle nothing/missing values
        if obj === nothing
            return "NULL"
        end
        
        # Handle dictionaries
        if isa(obj, Dict)
            items = String[]
            for (key, value) in obj
                push!(items, "[\'+char(39)+'$(key)\'+char(39)+', $(_transform(value, depth + 1))]")
            end
            return "[" * join(items, ", ") * "]"
        end
        
        # Handle arrays
        if isa(obj, AbstractArray)
            return "[" * join([_transform(item, depth + 1) for item in obj], ", ") * "]"
        end
        
        # Handle strings
        if isa(obj, AbstractString)
            return "\'+char(39)+'$(obj)\'+char(39)+'"
        end
        
        # Handle numeric values
        if isa(obj, Number)
            return string(obj)
        end
        
        # Handle boolean values
        if isa(obj, Bool)
            return obj ? "TRUE" : "FALSE"
        end
        
        # Default case: convert to string
        return "\'+char(39)+'$(string(obj))\'+char(39)+'"
    end
    
    return _transform(data)
end
'

# Go Transformation Function

$cGoToRingTransFunc = '
// transformToRing converts Go data structures to Ring format
func transformToRing(data interface{}, depth int) string {
    if depth > 100 {
        return "TOO_DEEP"
    }
    if data == nil {
        return "NULL"
    }
    v := reflect.ValueOf(data)
    if v.Kind() == reflect.Ptr {
        if v.IsNil() {
            return "NULL"
        }
        v = v.Elem()
    }
    switch v.Kind() {
    case reflect.Map:
        var items []string
        for _, key := range v.MapKeys() {
            keyStr := fmt.Sprintf("%v", key.Interface())
            valueStr := transformToRing(v.MapIndex(key).Interface(), depth+1)
            items = append(items, fmt.Sprintf("[\'+char(39)+'%s\'+char(39)+', %s]", keyStr, valueStr))
        }
        return "[" + strings.Join(items, ", ") + "]"
    case reflect.Slice, reflect.Array:
        var items []string
        for i := 0; i < v.Len(); i++ {
            items = append(items, transformToRing(v.Index(i).Interface(), depth+1))
        }
        return "[" + strings.Join(items, ", ") + "]"
    case reflect.String:
        return fmt.Sprintf("\'+char(39)+'%s\'+char(39)+'", v.String())
    case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
        return strconv.FormatInt(v.Int(), 10)
    case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
        return strconv.FormatUint(v.Uint(), 10)
    case reflect.Float32, reflect.Float64:
        return strconv.FormatFloat(v.Float(), \'+char(39)+'f\'+char(39)+', -1, 64)
    case reflect.Bool:
        if v.Bool() {
            return "TRUE"
        }
        return "FALSE"
    case reflect.Struct:
        jsonBytes, _ := json.Marshal(data)
        var m map[string]interface{}
        json.Unmarshal(jsonBytes, &m)
        return transformToRing(m, depth+1)
    default:
        return fmt.Sprintf("\'+char(39)+'%v\'+char(39)+'", data)
    }
}
func WriteRingFormat(data interface{}, filename string) error {
    result := transformToRing(data, 0)
    return os.WriteFile(filename, []byte(result), 0644)
}
'

func IsDir(cDir)
	return dirExists(cDir)

#------------------#
#  THE MAIN CLASS  #
#------------------#

class StzExtCodeXT

    # Configuring supported langauges

	@aLanguages = [
	        :python = [
	            :Name = "Python",
	            :Type = "interpreted",
	            :Extension = ".py",
	            :Runtime = "python",
	            :AlternateRuntimes = ["python3", "py"],
	            :ResultFile = "pyresult.txt",
	            :CustomPath = "",
	            :TransFunc = $cPyToRingTransFunc,
	            :Cleanup = FALSE
	        ],
	
	        :r = [
	            :Name = "R",
	            :Type = "interpreted",
	            :Extension = ".R",
	            :Runtime = "Rscript",
	            :AlternateRuntimes = ["R"],
	            :ResultFile = "rresult.txt",
	            :CustomPath = "",
	            :TransFunc = $cRToRingTransFunc,
	            :Cleanup = FALSE
	        ],
	
		:julia = [
		    :Name = "Julia",
		    :Type = "interpreted",
		    :Extension = ".jl",
		    :Runtime = "julia",
		    :AlternateRuntimes = [],
		    :ResultFile = "jlresult.txt",
		    :CustomPath = "",
		    :TransFunc = $cJuliaToRingTransFunc,
		    :Cleanup = FALSE
		],
	
		:go = [
			:Name = "Go",
			:Type = "compiled",
			:Extension = ".go",
			:Runtime = "go",
			:CompilerFlags = "run",
			:ExecutableName = "temp_go",
			:AlternateRuntimes = [],
			:ResultFile = "goresult.txt",
			:CustomPath = "",
			:TransFunc = $cGoToRingTransFunc,
			:Cleanup = FALSE,
			:CaptureBuildErrors = TRUE
		]

	]

	# Other attributes

	@aCallTrace = []
	@cLanguage = ""
	@cCode = ""
	@cSourceFile = "" # will be named automatically 'temp.py'; 'temp.R', etc.

	@cLogFile = "log.txt"
	@cResultFile = ""	# will take whatever name defined in @aLanguages[@cLanguage]
	@cResultVar = "res"	# can be changed with SetResVar()

	@nStartTime = 0
	@nEndTime = 0
	@bVerbose = FALSE	# can be changed using SetVerbose(TRUE)

	def Init(cLang)
		if NOT This.IsLanguageSupported(cLang)
			stzraise("Language '" + cLang + "' is not supported")
		ok

		@cLanguage = lower(cLang)
		@cSourceFile = "temp" + @aLanguages[@cLanguage][:extension]
		@cResultFile = @aLanguages[@cLanguage][:ResultFile]

	def IsLanguageSupported(cLang)
		return @aLanguages[lower(cLang)] != NULL

	def SetRuntimePath(cPath)
		@aLanguages[@cLanguage][:customPath] = cPath

	def SetCode(cNewCode)
		@cCode = cNewCode

	def @(cNewCode)
		@cCode = cNewCode

	def SetVerbose(bVerbose)
		@bVerbose = bVerbose

	def SetResultVar(cResVar)
		if NOT cResVar = ""
			@cResVar = cResVar
		ok

	def Prepare()
		This.WriteToFile(@cSourceFile, This.PrepareSourceCode())

def Execute()
    This.Prepare()

    if @cCode = ""
        return
    end

    if NOT fexists(@cSourceFile)
        stzraise("Source file '" + @cSourceFile + "' not found!")
    ok

    # Create batch file with PATH setup
    cBatchFile = "rungo.bat"
    cGoPath = "C:\\Go\\bin"  # Replace with your actual Go path (use \\ for Windows paths)
    cBatchContent = "SET PATH=" + cGoPath + ";%PATH%" + NL +
                    "go run temp.go > log.txt 2>&1" + NL +
                    "exit %ERRORLEVEL%"
    This.WriteToFile(cBatchFile, cBatchContent)

    # Execute batch file
    cCmd = cBatchFile
    system(cCmd)

    # Read log file
    cLog = This.ReadFile(@cLogFile)
    if cLog = NULL
        cLog = "Log file '" + @cLogFile + "' not found or unreadable"
    ok

    This.RecordExecution(cLog, 0)  # Note: system() doesn’t return exit code reliably

    if @bVerbose
        ? "Command: " + cCmd
        ? "Log: " + cLog
        ? "Working Directory: " + currentdir()
        ? "Source File Exists: " + fexists(@cSourceFile)
        ? "Result File Exists: " + fexists(@cResultFile)
    end

    if NOT fexists(@cResultFile)
        stzraise("Result file '" + @cResultFile + "' not created. Log: " + cLog)
    ok

    # Cleanup
    if fexists(cBatchFile)
        remove(cBatchFile)
    ok
		def Run()
			This.Execute()

		def Exec()
			This.Execute()

	def CleanupFiles()

		if @cLanguage = "go"
			try
				remove(@aLanguages[@cLanguage][:ExecutableName])
				# Remove any Go module files if present
				remove("go.mod")
				remove("go.sum")
				return

			catch
				stzraise(cError)
			done
		ok

		try
		        remove(@cSourceFile)
		        remove(@cResultFile)
			remove(@cLogFile)
		catch
			stzraise(cError)
		done

		def Cleanup()
			This.CleanupFiles()

	def CleanupRequired()
		bResult = @aLanguages[@cLanguage][:Cleanup]
		if isNumber(bResult) and bResult = TRUE
			return TRUE
		else
			return FALSE
		ok

	def LastCallDuration()
		if len(@aCallTrace) > 0
			return @aCallTrace[len(@aCallTrace)][:duration]
		end
		return 0

	def Duration()
		return LastCallDuration()

	def CallTrace()
		return @aCallTrace

	def Trace()
		return @aCallTrace

	def Result()

		if NOT fexists(@cResultFile)

			if @cLanguage = "go" and @bVerbose
				stzraise("File does not exist!" + NL + NL +
				"Log content (from Go console):" + NL +
				"-----------------------------" + NL + NL +
				This.Log() + NL +
				"-----------------------------" + NL +
				"End of log file content.")
			ok

			stzraise("File does not exist!" + NL + NL +

			"Log content (from " + @cLanguage + " console): " + NL +
			"------------------" + copy("-", len(@cLanguage)) + "----------" + NL + NL +
			This.Log() + NL + NL +
			"------------------------" + NL +
			"End of log file content.")
		ok

		cContent = This.ReadFile(@cResultFile)

		if cContent = ""
			return ""
		ok

		try
			cCode = 'result = ' + cContent
			eval(cCode)

			if CleanupRequired()
				This.CleanupFiles()
			ok

			return result

		catch
			? "Eval error: " + cCatchError + NL
			? "Log content: " + This.Log()

			return cContent
		done

	def FileName()
		return @cResultFile

	def ResultVar()
		return @cResultVar

	def RuntimePath()
		return @aLanguage[@cLanguage][:RuntimePath]

	def IsVerbose()
		return @bVerbose

	def SetLogFile(cFileName)
		@cLogFile = cFileName


	def LogFile()
		return This.ReadFile(@cLogFile)

		def Log()
			return This.LogFile()

	def Code()
		if NOT fexists(@cSourceFile)
			return ""
		ok
		return This.ReadFile(@cSourceFile)

	#======
	PRIVATE
	#======

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

	def BuildCommand()

		if @aLanguages[@cLanguage][:type] = "interpreted"

			cCmd = ""

			if @aLanguages[@cLanguage][:customPath] != ""
				cCmd = @aLanguages[@cLanguage][:customPath] + " " + @cSourceFile
			else
				cCmd = @aLanguages[@cLanguage][:runtime] + " " + @cSourceFile
			ok

			return cCmd

		but @aLanguages[@cLanguage][:type] = "compiled"

		        if @cLanguage = "go"
		            # For Go, use "go run" for simplicity instead of compile+execute
		            # This avoids binary naming issues and simplifies error capture

		            return @aLanguages[@cLanguage][:Runtime] + " run " + @cSourceFile
		        ok

		ok


		stzraise("Can't build the command! Seems the language you provided is  not supported.")


	def RecordExecution(cLog, nExitCode)

		cMode = @aLanguages[@cLanguage][:type]

		if (cMode != "interpreted" and cMode != "compiled")
			stzraise("Incorrect langguage type! Type must be 'interpreted' or 'compiled'.")
		ok

		@aCallTrace + [
			:Language = @cLanguage,
			:Timestamp = TimeStamp(),
			:Duration = (@nEndTime - @nStartTime) / clockspersecond(),
			:Log = cLog,
			:Exitcode = nExitCode,
			:Mode = cMode
		]


	def PrepareSourceCode()

        	cTransFunc = @aLanguages[@cLanguage][:TransFunc]

		#---- PYTHON ---

        	if @cLanguage = "python"

            		cFullCode = NL + cTransFunc + '
# Main code
print("Python script starting...")
' + @cCode + '
print("Data before transformation:", ' + @cResultVar + ')
transformed = transform_to_ring(' + @cResultVar + ')
print("Data after transformation:", transformed)
with open("' + @cResultFile + '", "w") as f:
    f.write(transformed)
print("Data written to file")
'
			return cFullCode

		#---- R ---

		but @cLanguage = "r"

			cFullCode = cTransFunc + '
			# Main code
			cat("R script starting...\n")
			' + @cCode + '
			transformed <- transform_to_ring(' + @cResultVar + ')
			writeLines(transformed, "' + @cResultFile + '")
			cat("Data written to file\n")
			'
			return cFullCode

		#---- JULIA ---

		but @cLanguage = "julia"

			cFullCode = cTransFunc + '
			# Main code
			println("Julia script starting...")
			' + @cCode + '
			transformed = transform_to_ring(' + @cResultVar + ')
			println("Data before transformation: ", ' + @cResultVar + ')
			println("Data after transformation: ", transformed)
			open("' + @cResultFile + '", "w") do f
			    write(f, transformed)
			end
			println("Data written to file")
			'
	
			return cFullCode

		#---- GO ---

#---- GO ---
but @cLanguage = "go"
    # Define common characters
    cDoubleQuote = char(34)  # "

    cFullCode = '
package main
import (
    ' + cDoubleQuote + 'fmt' + cDoubleQuote + '
    ' + cDoubleQuote + 'reflect' + cDoubleQuote + '
    ' + cDoubleQuote + 'strconv' + cDoubleQuote + '
    ' + cDoubleQuote + 'strings' + cDoubleQuote + '
    ' + cDoubleQuote + 'os' + cDoubleQuote + '
    ' + cDoubleQuote + 'encoding/json' + cDoubleQuote + '
)

// transformToRing converts Go data structures to Ring format
func transformToRing(data interface{}, depth int) string {
    if depth > 100 {
        return ' + cDoubleQuote + 'TOO_DEEP' + cDoubleQuote + '
    }
    if data == nil {
        return ' + cDoubleQuote + 'NULL' + cDoubleQuote + '
    }
    v := reflect.ValueOf(data)
    if v.Kind() == reflect.Ptr {
        if v.IsNil() {
            return ' + cDoubleQuote + 'NULL' + cDoubleQuote + '
        }
        v = v.Elem()
    }
    switch v.Kind() {
    case reflect.Map:
        var items []string
        for _, key := range v.MapKeys() {
            keyStr := fmt.Sprintf("%v", key.Interface())
            valueStr := transformToRing(v.MapIndex(key).Interface(), depth+1)
            items = append(items, fmt.Sprintf(' + cDoubleQuote + "['%s', %s]" + cDoubleQuote + ', keyStr, valueStr))
        }
        return ' + cDoubleQuote + '[' + cDoubleQuote + ' + strings.Join(items, ' + cDoubleQuote + ', ' + cDoubleQuote + ') + ' + cDoubleQuote + ']' + cDoubleQuote + '
    case reflect.Slice, reflect.Array:
        var items []string
        for i := 0; i < v.Len(); i++ {
            items = append(items, transformToRing(v.Index(i).Interface(), depth+1))
        }
        return ' + cDoubleQuote + '[' + cDoubleQuote + ' + strings.Join(items, ' + cDoubleQuote + ', ' + cDoubleQuote + ') + ' + cDoubleQuote + ']' + cDoubleQuote + '
    case reflect.String:
        return fmt.Sprintf(' + cDoubleQuote + "'%s'" + cDoubleQuote + ', v.String())
    case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
        return strconv.FormatInt(v.Int(), 10)
    case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
        return strconv.FormatUint(v.Uint(), 10)
    case reflect.Float32, reflect.Float64:
        return strconv.FormatFloat(v.Float(), ' + char(39) + 'f' + char(39) + ', -1, 64)
    case reflect.Bool:
        if v.Bool() {
            return ' + cDoubleQuote + 'TRUE' + cDoubleQuote + '
        }
        return ' + cDoubleQuote + 'FALSE' + cDoubleQuote + '
    case reflect.Struct:
        jsonBytes, _ := json.Marshal(data)
        var m map[string]interface{}
        json.Unmarshal(jsonBytes, &m)
        return transformToRing(m, depth+1)
    default:
        return fmt.Sprintf(' + cDoubleQuote + "'%v'" + cDoubleQuote + ', data)
    }
}

func WriteRingFormat(data interface{}, filename string) error {
    result := transformToRing(data, 0)
    return os.WriteFile(filename, []byte(result), 0644)
}

func main() {
    fmt.Println(' + cDoubleQuote + 'Go program starting...' + cDoubleQuote + ')
    // Main code
    ' + @cCode + '
    // Convert result to interface{} for transformation
    var result interface{} = ' + @cResultVar + '
    // Write to result file
    WriteRingFormat(result, ' + cDoubleQuote + @cResultFile + cDoubleQuote + ')
    fmt.Println(' + cDoubleQuote + 'Data written to file:' + cDoubleQuote + ', ' + @cResultVar + ')
}
'
    return cFullCode

        	else
            		stzraise("Not implemented yet for this language!")
        	ok
