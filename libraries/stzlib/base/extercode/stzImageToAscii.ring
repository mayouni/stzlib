#============================================================#
#  stzImageToAscii.ring  -  the class stzImgToAscii
#  Runs the external im2ansi tool through stzSystemCall
#  (program + argument list, no shell) and keeps the text
#  or the file it produces. Full chainability.
#============================================================#

if Haskey($aStzLibConfig, :Img2AnsiPath)
    if $aStzLibConfig[:Img2AnsiPath] != ""
        $cImg2AnsiExe = $aStzLibConfig[:Img2AnsiPath]
    else
        $cImg2AnsiExe = "../tools/im2ansi/im2ansi.exe"   # works when running from /test
    ok
else
    $cImg2AnsiExe = "../tools/im2ansi/im2ansi.exe"   # works when running from /test
ok

$acFormats = [ "ansi", "ascii", "svg", "html" ]

func StzImgToAsciiQ(pcImagePath)
    return new stzImgToAscii(pcImagePath)

    func ImgToAsciiQ(pcImagePath)
        return StzImgToAsciiQ(pcImagePath)

# Turns an image into text art (ansi, ascii, svg or html) by running the external im2ansi tool, and keeps the text or the file.
#
# Give the image, set the options (format, height, width, ramp, invert, no colour, seed, characters,
# output file), then read Content or call Show; Execute runs the tool and the other two run it when
# nothing ran yet. The tool is started as a program with a list of arguments, with no shell between,
# so a path holding spaces reaches it intact. The class is loaded by naming its file; no loader of
# the library does it.
#
#   receiver   o1 = StzImgToAsciiQ("photo.png")
#   example    o1.Format("ascii")
#              ? o1.Content()
#   warning    needs the real im2ansi tool, which is not in the library: its path is the value of
#              the key Img2AnsiPath of $aStzLibConfig, read when the file is loaded, or
#              ../tools/im2ansi/im2ansi.exe; without it Execute raises an error
#   see        stzExterCode, stzDotCode, stzSystemCall
class stzImgToAscii from stzObject

    @cExe      = $cImg2AnsiExe
    @cImage    = ""
    @cFormat   = "ansi"
    @nHeight   = 30
    @nWidth    = ""
    @cChars    = ""        # custom character set
    @nRamp     = 1         # 1-12 for ascii
    @bInvert   = 0
    @bNoColor  = 0
    @nSeed     = ""
    @cOutFile  = ""        # user-specified output file
    @cOutDir   = "output"
    @cTempDir  = "temp"
    @cContent  = ""
    @cFile     = ""
    @bRan      = 0
    @bVerbose  = 0

    # Builds the converter, with the image to convert when one is given, and creates its temp and output folders.
    #
    #   pcImage    the path of the image to convert, an empty text for none
    #   returns    nothing; the object is built
    #   warning    the parameter is required, since Ring has no default values: give an empty text
    #              for none; an image path that does not exist raises the error Image not found;
    #              the folders temp and output are created in the current folder
    #   see        Image, EnsureDirs
    def init(pcImage)
        if pcImage != ""
            This.Image(pcImage)
        ok
        This.EnsureDirs()

    # Creates the temp and output folders of the converter when they are missing.
    #
    #   returns    nothing; both folders exist afterwards
    #   warning    the folders are named relative to the current folder; a folder that cannot be
    #              created raises the error Cannot create folder
    #   see        init, Execute
    def EnsureDirs()
        if NOT StzMakeDir(@cTempDir)
            stzraise("Cannot create folder: " + @cTempDir)
        ok
        if NOT StzMakeDir(@cOutDir)
            stzraise("Cannot create folder: " + @cOutDir)
        ok

    # Sets the image the tool will convert, after checking that the file exists, and returns the object.
    #
    #   pc         the path of the image file, as text
    #   returns    the object, to chain
    #   warning    a path that is not an existing file raises the error Image not found
    #   see        init, Execute
    def Image(pc)
        if NOT fexists(pc)
            stzraise("Image not found: " + pc)
        ok
        @cImage = pc
        return This

    # Chooses the kind of text the tool produces and returns the object.
    #
    #   pc         the format, as text: ansi, ascii, svg or html, in any case
    #   returns    the object, to chain
    #   note       svg and html are written to a file; ansi and ascii are printed by the tool
    #   warning    any other format raises the error Unsupported format
    #   see        Execute, Content
    def Format(pc)
        pc = StzLower(pc)
        if StzFindFirst(pc, $acFormats) = 0
            stzraise("Unsupported format")
        ok
        @cFormat = pc
        return This

    # Sets the height asked of the tool, sent as its -s option, and returns the object.
    #
    #   n          the height, as a number; 30 when never set
    #   returns    the object, to chain
    #   see        Width, BuildArgs
    def Height(n)
        @nHeight = n
        return This

    # Sets the width asked of the tool, sent as its -w option, and returns the object.
    #
    #   n          the width, as a number; no width is sent when never set
    #   returns    the object, to chain
    #   see        Height, BuildArgs
    def Width(n)
        @nWidth = n
        return This

    # Sets a custom set of characters, sent as the -c option of the tool, and returns the object.
    #
    #   pc         the characters, as text; none is sent when never set
    #   returns    the object, to chain
    #   see        Ramp, Format
    def Chars(pc)
        @cChars = pc
        return This

    # Sets the ramp number sent to the tool as its -r option for the ascii format, and returns the object.
    #
    #   n          the ramp number, from 1 to 12; 1 when never set
    #   returns    the object, to chain
    #   warning    a number outside 1 to 12 raises the error Ramp 1-12 only
    #   see        Chars, Format
    def Ramp(n)
        if n < 1 or n > 12
            stzraise("Ramp 1-12 only")
        ok
        @nRamp = n
        return This

    # Asks the tool to invert the image, with its -i option, and returns the object.
    #
    #   returns    the object, to chain
    #   see        SetInvert, NoColor
    def Invert()
        @bInvert = 1
        return This

    # Turns the inversion on or off and returns the object.
    #
    #   b          1 to invert, 0 to leave the image as it is
    #   returns    the object, to chain
    #   see        Invert
    def SetInvert(b)
        @bInvert = b
        return This

    # Asks the tool for plain output, with its --no-color option, and returns the object.
    #
    #   returns    the object, to chain
    #   see        SetNoColor, Invert
    def NoColor()
        @bNoColor = 1
        return This

    # Turns the colourless output on or off and returns the object.
    #
    #   b          1 for no colour, 0 for colour
    #   returns    the object, to chain
    #   see        NoColor
    def SetNoColor(b)
        @bNoColor = b
        return This

    # Sets the seed sent to the tool as its --seed option and returns the object.
    #
    #   n          the seed, as a number; none is sent when never set
    #   returns    the object, to chain
    #   see        BuildArgs
    def Seed(n)
        @nSeed = n
        return This

    # Makes the next runs print the command line and the output file they use, and returns the object.
    #
    #   returns    the object, to chain
    #   see        SetVerbose, Execute
    def Verbose()
        @bVerbose = 1
        return This

    # Turns the printing of the command line on or off and returns the object.
    #
    #   b          1 to print, 0 to stay silent
    #   returns    the object, to chain
    #   see        Verbose
    def SetVerbose(b)
        @bVerbose = b
        return This

    # Sets the file the tool writes its result to, instead of printing the text, and returns the object.
    #
    #   pc         the path of the file, as text; an empty text goes back to the default
    #   returns    the object, to chain
    #   see        OutputFile, Execute
    def SetOutputFile(pc)
        @cOutFile = pc
        return This

    # Runs the im2ansi tool on the image and keeps the text it prints, or the file it writes for svg, html or a chosen output file.
    #
    #   returns    nothing; read Content or OutputFile afterwards
    #   note       Run and Go are the same call; the output file defaults to a name in the output
    #              folder for the svg and html formats; a run that fails leaves no text and no file
    #              kept
    #   warning    needs the real im2ansi tool (not in the library) and starts it as a real program;
    #              with no image set it raises the error No image set, and a tool that exits with a
    #              code other than 0, or writes no file when one was asked, raises the error im2ansi
    #              failed
    #   see        Content, Show, OutputFile
    def Execute()
        This.EnsureDirs()

        @bRan     = 0
        @cContent = ""
        @cFile    = ""

        if @cImage = ""
            stzraise("No image set")
        ok

        _aArgs_ = This.BuildArgs()

        # ----- Determine output destination -----
        _cDestFile_ = @cOutFile

        if _cDestFile_ = "" and (@cFormat = "svg" or @cFormat = "html")
            _cDestFile_ = @cOutDir + "/img2ansi_" + clock() + "." + @cFormat
        ok

        if _cDestFile_ != ""
            _aArgs_ + "-o"
            _aArgs_ + _cDestFile_
        ok

        if @bVerbose
            _cCmd_ = @cExe
            _nArgs_ = len(_aArgs_)
            for _i_ = 1 to _nArgs_
                _cCmd_ += " " + _aArgs_[_i_]
            next
            ? "CMD: " + _cCmd_
            if _cDestFile_ != ""
                ? " -> " + _cDestFile_
            ok
        ok

        _oCall_ = new stzSystemCall("im2ansi")
        _oCall_.SetProgram(@cExe)
        _oCall_.SetArgs(_aArgs_)
        _oCall_.HideConsole()
        _oCall_.Run()

        if NOT _oCall_.Succeeded()
            stzraise("im2ansi failed (exit " + _oCall_.ExitCode() + ", tool " + @cExe + "): " + _oCall_.Error())
        ok

        if _cDestFile_ != ""
            # output to real file
            if NOT fexists(_cDestFile_)
                stzraise("im2ansi failed (exit " + _oCall_.ExitCode() + "): no output file " + _cDestFile_)
            ok
            @cFile = _cDestFile_
        else
            # captured stdout (ansi / ascii)
            @cContent = _oCall_.Output()
        ok

        @bRan = 1

        # Runs the tool on the image, exactly as the main call does.
        #
        #   returns    nothing; read Content or OutputFile afterwards
        #   warning    needs the real im2ansi tool, not in the library, see Execute
        #   see        Execute, Content
        def Run()
            This.Execute()

        # Runs the tool on the image, exactly as the main call does.
        #
        #   returns    nothing; read Content or OutputFile afterwards
        #   warning    needs the real im2ansi tool, not in the library, see Execute
        #   see        Execute, Content
        def Go()
            This.Execute()

    # Returns the converted image as text, running the tool first when it did not run yet.
    #
    #   returns    a text: what the tool printed, or the content of the file it wrote; an empty text
    #              when the file holds nothing
    #   warning    needs the real im2ansi tool (not in the library) the first time, see Execute
    #   see        Execute, Show
    def Content()
        if NOT @bRan
            This.Execute()
        ok
        if @cContent = "" and @cFile != ""
            @cContent = read(@cFile)
        ok
        return @cContent

    # Prints the converted image, or opens the file the tool wrote in the program the system associates with it.
    #
    #   returns    nothing
    #   warning    needs the real im2ansi tool (not in the library) when nothing ran yet; for the svg
    #              and html formats, or an output file chosen with OutputFile, it starts the viewer
    #              of the operating system and opens a window, unless the environment variable
    #              STZ_NO_VIEW is set
    #   see        Content, Execute
    def Show()
        if NOT @bRan
            This.Execute()
        ok

        if @cFile != ""
            This.OpenViewer(@cFile)
        else
            ? This.Content()
        ok

        # Prints the converted image or opens its file, exactly as the main call does.
        #
        #   returns    nothing
        #   warning    can open a window on the screen, see Show
        #   see        Show
        def View()
            This.Show()

        # Prints the converted image or opens its file, exactly as the main call does.
        #
        #   returns    nothing
        #   warning    can open a window on the screen, see Show
        #   see        Show
        def Display()
            This.Show()

    # Runs the tool, then prints the converted image or opens its file, and returns nothing.
    #
    #   returns    nothing
    #   note       RunAndView, XT and GoXT are the same call
    #   warning    needs the real im2ansi tool and can open a window, see Execute and Show
    #   see        Execute, Show
    def ExecuteAndShow()
        This.Execute()
        This.Show()

        # Runs the tool, then prints the converted image or opens its file.
        #
        #   returns    nothing
        #   warning    needs the real im2ansi tool and can open a window, see Execute and Show
        #   see        ExecuteAndShow
        def RunAndView()
            This.ExecuteAndShow()

        # Runs the tool, then prints the converted image or opens its file.
        #
        #   returns    nothing
        #   warning    needs the real im2ansi tool and can open a window, see Execute and Show
        #   see        ExecuteAndShow
        def XT()
            This.ExecuteAndShow()

        # Runs the tool, then prints the converted image or opens its file.
        #
        #   returns    nothing
        #   warning    needs the real im2ansi tool and can open a window, see Execute and Show
        #   see        ExecuteAndShow
        def GoXT()
            This.ExecuteAndShow()

    # Returns the path of the file the last run kept.
    #
    #   returns    a text; empty when the last run kept no file (a run that printed the text, or none)
    #   see        SetOutputFile, Execute, Content
    def OutputFile()
        return @cFile

    private

    # Opens a file in the program the system associates with it, and does nothing when the environment variable STZ_NO_VIEW is set.
    #
    #   pcFile     the path of the file to open
    #   returns    nothing
    #   warning    opens a window on the screen
    #   see        Show
    def OpenViewer(pcFile)
        if sysget("STZ_NO_VIEW") = ""
            StzOpenInDefaultApp(pcFile)
        ok

    # Builds the list of command-line options for the im2ansi tool from the settings, one text per argument.
    #
    #   returns    a list of texts: the image path, then the options in the order -f -s -w -i
    #              --no-color --seed -c -r, each only when its setting asks for it
    #   note       no quoting is added, since the list reaches the tool one argument at a time
    #   see        Execute
    def BuildArgs()
        _a_ = [ "-p", @cImage ]

        if @cFormat != "ansi"
            _a_ + "-f"
            _a_ + @cFormat
        ok
        _a_ + "-s"
        _a_ + ("" + @nHeight)
        if isNumber(@nWidth)
            _a_ + "-w"
            _a_ + ("" + @nWidth)
        ok
        if @bInvert
            _a_ + "-i"
        ok
        if @bNoColor
            _a_ + "--no-color"
        ok
        if isNumber(@nSeed)
            _a_ + "--seed"
            _a_ + ("" + @nSeed)
        ok
        if @cChars != ""
            _a_ + "-c"
            _a_ + @cChars
        ok
        if @cFormat = "ascii"
            _a_ + "-r"
            _a_ + ("" + @nRamp)
        ok

        return _a_
