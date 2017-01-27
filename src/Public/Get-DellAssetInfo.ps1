function Get-DellAssetInfo {
    <#
    .SYNOPSIS
        Get asset information for Dell servers.
    .DESCRIPTION
        A detailed description of the Get-DellAssetInfo function.
    .PARAMETER Computer
        Name should be a valid computer name or IP address.  Defaults to localhost.
    .PARAMETER ServiceTag
        ServiceTag should be a valid Dell Service tag. Enter one or more values.
    .EXAMPLE
        PS C:\> Get-DellAssetInfo -ServiceTag XXXXXXX
        Get asset information by service tag
    .EXAMPLE
        PS C:\> Get-DellAssetInfo -Computer MyComputer
        Get asset information by computer name or IP address
    .EXAMPLE
        PS C:\> Get-DellAssetInfo -Computer MyComputer | Export-Csv -Path C:\Assets.csv
        Get asset information by computer name and export to CSV file for review
    .LINK
        https://github.com/twillin912/DellWarranty
    .NOTES
        Author: Trent Willingham
        Check out my other scripts and projects @ https://github.com/twillin912
    #>
    #Requires -Version 4.0
    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    Param (
        # Name should be a valid computer name or IP address.
        [Parameter(Mandatory = $False,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   ValueFromRemainingArguments = $false)]
        [Alias('Name', 'HostName', 'Identity', 'DNSHostName')]
        [string[]]$ComputerName = 'localhost',
        
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
        if ( $ComputerName ) {
            foreach ($Computer in $ComputerName) {
                $computerIsUp = Test-Connection $Computer -Count 1 -Quiet
                if (!$computerIsUp) {
                    Write-Warning "$Computer is offline."
                    $Computer = $Null
                }
                else {
                    # Get Service Tag and Model of target computer.
                    $bios = Get-CimInstance -ClassName Win32_SystemEnclosure -ComputerName $Computer
                    $system = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Computer
                    $Tag = $bios.SerialNumber
                    #$compName = $bios.__SERVER
                    #$model = $system.Model
                    $manuf = $system.Manufacturer
                    
                    if (!($manuf -match 'Dell')) {
                        Write-Warning "Computer not manufactured by Dell. Can't get warranty information."
                    }
                    else {
                        # Get warranty information from Dell's website.
                        $url = "https://api.dell.com/support/v2/assetinfo/detail/tags?svctags=${Tag}&apikey=${apiKey}"
                        $req = Invoke-RestMethod -URI $url -Method GET
                        $dellasset = $req.GetAssetDetailResponse.GetAssetDetailResult.Response.DellAsset.AssetParts.AssetPart
                        
                        # Construct and write output object.
                        foreach ($assetpart in $dellasset) {
                            $output = New-Object -Type PSCustomObject
                            # Copy properties from the XML data gotten from Dell.
                            foreach ($property in ($assetpart | Get-Member -Type Property)) {
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
        
        if ( $ServiceTag ) {
            foreach ($tag in $ServiceTag) {
                # Get warranty information from Dell's website.
                $url = "https://api.dell.com/support/v2/assetinfo/detail/tags.xml?svctags=${tag}&apikey=${apiKey}"
                $req = Invoke-RestMethod -URI $url -Method GET
                $dellasset = $req.GetAssetDetailResponse.GetAssetDetailResult.Response.DellAsset.AssetParts.AssetPart
                
                # Construct and write output object.
                foreach ($assetpart in $dellasset) {
                    $output = New-Object -Type PSCustomObject
                    # Copy properties from the XML data gotten from Dell.
                    foreach ($property in ($assetpart | Get-Member -Type Property)) {
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
