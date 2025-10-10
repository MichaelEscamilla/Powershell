# Languages to Remove - Modified Today
$Languages = @(
    'bg-bg'
    'cs-cz'
    'da-dk'
    'de-de'
    'el-gr'
    'en-gb'
    'es-es'
    'es-mx'
    'et-ee'
    'fi-fi'
    'fr-ca'
    'fr-fr'
    'hr-hr'
    'hu-hu'
    'it-it'
    'ja-jp'
    'ko-kr'
    'lt-lt'
    'lv-lv'
    'nb-no'
    'nl-nl'
    'pl-pl'
    'pt-br'
    'pt-pt'
    'ro-ro'
    'ru-ru'
    'sk-sk'
    'sl-si'
    'sr-latn-rs'
    'sv-se'
    'tr-tr'
    'uk-ua'
    'zh-cn'
    'zh-tw'
)

Start-Transcript
Write-Host -ForegroundColor DarkGray "[$((Get-Date).ToString('HH:mm:ss'))] Removing non en-us language artifacts from BootMedia"
foreach ($Language in $Languages) {
    if (Test-Path "$MediaPath\$Language") {
        Remove-Item -Path "$MediaPath\$Language" -Recurse
    }
    if (Test-Path "$MediaPath\Boot\$Language") {
        Remove-Item -Path "$MediaPath\Boot\$Language" -Recurse
    }
    if (Test-Path "$MediaPath\EFI\Boot\$Language") {
        Remove-Item -Path "$MediaPath\EFI\Boot\$Language" -Recurse
    }
    if (Test-Path "$MediaPath\EFI\Microsoft\Boot\$Language") {
        Remove-Item -Path "$MediaPath\EFI\Microsoft\Boot\$Language" -Recurse
    }
}
Stop-Transcript
