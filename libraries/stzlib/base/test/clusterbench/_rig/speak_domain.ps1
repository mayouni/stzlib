# DOMAINHEARING-01's term-dense recordings, spoken by the Windows French voice: each row of domain_sales.tsv, its
# sentence read aloud into recordings/<recording column> as 16 kHz, mono, 16-bit PCM -- the form Whisper reads.
#
#     powershell -ExecutionPolicy Bypass -File _rig\speak_domain.ps1        (from the clusterbench folder)
Add-Type -AssemblyName System.Speech
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(16000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$voices = (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { $_.VoiceInfo }
$fr = ($voices | Where-Object { $_.Culture.Name -eq "fr-FR" } | Select-Object -First 1).Name
$dir = Join-Path (Get-Location) "recordings\domain"
New-Item -ItemType Directory -Force $dir | Out-Null
foreach ($line in (Get-Content -Encoding UTF8 "domain_sales.tsv")) {
    if ($line.StartsWith("#") -or $line.StartsWith("id`t")) { continue }
    $c = $line -split "`t"
    $s = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $s.SelectVoice($fr)
    $s.SetOutputToWaveFile((Join-Path (Get-Location) ("recordings\" + $c[1].Replace("/", "\"))), $fmt)
    $s.Speak($c[2])
    $s.Dispose()
    "$($c[1])  $fr  $($c[2])"
}
