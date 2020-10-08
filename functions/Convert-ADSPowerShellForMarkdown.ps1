    <#
    .SYNOPSIS
    Converts PowerShell code into valid Markdown URI Link text

    .DESCRIPTION
    Converts PowerShell code into valid Markdown URI Link Text

    .PARAMETER inputstring
    The PowerShell to encode. IMPORTANT escap $ with a `

    .PARAMETER LinkText
    The text to show for the link

    .PARAMETER ToClipBoard
    Will not output to screen but instead will set the clipboard

    .EXAMPLE
    Convert-ADSPowerShellForMarkdown -InputText "Get-ChildItem" -LinkText 'This will list the files' -ToClipBoard

    Converts the PowerShell so that it works with MarkDown and sets it to the clipboard

    .NOTES
    June 2019 - Rob Sewell @SQLDbaWithBeard
    blog.robsewell.com
    #>

function Convert-ADSPowerShellForMarkdown {
    [cmdletbinding()]
    [OutputType('System.String')]

    Param(
        [Parameter(Mandatory = $true)]
        [string]$InputString,
        [string]$LinkText = " LINK TEXT HERE ",
        [switch]$ToClipBoard
    )

    [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
    $encodedstring = [System.Web.HttpUtility]::UrlEncode($inputstring)
    $linkage = $encodedstring.Replace('+', ' ').Replace('%3a', ':').Replace('%5c', '%5c%5c').Replace('%22', '\u0022').Replace('%27', '\u0027').Replace('%0D%0A', '').Replace('%3b%0a','\u003B ').Replace('%0a','\u000A')

    $outputstring = @"
<a href="command:workbench.action.terminal.sendSequence?%7B%22text%22%3A%22 $linkage \u000D %22%7D">$linktext</a>
"@
    if ($ToClipBoard) {
        if (-not ($IsLinux -or $IsMacOS) ) {
            $outputstring | Set-Clipboard
        }
        else {
            Write-Warning "Set-Clipboard - Doesnt work on Linux - Outputting to screen"
            $outputstring
        }
    }
    else {
        $outputstring
    }
}
