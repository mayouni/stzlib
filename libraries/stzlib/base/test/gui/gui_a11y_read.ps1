# THE CLIENT HALF of G4b's proof.
#
# Reads the accessibility tree back out of a running Softanza window using
# WINDOWS' OWN UI Automation -- the same API a screen reader uses, sharing
# not one line of code with the library that published the tree.
#
#     powershell -File gui_a11y_read.ps1
#
# Run it while gui_a11y_host.ring is up. It finds the window by title,
# walks the tree, and prints what a reader would be told.
#
# WHY A CLIENT AT ALL: in-process, "we pushed a tree" looks identical on a
# machine with a screen reader and a machine without one. This is the
# second, independent route to the same truth -- and the host's own
# `read` counter must move when this runs, which is the pair agreeing.

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

$title = "STZ-A11Y-PROBE-WINDOW"

$root = [System.Windows.Automation.AutomationElement]::RootElement
$cond = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::NameProperty, $title)

$win = $root.FindFirst([System.Windows.Automation.TreeScope]::Children, $cond)
if ($null -eq $win) {
    Write-Output "NOT-FOUND no window titled $title"
    exit 2
}

Write-Output ("WINDOW name=[" + $win.Current.Name + "] type=" + $win.Current.ControlType.ProgrammaticName)

# EVERY descendant, which is what a reader enumerates.
$all = $win.FindAll([System.Windows.Automation.TreeScope]::Descendants,
    [System.Windows.Automation.Condition]::TrueCondition)

Write-Output ("COUNT " + $all.Count)

foreach ($e in $all) {
    $c = $e.Current
    $r = $c.BoundingRectangle
    $bounds = "none"
    if (-not [double]::IsInfinity($r.X)) {
        $bounds = ("{0},{1} {2}x{3}" -f [int]$r.X, [int]$r.Y, [int]$r.Width, [int]$r.Height)
    }
    $kb = "no"
    if ($c.IsKeyboardFocusable) { $kb = "yes" }
    # THE DESCRIPTION IS *FullDescription*, not HelpText. AccessKit maps
    # a node's description to UIA_FullDescriptionPropertyId (30159), and
    # the legacy .NET wrapper has no named accessor for it -- reading
    # HelpText instead reports every description as empty and looks like
    # a library defect when it is a client one.
    # Distinguish EMPTY from UNSUPPORTED -- reporting both as "" is how a
    # client limitation gets mistaken for a library defect.
    $desc = ""
    try {
        $v = $e.GetCurrentPropertyValue(30159)
        if ($v -eq [System.Windows.Automation.AutomationElement]::NotSupported) {
            $desc = "<unsupported>"
        } elseif ($null -ne $v) { $desc = [string]$v }
    } catch {
        # MEASURED, and it is a CLIENT limit rather than a bridge defect:
        # this legacy .NET wrapper predates UIA's FullDescription and will
        # not take a raw property id. AccessKit maps a node's description
        # there, so the RATIONALE every declaration carries is published
        # and simply not readable from here. Verifying it needs a UIA 3
        # client (or a screen reader), which is recorded as owed rather
        # than reported as working.
        $desc = "<client cannot read FullDescription>"
    }
    if ($desc -eq "" -and $c.HelpText -ne "") { $desc = "help:" + $c.HelpText }
    Write-Output ("NODE type=" + $c.ControlType.ProgrammaticName +
                  " name=[" + $c.Name + "]" +
                  " desc=[" + $desc + "]" +
                  " focusable=" + $kb +
                  " bounds=" + $bounds)
}
