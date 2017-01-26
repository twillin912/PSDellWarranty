function Get-DellWarrantyInfo {
    <#
    .SYNOPSIS
        Get warranty information for Dell servers.
    .DESCRIPTION
        A detailed description of the Get-DellWarrantyInfo function.
    .PARAMETER Computer
        Name should be a valid computer name or IP address.  Defaults to localhost.
    .PARAMETER ServiceTag
        ServiceTag should be a valid Dell Service tag. Enter one or more values.
    .PARAMETER Latest
        Switch to display only the most currently warranty.
    .EXAMPLE
        PS C:\> Get-DellWarrantyInfo -ServiceTag XXXXXXX
        Get warranty information by service tag
    .EXAMPLE
        PS C:\> Get-DellWarrantyInfo -Computer MyComputer -Latest
        Get warranty information by computer name or IP address and only display the last to expire
    .EXAMPLE
        PS C:\> Get-DellWarrantyInfo -Computer MyComputer | Export-Csv -Path C:\Assets.csv
        Get warranty information by computer name and export to CSV file for review
    .LINK
        https://github.com/twillin912/DellWarranty
    .NOTES
        Author: Trent Willingham
        Check out my other scripts and projects @ https://github.com/twillin912
    #>
    #Requires -Version 4.0
    [CmdletBinding(DefaultParameterSetName="ByComputerName")]
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(ParameterSetName = 'ByComputerName',
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = 'localhost',
        
        [Parameter(ParameterSetName = 'ByServiceTag',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$ServiceTag,

        [Parameter(Mandatory = $false)]
        [Switch]$Latest
        
    )
    
    Process
    {
        
        $apiKey = '849e027f476027a394edd656eaef4842'
        if ( $ComputerName ) {
            foreach ($Computer in $ComputerName)
            {
                $computerIsUp = Test-Connection $Computer -Count 1 -Quiet
                if (!$computerIsUp)
                {
                    Write-Warning "$Computer is offline."
                    $Computer = $Null
                }
                else
                {
                    # Get Service Tag and Model of target computer.
                    $bios = Get-CimInstance -ClassName Win32_SystemEnclosure -ComputerName $Computer
                    $system = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Computer
                    $Tag = $bios.SerialNumber
                    #$compName = $bios.__SERVER
                    #$model = $system.Model
                    $manuf = $system.Manufacturer
                    
                    if (!($manuf -match 'Dell'))
                    {
                        Write-Warning "Computer not manufactured by Dell. Can't get warranty information."
                    }
                    else
                    {
                        # Get warranty information from Dell's website.
                        $url = "https://api.dell.com/support/v2/assetinfo/warranty/tags?svctags=${Tag}&apikey=${apiKey}"
                        $req = Invoke-RestMethod -URI $url -Method GET
                        $warranties = $req.getassetwarrantyresponse.getassetwarrantyresult.response.dellasset.warranties.warranty | Where-Object {
                            $_.ServiceLevelCode -ne 'D'
                        }
                        $dellasset = $req.getassetwarrantyresponse.getassetwarrantyresult.response.dellasset
                        
                        # If the $Latest paramater is given, filter out all but the most recent warranty.
                        if ($Latest)
                        {
                            $latestWarranty = $warranties[0]
                            foreach ($warranty in $warranties)
                            {
                                if ((Get-Date $warranty.enddate) -gt (Get-Date $latestWarranty.enddate))
                                {
                                    $latestWarranty = $warranty
                                }
                            }
                            $warranties = $latestWarranty
                        }
                        
                        # Construct and write output object.
                        foreach ($warranty in $warranties)
                        {
                            $output = New-Object -Type PSCustomObject
                            # Copy properties from the XML data gotten from Dell.
                            Add-Member -MemberType NoteProperty -Name 'Name' -Value $Comp -InputObject $output
                            Add-Member -MemberType NoteProperty -Name 'ServiceTag' -Value $dellasset.ServiceTag -InputObject $output
                            Add-Member -MemberType NoteProperty -Name 'MachineDescription' -Value $dellasset.MachineDescription -InputObject $output
                            Add-Member -MemberType NoteProperty -Name 'ShipDate' -Value $dellasset.ShipDate -InputObject $output
                            foreach ($property in ($warranty | Get-Member -Type Property))
                            {
                                Add-Member -MemberType NoteProperty -Name $property.name `
                                           -Value $warranty.$($property.name) `
                                           -InputObject $output
                            }
                            $output.ShipDate = [datetime]::ParseExact($output.ShipDate, "yyyy-MM-ddTHH:mm:ss", $null)
                            $output.StartDate = [datetime]::ParseExact($output.StartDate, "yyyy-MM-ddTHH:mm:ss", $null)
                            $output.EndDate = [datetime]::ParseExact($output.EndDate, "yyyy-MM-ddTHH:mm:ss", $null)
                            Write-Output -InputObject $output
                        }
                    }
                }
            }
        }
        
        if ( $ServiceTag )
        {
            foreach ($tag in $ServiceTag)
            {
                # Get warranty information from Dell's website.
                $url = "https://api.dell.com/support/v2/assetinfo/warranty/tags.xml?svctags=${tag}&apikey=${apiKey}"
                $req = Invoke-RestMethod -URI $url -Method GET
                $warranties = $req.getassetwarrantyresponse.getassetwarrantyresult.response.dellasset.warranties.warranty | Where-Object {
                    $_.ServiceLevelCode -ne 'D'
                }
                $dellasset = $req.getassetwarrantyresponse.getassetwarrantyresult.response.dellasset
                
                # If the $Latest paramater is given, filter out all but the most recent warranty.
                if ($Latest)
                {
                    $latestWarranty = $warranties[0]
                    foreach ($warranty in $warranties)
                    {
                        if ((Get-Date $warranty.enddate) -gt (Get-Date $latestWarranty.enddate))
                        {
                            $latestWarranty = $warranty
                        }
                    }
                    $warranties = $latestWarranty
                }
                
                # Construct and write output object.
                foreach ($warranty in $warranties)
                {
                    $output = New-Object -Type PSCustomObject
                    # Copy properties from the XML data gotten from Dell.
                    Add-Member -MemberType NoteProperty -Name 'ServiceTag' -Value $dellasset.ServiceTag -InputObject $output
                    Add-Member -MemberType NoteProperty -Name 'MachineDescription' -Value $dellasset.MachineDescription -InputObject $output
                    Add-Member -MemberType NoteProperty -Name 'ShipDate' -Value $dellasset.ShipDate -InputObject $output
                    foreach ($property in ($warranty | Get-Member -Type Property))
                    {
                        Add-Member -MemberType NoteProperty -Name $property.name `
                                   -Value $warranty.$($property.name) `
                                   -InputObject $output
                    }
                    $output.ShipDate = [datetime]::ParseExact($output.ShipDate, "yyyy-MM-ddTHH:mm:ss", $null)
                    $output.StartDate = [datetime]::ParseExact($output.StartDate, "yyyy-MM-ddTHH:mm:ss", $null)
                    $output.EndDate = [datetime]::ParseExact($output.EndDate, "yyyy-MM-ddTHH:mm:ss", $null)
                    Write-Output -InputObject $output
                }
            }
        }
    }
}
