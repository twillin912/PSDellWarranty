---
external help file: PSDellWarranty-help.xml
online version: https://github.com/twillin912/PSDellWarranty
schema: 2.0.0
---

# Get-DellWarranty

## SYNOPSIS
Get warranty information for Dell computers.

## SYNTAX

```
Get-DellWarranty [[-ComputerName] <String[]>] [[-ServiceTag] <String[]>] [[-Credential] <PSCredential>]
 [-Active] [[-ApiKey] <String>] [-UseSandbox] [<CommonParameters>]
```

## DESCRIPTION
The Get-DellWarranty cmdlet submits requests to the Dell API site to retrieve system warranty information for a list of computers or service tags.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-DellWarranty -ServiceTag XXXXXXX,YYYYYYY
```

Get all warranty information for the service tags specified.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-DellWarranty -Computer MyComputer -Active
```

Get only active warranty information by computer name or IP address.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-DellWarranty -Computer MyComputer | Export-Csv -Path C:\Assets.csv
```

Get all warranty information by computer name and export to CSV file for review

## PARAMETERS

### -ComputerName
{{Fill ComputerName Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Name, HostName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServiceTag
Specifies one or more Dell service tags.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: SerialNumber

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
{{Fill Credential Description}}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Active
Switch to display only warranties that have not expired.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiKey
Specifies the API key to authenticate with the Dell API service.
This defaults to the Cambium Learning API key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 5be19193171b46ab8851e183d3e7f47a
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSandbox
Switch to use the Dell sandbox URI for testing.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES
Author: Trent Willingham
Check out my other scripts and projects @ https://github.com/twillin912

## RELATED LINKS

[https://github.com/twillin912/PSDellWarranty](https://github.com/twillin912/PSDellWarranty)

