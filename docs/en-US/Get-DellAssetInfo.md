---
external help file: PSDellWarranty-help.xml
online version: https://github.com/twillin912/DellWarranty
schema: 2.0.0
---

# Get-DellAssetInfo

## SYNOPSIS
Get asset information for Dell servers.

## SYNTAX

```
Get-DellAssetInfo [[-ComputerName] <String[]>] [[-ServiceTag] <String[]>] [-Latest]
```

## DESCRIPTION
A detailed description of the Get-DellAssetInfo function.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-DellAssetInfo -ServiceTag XXXXXXX
```

Get asset information by service tag

### -------------------------- EXAMPLE 2 --------------------------
```
Get-DellAssetInfo -Computer MyComputer
```

Get asset information by computer name or IP address

### -------------------------- EXAMPLE 3 --------------------------
```
Get-DellAssetInfo -Computer MyComputer | Export-Csv -Path C:\Assets.csv
```

Get asset information by computer name and export to CSV file for review

## PARAMETERS

### -ComputerName
Name should be a valid computer name or IP address.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Name, HostName, Identity, DNSHostName

Required: False
Position: 1
Default value: Localhost
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ServiceTag
ServiceTag should be a valid Dell Service tag.
Enter one or more values.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Serial, SerialNumber

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Latest
{{Fill Latest Description}}

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

