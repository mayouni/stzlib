#============================================================#
#  stzImgToAscii.ring   →   Maximum simplified version
#  Uses only built-in system() + read()/remove() 
#  Keeps 100% of the features and full chainability
#============================================================#

if Haskey($aStzLibConfig, :Img2AnsiPath) and $aStzLibConfig[:Img2AnsiPath] != ""
    $cImg2AnsiExe = $aStzLibConfig[:Img2AnsiPath]
else
    $cImg2AnsiExe = "../tools/im2ansi/im2ansi.exe"   # works when running from /test
ok

$acFormats = [ "ansi", "ascii", "svg", "html" ]

func StzImgToAsciiQ(pcImagePath)
    return new stzImgToAscii(pcImagePath)

    func ImgToAsciiQ(pcImagePath)
        return StzImgToAsciiQ(pcImagePath)

class stzImgToAscii

    @cExe      = $cImg2AnsiExe
    @cImage    = ""
    @cFormat   = "ansi"
    @nHeight   = 30
    @nWidth    = NULL
    @cChars    = NULL      # custom character set
    @nRamp     = 1         # 1-12 for ascii
    @bInvert   = FALSE
    @bNoColor  = FALSE
    @nSeed     = NULL
    @cOutFile  = ""        # user-specified output file
    @cOutDir   = "output"
    @cTempDir  = "temp"
    @cContent  = ""
    @cFile     = ""
    @bRan      = FALSE
    @bVerbose  = FALSE

    def init(pcImage = "")
        if pcImage != "" { This.Image(pcImage) }
        This.EnsureDirs()

    def EnsureDirs()
        dir_create(@cTempDir)
        dir_create(@cOutputDir)

    def Image(pc)          { @cImage = pc ; if NOT fexists(pc) stzraise("Image not found: " + pc) ok ; return This }
    def Format(pc)         { pc=lower(pc) ; if ring_find($acFormats,pc)=0 stzraise("Unsupported format") ok ; @cFormat=pc ; return This }
    def Height(n)          { @nHeight = n ; return This }
    def Width(n)           { @nWidth  = n ; return This }
    def Chars(pc)          { @cChars  = pc ; return This }
    def Ramp(n)            { if n<1 or n>12 stzraise("Ramp 1-12 only") ok ; @nRamp = n ; return This }
    def Invert(b=TRUE)     { @bInvert = b ; return This }
    def NoColor(b=TRUE)    { @bNoColor = b ; return This }
    def Seed(n)            { @nSeed = n ; return This }
    def Verbose(b=TRUE)    { @bVerbose = b ; return This }
    def OutputFile(pc)     { @cOutFile = pc ; return This }

    def Execute()
        This.EnsureDirs()

        if @cImage = "" { stzraise("No image set") }

        aArgs     = This.BuildArgs()
        cArgsStr  = ""
        for x in aArgs { cArgsStr += x + " " }
        cArgsStr  = rtrim(cArgsStr," ")

        cCmd = @@(@cExe) + " " + cArgsStr

        # ───── Determine output destination ─────
        cDestFile = @cOutFile

        if cDestFile = "" and @cFormat in ["svg","html"]
            cExt = (@cFormat="html" ? "html" : "svg")
            cDestFile = @cOutDir + "/img2ansi_" + clock() + "." + cExt
        ok

        if @bVerbose { ? "CMD: " + cCmd ; if cDestFile!="" ? " → " + cDestFile ok }

        if cDestFile != ""
            # output to real file
            cCmd += " -o " + @@(cDestFile)
            nExit = system(cCmd)
            if nExit != 0 or NOT fexists(cDestFile)
                stzraise("im2ansi failed (exit " + nExit + ")")
            ok
            @cFile    = cDestFile
            @cContent = ""
        else
            # capture stdout (ansi / ascii)
            cTemp = @cTempDir + "/_tmp_" + clock() + ".txt"
            cCmd += " > " + @@(cTemp) + " 2>&1"
            nExit = system(cCmd)
            if nExit != 0
                cErr = read(cTemp)
                remove(cTemp)
                stzraise("im2ansi error: " + cErr)
            ok
            @cContent = read(cTemp)
            remove(cTemp)
            @cFile = ""
        ok

        @bRan = TRUE

        def Run()    { This.Execute() }
        def Go()     { This.Execute() }

    def Content()
        if NOT @bRan { This.Execute() }
        if @cContent = "" and @cFile != ""
            @cContent = read(@cFile)
        ok
        return @cContent

    def Show()
        if NOT @bRan { This.Execute() }

        if @cFile != ""
            # open file with OS default viewer
                 if iswindows() { system('start "" ' + @@(@cFile)) }
            elif ismacosx()     { system("open " + @@(@cFile)) }
            elif islinux()      { system("xdg-open " + @@(@cFile)) }
            ok
        else
            ? This.Content()
        ok

        def View()    { This.Show() }
        def Display() { This.Show() }

    def ExecuteAndShow() { This.Execute() ; This.Show() }
        def RunAndView() { This.ExecuteAndShow() }
        def XT()         { This.ExecuteAndShow() }
        def GoXT()       { This.ExecuteAndShow() }

    def OutputFile() { return @cFile }

    private

    def BuildArgs()
        a = [ "-p", @@(@cImage) ]

        if @cFormat != "ansi"   { a + "-f" + @cFormat }
        a + "-s" + @nHeight
        if isNumber(@nWidth)    { a + "-w" + @nWidth }
        if @bInvert             { a + "-i" }
        if @bNoColor            { a + "--no-color" }
        if isNumber(@nSeed)     { a + "--seed" + @nSeed }
        if @cChars != NULL      { a + "-c" + @@(@cChars) }
        if @cFormat = "ascii"   { a + "-r" + @nRamp }

        return a
    end
