---
external help file: PSDellWarranty-help.xml
online version: https://github.com/twillin912/DellWarranty
schema: 2.0.0
---

# Get-DellWarrantyInfo

## SYNOPSIS
Get warranty information for Dell servers.

## SYNTAX

### ByComputerName (Default)
```
Get-DellWarrantyInfo [-ComputerName <String[]>] [-Latest]
```

### ByServiceTag
```
Get-DellWarrantyInfo -ServiceTag <String[]> [-Latest]
```

## DESCRIPTION
A detailed description of the Get-DellWarrantyInfo function.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-DellWarrantyInfo -ServiceTag XXXXXXX
```

Get warranty information by service tag

### -------------------------- EXAMPLE 2 --------------------------
```
Get-DellWarrantyInfo -Computer MyComputer -Latest
```

Get warranty information by computer name or IP address and only display the last to expire

### -------------------------- EXAMPLE 3 --------------------------
```
Get-DellWarrantyInfo -Computer MyComputer | Export-Csv -Path C:\Assets.csv
```

Get warranty information by computer name and export to CSV file for review

## PARAMETERS

### -ComputerName
{{Fill ComputerName Description}}

```yaml
Type: String[]
Parameter Sets: ByComputerName
Aliases: 

Required: False
Position: Named
Default value: Localhost
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServiceTag
ServiceTag should be a valid Dell Service tag.
Enter one or more values.

```yaml
Type: String[]
Parameter Sets: ByServiceTag
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Latest
Switch to display only the most currently warranty.

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

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES
Author: Trent Willingham
Check out my other scripts and projects @ https://github.com/twillin912

Requires -Version 4.0

## RELATED LINKS

[https://github.com/twillin912/DellWarranty](https://github.com/twillin912/DellWarranty)

