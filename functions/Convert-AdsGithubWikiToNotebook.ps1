<#
.SYNOPSIS
Converts a Github Wiki markdown page to a notebook

.DESCRIPTION
Converts a Github Wiki markdown page to a notebook

.PARAMETER FilePath
The full path to the markdown page

.PARAMETER NotebookDirectory
The directory to store the notebook

.PARAMETER NotebookType
The type of notebook to create

.EXAMPLE
$Wikilocation = 'C:\Users\mrrob\OneDrive\Documents\GitHub\ClonedForked\SqlServerAndContainersGuide.wiki'
$GitLocation = 'C:\Users\mrrob\OneDrive\Documents\GitHub\ClonedForked\SqlServerAndContainersGuide'

$dotnetnotebookpath = "$GitLocation\Notebooks\dotnet\"
$notdotnetnotebookpath = "$GitLocation\Notebooks\notdotnet\"

Copy-Item -Path $Wikilocation\images -Destination $GitLocation\Notebooks\ -Recurse -Force

$wikipages = Get-ChildItem $Wikilocation\*md

foreach ($page in $wikipages) {

    Convert-AdsGithubWikiToNotebook -FilePath $page.FullName -NotebookDirectory $dotnetnotebookpath -NotebookType DotNetPowerShell -WhatIf
    Convert-AdsGithubWikiToNotebook -FilePath $page.FullName -NotebookDirectory $notdotnetnotebookpath -NotebookType PowerShell -WhatIf
}

Gets all of the markdown pages in the wiki location and converts them to dot net and not dotnet notebooks

.NOTES
Rob Sewell 15/08/2020 - Initial
#>
function Convert-AdsGithubWikiToNotebook {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        [Parameter(Mandatory)]
        [string]$NotebookDirectory,
        [Parameter(Mandatory)]
        [ValidateSet('SQL', 'PowerShell', 'DotNetPowerShell')]
        [string]$NotebookType
    )
    if (Test-Path $FilePath) {
        $page = Get-Item $FilePath
    }
    else {
        Write-Warning "There doesn't appear to be anything here $filepath"
        Return
    }

    $content = Get-Content $page.FullName
    $cells = @()
    $lasttype = 'Text'
    $vars = 'Text', 'Code'
    $blockcontent = ''
    $content.ForEach{
        Write-Verbose "Starting Line"
        $line = $psitem
        $line = $line.Replace('[[', '![](..').Replace(']]', ')')
        if ($line.StartsWith('    ')) {
            Write-Verbose "This is a code line: $line"
            $type = 'code'
        }
        else {
            $type = 'text'
            Write-Verbose "This is a not code line: $line"
        }
        if ($lasttype -eq $type) {
            Write-Verbose "Set blockcontent"
            $blockcontent = $blockcontent + "`r" + $line 
        }
        else {   
            $celltype = $vars -ne $type | Out-String 
            $celltype = $celltype.Replace("`r`n", '')
            $block = New-ADSWorkBookCell -Type $celltype -Text $blockcontent
            $blockcontent = $line
            $cells = $cells + $block
        }
        $lasttype = $type
        $message = "Text $text "
        Write-Verbose $message
        Write-Verbose "Code - $code"
        Write-Verbose "Finished Line"
    }
    
    Write-Verbose "Set Line to new cell"
    $block = New-ADSWorkBookCell -Type $type -Text $blockcontent
    $blockcontent = $line
    $cells = $cells + $block
    $message = $cells | Out-String
    Write-Verbose $message
    
    if ($cells) {
        $path = $NotebookDirectory + $page.Name.replace('.md', '.ipynb')

        switch ($NotebookType) {
            DotNetPowerShell {
                if ($PSCmdlet.ShouldProcess("$path", "Creating DotNetPowerShell Notebook ")) {
                    New-ADSWorkBook -Path $path -cells $cells -Type DotNetPowerShell
                }
            }
            PowerShell {
                if ($PSCmdlet.ShouldProcess("$path", "Creating PowerShell Notebook ")) {
                    New-ADSWorkBook -Path $path -cells $cells -Type PowerShell
                }
            }
            SQL {
                if ($PSCmdlet.ShouldProcess("$path", "Creating SQL Notebook ")) {
                    New-ADSWorkBook -Path $path -cells $cells -Type SQL
                }
            }
        }
    }
    else {
        Write-Warning "Don't appear to have any content in $($page.Name)"
    }

}
