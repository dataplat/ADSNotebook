<#
.SYNOPSIS
Creates a cell for an Azure Data Studio Notebook

.DESCRIPTION
Creates a text (markdown) or code (T-SQL) cell for an Azure Data Studio Notebook

.PARAMETER Type
The type of cell to create (code or text)

.PARAMETER Text
The value for the cell (markdown for text and T-SQL for celll)

.PARAMETER Collapse
Should the code cell be collapsed

.EXAMPLE
$introCelltext = "# Welcome to my Auto Generated Notebook

## Automation
Using this we can automate the creation of notebooks for our use
"
$Intro = New-ADSWorkBookCell -Type Text -Text $introCelltext

Creates an Azure Data Studio Text cell and sets it to a variable for passing to New-AdsWorkBook

.EXAMPLE
$thirdcelltext = "SELECT Name
FROM sys.server_principals
WHERE is_disabled = 0"
$Third = New-ADSWorkBookCell -Type Code -Text $thirdcelltext

Creates an Azure Data Studio Code cell which will be collapsed and sets it to a variable for passing to New-AdsWorkBook

.NOTES
Rob Sewell 10/10/2019 - Initial
Rob Sewell 19/11/2019 - Added Collapse parameter
#>

function New-ADSWorkBookCell {
    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "Because it doesnt really change anything")]
    Param (
        # The Type of cell
        [Parameter(Mandatory)]
        [ValidateSet('Code', 'Text')]
        [string]
        $Type,
        # The source for the cell
        [Parameter(Mandatory)]
        [string]
        $Text,
        [switch]
        $Collapse
    )
    $PSCmdlet.WriteVerbose('Lets create a Notebook Cell')
    switch ($type) {
        Text {
            $PSCmdlet.WriteVerbose('We are going to create a Text Cell')
            $PSCmdlet.WriteVerbose('Creating base object')
            $guid = [guid]::NewGuid().guid
            $basecell = [pscustomobject]@{
                cell_type = 'markdown'
                source    = @(
                )
                metadata  = [pscustomobject]@{
                    azdata_cell_guid = "$guid"
                }
            }
        }
        Code {
            $PSCmdlet.WriteVerbose('We are going to create a Code Cell')
            $PSCmdlet.WriteVerbose('Creating base object')
            $guid = [guid]::NewGuid().guid
            $basecell = [pscustomobject]@{
                cell_type       = 'code'
                source          = @(
                )
                metadata        = [pscustomobject]@{
                    azdata_cell_guid = "$guid"
                }
                outputs         = @()
                execution_count = 0
            }
        }
    }
    if($Collapse -and $Type -eq 'Code'){
        $basecell.metadata | Add-Member -Name tags -Value @('hide_input') -MemberType NoteProperty
    }
    $PSCmdlet.WriteVerbose('Now we need to parse the text, first split it by line ending')
    $rawtext = $text -split "[`r`n]+"

    $PSCmdlet.WriteVerbose('Recreate the code as an array of strings with the correct line ending')
    $source = @()
    foreach ($line in $rawtext) {
       $source += '"' + $Line + '\r\n"'
    }
    $PSCmdlet.WriteVerbose('Source now looks like this - Each line should be a double quote and end with \r\n' + $source)
    $PSCmdlet.WriteVerbose('Add source to the base cell')
    $basecell.source = $source
    $basecell
    $PSCmdlet.WriteVerbose('Finished creating cell')
}