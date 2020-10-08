<#
.SYNOPSIS
Converts a Not DotNet  PowerShell notebook to a dotnet interactive PowerShell notebook for Azure Data Studio

.DESCRIPTION
Converts a Not DotNet  PowerShell notebook to a dotnet interactive PowerShell notebook for Azure Data Studio

.PARAMETER SourceNotebook
The path to the Source Notebook

.PARAMETER DestinationDirectory
The directory to create the DotNet Notebook (will be created if it doesnt exist)

.PARAMETER DestinationNotebook
Optional - The name of the Destination Notebook - will retain the original name by default

.EXAMPLE
Convert-AdsNotDotNetToDotNet -SourceNotebook Number1.ipynb -DestinationDirectory Git:\dbatoolsnotebooks

Will convert the not dotnet notebook Number1.iynb to a dotnet interactive notebook and save in the Git:\dbatoolsnotebooks directory

.EXAMPLE
Convert-AdsNotDotNetToDotNet -SourceNotebook Number1.ipynb -DestinationDirectory Git:\dbatoolsnotebooks -DestinationNotebook NotNumber1

Will convert the not dotnet notebook Number1.iynb to a dotnet interactive notebook and save in the Git:\dbatoolsnotebooks directory and rename it to NotNumber1

.NOTES
    Some Month in 2020 - Rob Sewell @SQLDbaWithBeard
    blog.robsewell.com
#>
function Convert-AdsNotDotNetToDotNet {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory)]
        [string]$SourceNotebook,
        [Parameter(Mandatory)]
        [string]$DestinationDirectory,
        [Parameter()]
        [string]$DestinationNotebook
    )

    if (Test-Path $SourceNotebook) {
        $SourceNotebookObject = Get-Item $SourceNotebook
        if($SourceNotebookObject.Extension -eq '.ipynb'){
            $Source = Get-Content $SourceNotebook | ConvertFrom-Json
        } else {
            Write-Warning "$SourceNotebook doesnt appear to be a notebook"
            Return
        }
    }
    else {
        Write-Warning "There doesn't appear to be anything here $SourceNotebook"
        Return
    }

    if (Test-Path $DestinationDirectory) {
        Write-Verbose "Destination Directory $DestinationDirectory exists "
    }
    else {
        if ($PSCmdlet.ShouldProcess("$DestinationDirectory", "Creating ")) {
            $null = New-Item $DestinationDirectory -ItemType Directory
        }
    }

    if ($source.metadata.kernelspec.name -eq 'powershell') {

    }
    else {
        Write-Warning "This notebook $SourceNotebook does not appear to be a notdotnet PowerShell notebook "
        Return
    }

     
    $Source.metadata.kernelspec.name = '.net-powershell'
    $Source.metadata.kernelspec.display_name = '.NET (PowerShell)'
    $Source.metadata.language_info.name = 'PowerShell'
    $Source.metadata.language_info | Add-Member -Name "version" -Value '7.0' -MemberType NoteProperty
    $Source.metadata.language_info.mimetype = 'text/x-powershell' 
    $Source.metadata.language_info.PSObject.Properties.Remove('codemirror_mode')
    $Source.metadata.language_info | Add-Member -Name "pygments_lexer" -Value 'powershell' -MemberType NoteProperty

    if($DestinationNotebook){
        if($DestinationNotebook.EndsWith('.ipynb')){

        }else{
            $DestinationNotebook = $DestinationNotebook + '.ipynb'
        }
        $Destination = $DestinationDirectory + '\' + $DestinationNotebook
    } else{
        $Destination = $DestinationDirectory + '\' +   $SourceNotebookObject.Name

    }
    if ($PSCmdlet.ShouldProcess("$Destination", "Creating NotDotNet Notebook")) {
    $Source | ConvertTo-Json -Depth 5 |Set-Content $Destination
    }
}