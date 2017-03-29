function Split-Array {
    [CmdletBinding()]
    [OutputType([System.Array])]
    Param (
        [object[]] $InputObject,
        [int] $SplitSize
    )

    $Length = $InputObject.Length
    for ( $Index = 0; $Index -lt $Length; $Index += $SplitSize ) {
        ,( $InputObject[$Index..($Index+$SplitSize-1)])
    }
}
