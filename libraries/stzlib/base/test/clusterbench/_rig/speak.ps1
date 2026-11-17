# The hearing cluster's recordings, spoken by the Windows voices: each "heard" row of tasks.tsv, its question column read
# aloud into recordings/<picture column> as 16 kHz, mono, 16-bit PCM -- the form Whisper reads. French rows (fr*.wav) take
# the French voice, the others the English one.
#
#     powershell -ExecutionPolicy Bypass -File _rig\speak.ps1        (from the clusterbench folder)
Add-Type -AssemblyName System.Speech
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(16000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$voices = (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | ForEach-Object { $_.VoiceInfo }
$fr = ($voices | Where-Object { $_.Culture.Name -eq "fr-FR" } | Select-Object -First 1).Name
$en = ($voices | Where-Object { $_.Culture.Name -like "en-*" } | Select-Object -First 1).Name
$dir = Join-Path (Get-Location) "recordings"
New-Item -ItemType Directory -Force $dir | Out-Null
foreach ($line in (Get-Content -Encoding UTF8 "tasks.tsv" | Select-Object -Skip 1)) {
    $c = $line -split "`t"
    if ($c[2] -ne "heard") { continue }
    $s = New-Object System.Speech.Synthesis.SpeechSynthesizer
    if ($c[3] -like "fr*") { $s.SelectVoice($fr) } else { $s.SelectVoice($en) }
    $s.SetOutputToWaveFile((Join-Path $dir $c[3]), $fmt)
    $s.Speak($c[4])
    $s.Dispose()
    "$($c[3])  $($s.Voice.Name)  $($c[4])"
}
