function ConvertTo-Date {
    Param (
        [string] $RawDate
    )

    if ( [string]::IsNullOrEmpty($RawDate) ) {
        Return $RawDate
    } else {
        Return [datetime]$RawDate
    }
}
