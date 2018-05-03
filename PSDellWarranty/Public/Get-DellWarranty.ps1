function Get-DellWarranty {
    <#
    .SYNOPSIS
        Get warranty information for Dell computers.
    .DESCRIPTION
        The Get-DellWarranty cmdlet submits requests to the Dell API site to retrieve system warranty information for a list of computers or service tags.
    .PARAMETER Computer
        Specifies the name of one or more computers. Get-DellWarranty queries the CIM instance on these computers to get the service tag value.
    .PARAMETER ServiceTag
        Specifies one or more Dell service tags.
    .PARAMETER Active
        Switch to display only warranties that have not expired.
    .PARAMETER ApiKey
        Specifies the API key to authenticate with the Dell API service. This defaults to the Cambium Learning API key.
    .PARAMETER UseSandbox
        Switch to use the Dell sandbox URI for testing.
    .EXAMPLE
        PS C:\> Get-DellWarranty -ServiceTag XXXXXXX,YYYYYYY
        Get all warranty information for the service tags specified.
    .EXAMPLE
        PS C:\> Get-DellWarranty -Computer MyComputer -Active
        Get only active warranty information by computer name or IP address.
    .EXAMPLE
        PS C:\> Get-DellWarranty -Computer MyComputer | Export-Csv -Path C:\Assets.csv
        Get all warranty information by computer name and export to CSV file for review
    .LINK
        https://github.com/twillin912/PSDellWarranty
    .NOTES
        Author: Trent Willingham
        Check out my other scripts and projects @ https://github.com/twillin912
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias('Name','IPAddress')]
        [string[]] $ComputerName,

        [Parameter(
            ValueFromPipelineByPropertyName=$true
        )]
        [ValidateLength(7,7)]
        [ValidatePattern('[a-zA-Z0-9]')]
        [Alias('SerialNumber')]
        [string[]] $ServiceTag,

        [PSCredential] $Credential,

        [Parameter(Mandatory = $false)]
        [Switch] $Active,

        [Parameter(Mandatory = $true)]
        [string] $ApiKey,

        [Parameter(Mandatory = $false)]
        [Switch] $UseSandbox
    )

    begin {
        $RequestHeader = @{
            'content-type' = 'application/x-www-form-urlencoded'
            'apikey' = "$ApiKey"
        }

        if ($UseSandbox) {
            $ApiUri = 'https://sandbox.api.dell.com/support/assetinfo/v4/getassetwarranty'
        }
        else {
            $ApiUri = 'https://api.dell.com/support/assetinfo/v4/getassetwarranty'
        }

        $HostList = @{}
        $InvalidTags = @()
        $OutputObject = @()
        $ServiceTagList = @()
    }

    process {
        foreach ( $Computer in $ComputerName ) {
            Write-Verbose -Message "Testing connection to '$Computer'."
            if ( -not ( Test-Connection $Computer -Count 1 -Quiet ) ) {
                Write-Warning "$Computer is offline."
                Continue
            }

            Write-Verbose -Message "Query CIM instance for manufacturer and service tag."
            try {
                if ( $Credential ) {
                    $CimSession = New-CimSession -ComputerName $Computer -Credential $Credential
                } else {
                    $CimSession = New-CimSession -ComputerName $Computer
                }
                $CimBios = Get-CimInstance -CimSession $CimSession -ClassName Win32_BIOS
                $CimSystem = Get-CimInstance -CimSession $CimSession -ClassName Win32_ComputerSystem
            }
            catch {
                Write-Warning -Message "CIM connection to '$Computer' failed."
                continue
            }
            if ( -not ( $CimSystem.Manufacturer -match 'Dell' ) ) {
                Write-Warning "System manufacturer '$($CimSystem.Manufacturer)' on computer '$($Computer)' is not supported by this cmdlet."
                Continue
            }
            $HostList.Add($CimBios.SerialNumber, $Computer)
            $ServiceTagList += $CimBios.SerialNumber
        }

        foreach ( $Tag in $ServiceTag ) {
            $ServiceTagList += $Tag
        }
    }

    end {
        if ( -not $ServiceTagList ) {
            Write-Warning -Message "No valid service tags specified. Aborting"
            break
        }
        foreach ( $Array in (Split-Array -InputObject $ServiceTagList -SplitSize 2) ) {

            $RequestBody = @{ 'ID' = $($Array -join ',') }

            Write-Verbose -Message "Submitting query for the service tags $($RequestBody.Item('ID'))."
            $Response = Invoke-RestMethod -Uri $ApiUri -Method Get -Headers $RequestHeader -Body $RequestBody

            $InvalidTags += $Response.InvalidFormatAssets.BadAssets
            $InvalidTags += $Response.InvalidBILAssets.BadAssets

            foreach ( $AssetRecord in $Response.AssetWarrantyResponse ) {
                $HeaderData = $AssetRecord.AssetHeaderData
                $EntitlementData = $AssetRecord.AssetEntitlementData
                foreach ( $EntitlementRecord in $EntitlementData ) {
                    if ( $EntitlementRecord.ServiceLevelCode -notin ('D','KK') ) {
                        $NewRecord = New-Object -TypeName PSObject -Property @{
                            # Data from AssetHeaderData
                            HostName            = $HostList.Item($HeaderData.ServiceTag)
                            ServiceTag          = $HeaderData.ServiceTag
                            BUID                = $HeaderData.BUID
                            CountryLookupCode   = $HeaderData.CountryLookupCode
                            CustomerNumber      = $HeaderData.CustomerNumber
                            IsDuplicate         = $HeaderData.IsDuplicate
                            ItemClassCode       = $HeaderData.ItemClassCode
                            LocalChannel        = $HeaderData.LocalChannel
                            MachineDescription  = $HeaderData.MachineDescription
                            OrderNumber         = $HeaderData.OrderNumber
                            ParentServiceTag    = $HeaderData.ParentServiceTag
                            ShipDate            = ConvertTo-Date $HeaderData.ShipDate

                            # Data from AssetEntitlementData
                            EntitlementType         = $EntitlementRecord.EntitlementType
                            ItemNumber              = $EntitlementRecord.ItemNumber
                            ServiceLevelCode        = $EntitlementRecord.ServiceLevelCode
                            ServiceLevelDescription = $EntitlementRecord.ServiceLevelDescription
                            ServiceLevelGroup       = $EntitlementRecord.ServiceLevelGroup
                            ServiceProvider         = $EntitlementRecord.ServiceProvider
                            StartDate               = ConvertTo-Date $EntitlementRecord.StartDate
                            EndDate                 = ConvertTo-Date $EntitlementRecord.EndDate
                        }

                        if ( $NewRecord ) {
                            $NewRecord.PSObject.TypeNames.Insert(0,'PSDellWarranty.WarrantyRecord')
                            $OutputObject += $NewRecord
                        }
                        Remove-Variable -Name NewRecord
                    }
                }
            }
        }

        if ( $InvalidTags ) {
            Write-Warning -Message "No results for ServiceTag(s) '$($InvalidTags -join ',')'"
        }

        Write-Output -InputObject $OutputObject
   }
}
