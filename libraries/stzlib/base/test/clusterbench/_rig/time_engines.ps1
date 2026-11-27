# Whisper's time on two engines, alternated: the engine of 2026-11-16 (stzlib 1212cb88c, WHISPER-02) and the shared engine
# (C:/haro-engine, stzlib c2b930b71). Each recording runs once per engine, in a separate process, and the engines' order
# turns with each recording (A B, B A, A B, B A), so the machine's drift falls on both. One process at a time.
#
#     powershell -ExecutionPolicy Bypass -File _rig\time_engines.ps1 -Old <folder> -New <folder>   (from the clusterbench folder)

param([string]$Old, [string]$New)
$haro = 'D:\GitHub\haro\vm\zig-out\bin\haro.exe'
$recs = @(@('fr01','fr'), @('fr02','fr'), @('fr03','fr'), @('en01','en'))
"recording`tengine`tplain ms`tsetting list ms`tplain heard`tlisted heard`twall s"
for ($r = 0; $r -lt $recs.Count; $r++) {
    $order = if ($r % 2 -eq 0) { @($Old, $New) } else { @($New, $Old) }
    foreach ($eng in $order) {
        $env:STZ_ENGINE_DIR = $eng
        $env:RIG_REC = $recs[$r][0]
        $env:RIG_LANG = $recs[$r][1]
        $t0 = Get-Date
        $line = & $haro '_rig/time_engine.haro' | Select-Object -Last 1
        $wall = [Math]::Round(((Get-Date) - $t0).TotalSeconds, 1)
        "$line`t$wall"
    }
}
