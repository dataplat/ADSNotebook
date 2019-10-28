function New-ADSWorkBook {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        # The full path to the file
        [Parameter(Mandatory)]
        [ValidateScript({
            if($_ -match '^*.ipynb'){
                $true
            }
            else{
                Throw [System.Management.Automation.ValidationMetadataException] "The path $($_) does not have the correct extension. It needs to be .ipynb"
            }
        })]
        [string]
        $Path,
        # The cells (in order) created by New-ADSWorkBookCell to build the notebook 
        [Parameter(Mandatory)]
        [pscustomobject[]]
        $cells
    )

    $PSCmdlet.WriteVerbose('Lets create a Notebook')
    $PSCmdlet.WriteVerbose('Creating the base object')
    $Base = [PSCustomObject]@{
        metadata       = [PSCustomObject]@{
            kernelspec = [PSCustomObject]@{
                name         = 'SQL'
                display_name = 'SQL'
                language     = 'sql'
            }
        }
        language_info  = [PSCustomObject]@{
            name    = 'sql'
            version = ''
        }
        nbformat_minor = 2
        nbformat       = 4
        cells          = @()
    }

    $PSCmdlet.WriteVerbose('Adding the array of cells to the base object')
    foreach ($cell in $cells) {
        $base.cells += $cell
    }
    $PSCmdlet.WriteVerbose('Finished adding the array of cells to the base object')
    $PSCmdlet.WriteVerbose('Creating the json and replacing the back slashes and double quotes')
    try {
        if($IsCoreCLR){
            $base = ($Base | ConvertTo-Json -Depth 4 ).Replace('\\r', '\r').Replace('\\n', '\n').Replace('"\', '').Replace('\""','"')
        }
        else{
            # Grr PowwerShell
            $base = ($Base | ConvertTo-Json -Depth 4 ).Replace('\\r', '\r').Replace('\\n', '\n').Replace('\"\u003e','\">').Replace('"\"\u003c','"<').Replace('"\"', '"').Replace('\""','"').Replace('\u003c','<').Replace('\u003e','>')
        }
    }
    catch {
        $PSCmdlet.WriteWarning('Failed to create the json for some reason. Run `$error[0] | fl -force to find out why')
        Return
    }
    $PSCmdlet.WriteVerbose('json created')
    if ($PSCmdlet.ShouldProcess("$path", "Creating File")) {
        $Base | Set-Content -Path $path
    }
    $PSCmdlet.WriteVerbose('Created json file at' + $path + ' - Go and open it in Azure Data Studio')
}
