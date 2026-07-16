function Write-M365ToolkitLog {
    <#
    .SYNOPSIS
        Internal helper for writing verbose log messages within the module.
    .DESCRIPTION
        Sample private function. Private functions are not exported and are only
        callable from within other module functions.
    .PARAMETER Message
        The message to write.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Verbose "[M365.Toolkit] $Message"
}
