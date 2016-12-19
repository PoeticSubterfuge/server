function Get-PoeticSubterfugeServer {

	[cmdletbinding()]

	param (

		[string] $Password = 'nope',

		[string] $OutFolder = $($env:USERPROFILE + '\Downloads\PoeticSubterfuge\server'),

		[string] $ValidatedHash = '69B03F3E4D610F74A9D3D5C2DC6D5A1EFB891A09BDB3C3A84B24FFA62105C344',

		[string] $7zipUrl = 'https://github.com/PoeticSubterfuge/devops-glue/releases/download/latest/7za.exe',

		[string] $7zip = $($env:USERPROFILE + '\Downloads\7za.exe'),

		[string] $RepoUrl = 'https://github.com/PoeticSubterfuge/server/releases/download/latest/',

		[array] $FileNames = @(
								'server.7z.001'
								'server.7z.002'
								'server.7z.003'
		),

		[string] $OvaName = 'server.ova',

		$WebClient = (New-Object System.Net.WebClient)

	)

	begin {

		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

		if (!(Test-Path $OutFolder)) {

			New-Item -Path $OutFolder -ItemType Directory -Force | Out-Null

		}

		if (!(Test-Path $7zip)) {

			$WebClient.DownloadFile($7zipUrl,$7zip)

		}

	} # begin

	process {

		$FileNames |

		ForEach-Object {

			$src = $($RepoUrl + '/' + $_)

			$dst = $($OutFolder + '\' + $_)

			Write-Verbose "downloading $_"

			$WebClient.DownloadFile($src,$dst)

			Write-Verbose "$_ complete"

		}

		Push-Location $OutFolder

		& $7zip x $('-p' + $Password) .\$($FileNames[0]) | Out-Null

		$Hash = (Get-FileHash -Path .\$OvaName -Algorithm SHA256).Hash

		if ($Hash -eq $ValidatedHash) {

			Write-Host "Success!" -ForegroundColor Green

			Write-Host "$OvaName downloaded, decrypted, and validated." -ForegroundColor Green

			Write-Host "Location: $($OutFolder + $OvaName)" -ForegroundColor Green

			foreach ($FileName in $FileNames) {

				Remove-Item .\$FileName | Out-Null

			}

		} elseif ($Hash -ne $ValidatedHash) {

			Write-Host "Not so fast!" -ForegroundColor Red

			Write-Host "$OvaName decryption and validation failed." -ForegroundColor Red

			Write-Verbose "Nuking bogus OVA from high orbit!"

			Remove-Item .\$OvaName | Out-Null

		}

		Pop-Location

	} # process

	end {} # end

} # function Get-PoeticSubterfugeServer