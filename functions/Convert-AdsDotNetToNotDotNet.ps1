function Convert-AdsDotNetToNotDotNet {
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
        $Source = Get-Content $SourceNotebook | ConvertFrom-Json
    }
    else {
        Write-Warning "There doesn't appear to be anything here $SourceNotebook"
        Return
    }

    if($source.metadata.kernelspec.name -eq '.net-powershell'){

    }else{
        Write-Warning "This notebook $SourceNotebook does not appear to be a dotnet PowerShell notebook "
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
      
    $Source.metadata.kernelspec.name = 'powershell'
    $Source.metadata.kernelspec.display_name = 'PowerShell'
    $Source.metadata.language_info.name = 'powershell'
    $Source.metadata.language_info.mimetype = 'text/x-sh'
    $Source.metadata.language_info | Add-Member -Name "codemirror_mode" -Value 'shell' -MemberType NoteProperty
    $Source.metadata.language_info.PSObject.Properties.Remove('version')
    $Source.metadata.language_info.PSObject.Properties.Remove('pygments_lexer')

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