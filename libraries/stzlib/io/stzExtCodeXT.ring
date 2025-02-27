#  TARGET LANGAUGES DATA TRANSFORMATION FUNCTIONS  #

#~> Embedded automatically within the external code you provide.
#~> They transform the result of the external computation in
#   format that is processable by Ring


#------------------#
#  THE MAIN CLASS  #
#------------------#

class StzExtCodeXT
    # Configuring supported languages with full paths
    @aLanguages = [
        :python = [
            :Name = "Python",
            :Type = "interpreted",
            :Extension = ".py",
            :Runtime = "python",
            :AlternateRuntimes = ["python3", "py"],
            :ResultFile = "pyresult.txt",
            :CustomPath = "C:\\Python312\\python.exe",  # Replace with your Python path
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
            :CustomPath = "C:\\R\\R-4.4.2\\bin\\Rscript.exe",  # Replace with your R path
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
            :CustomPath = "C:\\Users\\MSI\\.julia\\juliaup\\julia-1.11.3+0.x64.w64.mingw32\\bin\\julia.exe",  # Replace with your Julia path
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
            :CustomPath = "C:\\Go\\bin\\go.exe",  # Replace with your Go path
            :TransFunc = $cGoToRingTransFunc,
            :Cleanup = FALSE,
            :CaptureBuildErrors = TRUE
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
            :CustomPath = "C:\\Go\\bin\\go.exe",  # Replace with your Go path
            :TransFunc = $cGoToRingTransFunc,
            :Cleanup = FALSE,
            :CaptureBuildErrors = TRUE
        ],

        :C = [
            :Name = "C",
            :Type = "compiled",
            :Extension = ".c",
            :Runtime = "gcc",
            :CompilerFlags = "-o temp_c",
            :ExecutableName = "temp_c",
            :AlternateRuntimes = [],
            :ResultFile = "cresult.txt",
            :CustomPath = "C:\\msys64\\ucrt64\\bin\\gcc.exe",  # Replace with your Go path
            :TransFunc = $cCToRingTransFunc,
            :Cleanup = FALSE,
            :CaptureBuildErrors = TRUE
        ]

    ]

    # Other attributes
    @aCallTrace = []
    @cLanguage = ""
    @cCode = ""
    @cSourceFile = ""  # Auto-named like 'temp.py', 'temp.go', etc.
    @cLogFile = "log.txt"
    @cResultFile = ""  # Set from @aLanguages[@cLanguage][:ResultFile]
    @cResultVar = "res"  # Configurable with SetResVar()
    @nStartTime = 0
    @nEndTime = 0
    @bVerbose = FALSE  # Toggle with SetVerbose()

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
        # Set custom runtime path for the language
        @aLanguages[@cLanguage][:CustomPath] = cPath

    def SetCode(cNewCode)
        @cCode = cNewCode

    def @(cNewCode)
        @cCode = cNewCode

    def SetVerbose(bVerbose)
        @bVerbose = bVerbose

    def SetResultVar(cResVar)
        if NOT cResVar = ""
            @cResultVar = cResVar
        ok

    def Prepare()
	This.Cleanup()
        This.WriteToFile(@cSourceFile, This.PrepareSourceCode())

   def Execute()
    	This.Prepare()

    	if @cCode = ""
        	return
    	end

    	if NOT fexists(@cSourceFile)
        	stzraise("Source file '" + @cSourceFile + "' not found!")
    	ok

    	@nStartTime = clock()

    	cRuntime = @aLanguages[@cLanguage][:CustomPath]
    	if cRuntime = ""
        	cRuntime = @aLanguages[@cLanguage][:Runtime]
    	ok

    	cScriptFile = "run" + @cLanguage

    	if isWindows()
        	cScriptFile += ".bat"
        	cScriptContent = "@echo off" + NL

        	if @aLanguages[@cLanguage][:Type] = "compiled"
            		if @cLanguage = "c"
                		# Compile and run separately for C
                		cScriptContent += cRuntime + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
                                 "if %ERRORLEVEL% EQU 0 " + @aLanguages[@cLanguage][:ExecutableName] + ".exe >> " + @cLogFile + " 2>&1" + NL
            		ok
        	else
            		# Interpreted languages (Python, R, Julia)
		        cScriptContent += cRuntime + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
        	ok

        	cScriptContent += "exit %ERRORLEVEL%"

    	else
        	cScriptFile += ".sh"
        	cScriptContent = "#!/bin/bash" + NL

        	if @aLanguages[@cLanguage][:Type] = "compiled"

            		if @cLanguage = "c"

                		# Compile and run separately for C
                		cScriptContent += cRuntime + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL +
                                 "if [ $? -eq 0 ]; then ./" + @aLanguages[@cLanguage][:ExecutableName] + " >> " + @cLogFile + " 2>&1; fi" + NL
 	            	ok
        	else
            		# Interpreted languages (Python, R, Julia)
            		cScriptContent += cRuntime + " " + @cSourceFile + " > " + @cLogFile + " 2>&1" + NL
        	ok

        	cScriptContent += "exit $?"
    	ok

    	This.WriteToFile(cScriptFile, cScriptContent)

    	cCmd = cScriptFile
   	 system(cCmd)

    	@nEndTime = clock()

    	cLog = This.ReadFile(@cLogFile)

    	if cLog = NULL
        	cLog = "Log file '" + @cLogFile + "' not found or unreadable"
    	ok

    	This.RecordExecution(cLog, 0)

    	if @bVerbose
        	? "Command: " + cCmd
        	? "Log: " + cLog
        	? "Working Directory: " + currentdir()
        	? "Source File Exists: " + fexists(@cSourceFile)
        	? "Result File Exists: " + fexists(@cResultFile)
    	ok

    	if NOT fexists(@cResultFile)
        	stzraise("Result file '" + @cResultFile + "' not created. Log: " + cLog)
    	ok

    	if fexists(cScriptFile)
        	remove(cScriptFile)
    	ok
	
	#< @FunctionAlternativeForms

    	def Run()
       		This.Execute()

	def Exec()
	        This.Execute()
	#>

    def CleanupFiles()
	# TODO: does this cover cleaning compiled languages files?

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
        return isNumber(bResult) and bResult = TRUE

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
	    cContent = ring_substr2(cContent, "\n", NL)
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
        return @aLanguages[@cLanguage][:CustomPath]

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

    #====== PRIVATE METHODS ======#

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
        # Not used with batch approach, kept for compatibility
        if @aLanguages[@cLanguage][:type] = "interpreted"
            cCmd = @aLanguages[@cLanguage][:runtime] + " " + @cSourceFile
            if @aLanguages[@cLanguage][:customPath] != ""
                cCmd = @aLanguages[@cLanguage][:customPath] + " " + @cSourceFile
            ok
            return cCmd
        but @aLanguages[@cLanguage][:type] = "compiled"
            return @aLanguages[@cLanguage][:Runtime] + " " + @aLanguages[@cLanguage][:CompilerFlags] + " " + @cSourceFile
        ok
        stzraise("Unsupported language type for " + @cLanguage)

    def RecordExecution(cLog, nExitCode)
        cMode = @aLanguages[@cLanguage][:type]
        if cMode != "interpreted" and cMode != "compiled"
            stzraise("Incorrect language type! Must be 'interpreted' or 'compiled'.")
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
        cDoubleQuote = char(34)  # "
        cSingleQuote = char(39)  # '

        if @cLanguage = "python"
            return NL + cTransFunc + '
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

        but @cLanguage = "r"
            return cTransFunc + '
# Main code
cat("R script starting...\n")
' + @cCode + '
transformed <- transform_to_ring(' + @cResultVar + ')
writeLines(transformed, "' + @cResultFile + '")
cat("Data written to file\n")
'

        but @cLanguage = "julia"
            return cTransFunc + '
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
      but @cLanguage = "go"
            return '
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
        return strconv.FormatFloat(v.Float(), ' + cSingleQuote + 'f' + cSingleQuote + ', -1, 64)
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
but @cLanguage = "c"
    return $cCToRingTransFunc + '
int main() {
    printf("C program starting...\n");
    ' + @cCode + '
    transform_res_to_ring(res, "' + @cResultFile + '");
    printf("Data written to file.\n");
    return 0;
}
'
        else
            stzraise("Not implemented yet for this language!")
        ok
