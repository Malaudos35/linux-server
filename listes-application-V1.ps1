# Récupérer la liste des applications qui ne sont pas des applications natives de Windows
Get-WmiObject -Class Win32_Product | Where-Object { $_.Vendor -notlike "Microsoft Corporation" } | Select-Object -Property Name | Out-File -FilePath "$env:USERPROFILE\Downloads\listes-app.txt"


# Get-ExecutionPolicy # avoir la politique d execution
# Set-ExecutionPolicy Unrestricted # authorise l execution les scripts
# Set-ExecutionPolicy Restricted   # refuse l execution des scripts
