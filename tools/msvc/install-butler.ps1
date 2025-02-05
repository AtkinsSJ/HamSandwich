# Setup
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.IO.Compression.FileSystem

$sha256 = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider

function CheckHash {
	param([string] $File, [string] $Sha)
	$got = $sha256.ComputeHash([System.IO.File]::ReadAllBytes("$PWD/$FILE"))
	$got = [System.BitConverter]::ToString($got).Replace('-', '').ToLower()
	if ($got -ne $Sha) {
		Write-Output "${File}: FAILED"
		exit 1
	} else {
		Write-Output "${File}: OK"
	}
}

# Fetch Butler binary
if (-not (Test-Path "build/butler.exe")) {
	New-Item build -ItemType Directory -ErrorAction SilentlyContinue > $null

	Write-Output "==== Downloading butler binary ===="
	Invoke-WebRequest `
		-Uri "https://broth.itch.ovh/butler/windows-amd64/15.21.0/archive/default" `
		-OutFile "build/butler.zip" `
		-ErrorAction Stop
	CheckHash -File "build/butler.zip" -Sha "e5381a1ec38abe8c2f3bf742dc22e897901e7def22d20ebc8fd4490d52038d35"

	[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/build/butler.zip", "$PWD/build")
	rm build/butler.zip -ErrorAction Stop
}

$ButlerVersion = build/butler.exe --version 2>&1
Write-Output "butler: $ButlerVersion"
