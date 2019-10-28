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
        $Text
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