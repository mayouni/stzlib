# winocr.ps1 -Path <png> -Lang <fr-FR|ar-SA> -Out <txt>  -- the platform OCR floor (Windows.Media.Ocr), timed
param([string]$Path, [string]$Lang = 'fr-FR', [string]$Out = '')
$null = [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType=WindowsRuntime]
$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType=WindowsRuntime]
$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime]
$null = [Windows.Globalization.Language, Windows.Globalization, ContentType=WindowsRuntime]
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($op, $type) { $t = $asTaskGeneric.MakeGenericMethod($type).Invoke($null, @($op)); $t.Wait(-1) | Out-Null; $t.Result }
$file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($Path)) ([Windows.Storage.StorageFile])
$stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
$decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
$bitmap = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
$language = New-Object Windows.Globalization.Language -ArgumentList $Lang
$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage($language)
if ($null -eq $engine) { "NO ENGINE for $Lang"; exit 2 }
$sw = [Diagnostics.Stopwatch]::StartNew()
$result = Await ($engine.RecognizeAsync($bitmap)) ([Windows.Media.Ocr.OcrResult])
$ms = $sw.ElapsedMilliseconds
$lines = @()
$words = 0
foreach ($l in $result.Lines) { $lines += $l.Text; $words += @($l.Words).Count }
$text = ($lines -join "`n")
"lang $Lang  image $($bitmap.PixelWidth)x$($bitmap.PixelHeight)  lines $(@($result.Lines).Count)  words $words  angle $($result.TextAngle)  ms $ms"
if ($Out -ne '') { [IO.File]::WriteAllText($Out, $text, (New-Object Text.UTF8Encoding $false)) }
