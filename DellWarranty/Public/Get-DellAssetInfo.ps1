function Get-DellAssetInfo {
	<#
	#>
	#Requires -Version 2
	[CmdletBinding()]

	Param (
		# Name should be a valid computer name or IP address.
		[Parameter(Mandatory = $False,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false)]
		[Alias('Name', 'HostName', 'Identity', 'DNSHostName', 'ComputerName')]
		[string[]]$Computer = 'localhost',
		
		# ServiceTag should be a valid Dell Service tag. Enter one or more values.
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true)]
		[Alias('Serial', 'SerialNumber')]
		[string[]]$ServiceTag,
		[Parameter(Mandatory = $false)]
		[Switch]$Latest
		
	)
	
	Process
	{
		
		$apiKey = '849e027f476027a394edd656eaef4842'
		if ($ServiceTag -eq $Null)
		{
			foreach ($Comp in $Computer)
			{
				$computerIsUp = Test-Connection $Comp -Count 1 -Quiet
				if (!$computerIsUp)
				{
					Write-Warning "$Comp is offline."
					$Comp = $Null
				}
				else
				{
					# Get Service Tag and Model of target computer.
					$bios = Get-WmiObject Win32_SystemEnclosure -ComputerName $Comp
					$system = Get-WmiObject Win32_ComputerSystem -ComputerName $Comp
					$Tag = $bios.SerialNumber
					$compName = $bios.__SERVER
					$model = $system.Model
					$manuf = $system.Manufacturer
					
					if (!($manuf -match 'Dell'))
					{
						Write-Warning "Computer not manufactured by Dell. Can't get warranty information."
					}
					else
					{
						# Get warranty information from Dell's website.
						$url = "https://api.dell.com/support/v2/assetinfo/detail/tags?svctags=${Tag}&apikey=${apiKey}"
						$req = Invoke-RestMethod -URI $url -Method GET
						$dellasset = $req.GetAssetDetailResponse.GetAssetDetailResult.Response.DellAsset.AssetParts.AssetPart
						
						# Construct and write output object.
						foreach ($assetpart in $dellasset)
						{
							$output = New-Object -Type PSCustomObject
							# Copy properties from the XML data gotten from Dell.
							foreach ($property in ($assetpart | Get-Member -Type Property))
							{
								Add-Member -MemberType NoteProperty -Name $property.name `
										   -Value $assetpart.$($property.name) `
										   -InputObject $output
							}
							Write-Output -InputObject $output
						}
					}
				}
			}
		}
		elseif ($ServiceTag -ne $Null)
		{
			foreach ($tag in $ServiceTag)
			{
				# Get warranty information from Dell's website.
				$url = "https://api.dell.com/support/v2/assetinfo/detail/tags.xml?svctags=${tag}&apikey=${apiKey}"
				$req = Invoke-RestMethod -URI $url -Method GET
				$dellasset = $req.GetAssetDetailResponse.GetAssetDetailResult.Response.DellAsset.AssetParts.AssetPart
				
				# Construct and write output object.
				foreach ($assetpart in $dellasset)
				{
					$output = New-Object -Type PSCustomObject
					# Copy properties from the XML data gotten from Dell.
					foreach ($property in ($assetpart | Get-Member -Type Property))
					{
						Add-Member -MemberType NoteProperty -Name $property.name `
								   -Value $assetpart.$($property.name) `
								   -InputObject $output
					}
					Write-Output -InputObject $output
				}
			}
		}
	}
}
