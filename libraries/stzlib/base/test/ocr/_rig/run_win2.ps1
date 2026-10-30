# run_win2.ps1 -- the platform OCR floor on every rendered golden page in ocr_golden (<doc>_p<n>_200dpi.png)
$S = 'C:\Users\ASUSV3~1\AppData\Local\Temp\claude\D--GitHub-stzlib\218fa361-a925-4e31-90cd-d494bf0cc7c2\scratchpad'
New-Item -ItemType Directory -Force "$S\ocr\out" | Out-Null
$P = "$S\ocr\winocr.ps1"
$langOf = @{ 'z09' = 'fr-FR'; 'z01' = 'fr-FR'; 'u06' = 'fr-FR'; 'y11' = 'ar-SA' }
Get-ChildItem "$S\ocr_golden\*_p*_200dpi.png" | Sort-Object Name | ForEach-Object {
  $doc = $_.Name.Substring(0, 3)
  $page = $_.Name.Split('_')[1]
  $lang = $langOf[$doc]
  if ($null -eq $lang) { $lang = 'fr-FR' }
  "== $doc $page " + (& $P -Path $_.FullName -Lang $lang -Out "$S\ocr\out\${doc}_${page}_win.txt")
}
