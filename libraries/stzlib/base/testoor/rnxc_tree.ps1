# Makes a tree in which the library FINDS A RING++ ENGINE, so Testoor's guards (and
# any tour) run under rnxc against libraries built for it.
#
# WHY A TREE. The library discovers its engine by searching UPWARD from the working
# directory for engine/zig-out/bin (core/common/stkRingLibs.ring), so the libraries
# a run uses are the ones in the nearest engine directory above where it starts. A
# worktree's own engine is built for Ring, and rnxc refuses those (R46, no rpp_init).
# This tree has the library's base and core as JUNCTIONS to a worktree, so edits in
# the worktree are seen at once, and an `engine` junction to a Ring++ build.
#
#   powershell -File rnxc_tree.ps1 -Worktree <worktree> -Engine <ring++ engine copy> -Tree <new folder>
#
# The Ring++ engine copy is made with the Ring++ repository's bench/engine_copy.py and
# built with `ONLY=<domains> zig build -j2` (see SOFTANZA_TESTOOR_ROADMAP.md, P2a).
#
# RUN FROM POWERSHELL OR cmd, NOT FROM Git Bash. Git Bash follows a junction when it
# changes directory, so the process would report the real worktree path and find the
# Ring-built engine again. PowerShell keeps the path as typed:
#
#   Set-Location <Tree>\libraries\stzlib\base\test\testoor
#   rnxc testoor_reader_narrated.ring
#
# Idempotent: a junction that exists is left alone.
param(
    [Parameter(Mandatory = $true)][string]$Worktree,
    [Parameter(Mandatory = $true)][string]$Engine,
    [Parameter(Mandatory = $true)][string]$Tree
)
$ErrorActionPreference = 'Stop'
$lib = Join-Path $Tree 'libraries\stzlib'
New-Item -ItemType Directory -Force $lib | Out-Null
$links = @(
    @('base',   (Join-Path $Worktree 'libraries\stzlib\base')),
    @('core',   (Join-Path $Worktree 'libraries\stzlib\core')),
    @('engine', $Engine)
)
foreach ($l in $links) {
    if (-not (Test-Path $l[1])) { throw "missing target: $($l[1])" }
    $p = Join-Path $lib $l[0]
    if (-not (Test-Path $p)) { New-Item -ItemType Junction -Path $p -Target $l[1] | Out-Null }
}
Get-ChildItem $lib | Select-Object Name, LinkType, Target | Format-Table -AutoSize | Out-String -Width 200
"ready: Set-Location '$lib\base\test\testoor' ; rnxc testoor_reader_narrated.ring"
