# winget-bool.ps1
# Author: HilulPython
# Version 1.0.0.0

[string]$global:CurrentVersion = "1.0.0.0" 

#------------------------------------------------------------------------------------------------------------------#
#                                                    VARIABLES                                                     #
#------------------------------------------------------------------------------------------------------------------#
[string[]]$WingetArgs = @()                   # Create a empty array for the winget parameters
[int16]$global:originalBufferSize = $rawUI.BufferSize
[int16]$global:originalWindowSize = $rawUI.WindowSize

[bool]$global:Should_Output_All = $false      # Toggle if you want to show the output of winget at the end
[bool]$global:Should_Return_Array = $false    # Toggle the array output of the bools

[bool]$global:get_LEC_Output = $true          # Bool to get if the Exit code of winget should also be saved/used

[string[]]$global:Package_ID = @()            # store the passed Package ids
[Version[]]$global:Package_Version = @()      # Used to store the current package version
[string[]]$global:ErrorCache                  # Used to store package error messages

[bool[]]$global:outBool = @()                 # Create empty boolean array output

[bool]$global:IsWingetError = $false          # Used for the getPackageArgs function
[string[]]$WingetArgs
#------------------------------------------------------------------------------------------------------------------#



#---------------------------------------------------------------------------------------#
#                              Needed System User Variable                              #
#---------------------------------------------------------------------------------------#
# WG = Winget
[string]$global:WG_Name = "WINGET_BOOL_VAR_NAME"   # Name of the temp user variable
[string]$stdName = "WINGET_BOOL_EVAL"              # Default value if it doesnt exist

if (-not [Environment]::GetEnvironmentVariable($global:WG_Name, 'User')) {
    [Environment]::SetEnvironmentVariable($global:WG_Name, $stdName , 'User')
}
#---------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------#
#                               System User Variable                                #
#-----------------------------------------------------------------------------------#
[string]$defaultVal = "0"           # Default value if it doesnt exist
[Environment]::SetEnvironmentVariable($global:WG_Name, $defaultVal, 'User')
#-----------------------------------------------------------------------------------#



#------------------------------------------------------------------------------------------------------------------------------------#
#                                                           Terminal Setup                                                           #
#------------------------------------------------------------------------------------------------------------------------------------#
chcp 65001 > $null                                                      # (Change Code Page) Changes the Code Page to 65001 (UTF-8)
[System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)     # Force the Terminal Encoding to be UTF-8
#------------------------------------------------------------------------------------------------------------------------------------#



#-------------------------------------------------------------------------------------------------------------------------------#
#                                                         Help-Function                                                         #
#-------------------------------------------------------------------------------------------------------------------------------#
function Get-Help {
    [OutputType([void])]
    param ()

    Write-Host @"
winget-bool - PowerShell Winget wrapper
Verwendung: winget-bool [<Befehl>] [<Optionen>]

Folgende Befehle sind für winget verfügbar:
  install    Installiert das angegebene Paket
  show       Zeigt Informationen zu einem Paket an
  source     Verwalten von Paketquellen
  search     Suchen und Anzeigen grundlegender Informationen zu Paketen
  list       Installierte Pakete anzeigen
  upgrade    Zeigt verfügbare Upgrades an und führt sie aus.
  uninstall  Deinstalliert das angegebene Paket
  hash       Hilfsprogramm zum Hashen von Installationsdateien
  validate   Überprüft eine Manifestdatei
  settings   Einstellungen öffnen oder Administratoreinstellungen festlegen
  features   Zeigt den Status von experimentellen Features an
  export     Exportiert eine Liste der installierten Pakete
  import     Installiert alle Pakete in einer Datei
  pin        Paketpins verwalten
  configure  Konfiguriert das System in einem gewünschten Zustand
  download   Lädt das Installationsprogramm aus einem bestimmten Paket herunter.
  repair     Repariert das ausgewählte Paket
  dscv3      DSC v3-Ressourcenbefehle

Folgende Befehle sind für winget-bool verfügbar:
  changeName <Name>  Kann benutzt werden um den Namen der User Variable zu ändern

Wenn Sie weitere Details zu einem bestimmten Befehl erfahren möchten, übergeben Sie ihm das Hilfe-Argument. [-?]

Die folgenden Optionen stehen für winget zur Verfügung:
  -v,--version                Version des Tools anzeigen
  --info                      Allgemeine Informationen zum Tool anzeigen
  -?                          Zeigt Hilfe zum ausgewählten Befehl an
  --logs,--open-logs          Öffnen des Standardspeicherorts für Protokolle
  --verbose,--verbose-logs    Aktiviert die ausführliche Protokollierung für WinGet
  --nowarn,--ignore-warnings  Unterdrückt Warnungsausgaben.
  --disable-interactivity     Interaktive Eingabeaufforderungen deaktivieren
  --proxy                     Legen Sie einen Proxy fest, der für diese Ausführung verwendet werden soll.
  --no-proxy                  Verwendung des Proxys für diese Ausführung deaktivieren

Die folgenden Optionen stehen für winget-bool zur Verfügung:
  -help         (-h)          Zeigt diese Hilfe an (überschreibt nicht -? aber --help)
  -out          (-o)          Gibt die Normalen Ausgabe des Befehls
  -returnarray  (-ra)         Gibt die Ausgang als Bool array
  -windowinfo   (-wi)         Zeigt die Größe des Powershell-Fensters an

"@
}
#-------------------------------------------------------------------------------------------------------------------------------#



#-------------------------------------------------------------------------------------------------------------------------------#
#                                                            Macros                                                             #
#-------------------------------------------------------------------------------------------------------------------------------#
function Write-Text {
    [OutputType([void])]
    param (
        [string]$text,  
        [bool]$isError  
    )

    if ($global:Should_Output_All) {
        if ($isError) {
            Write-Error $text
            return $true
        }

        Write-Host $text
        return $true
    }
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Get-Active {
    [OutputType([bool])]
    param ()

    return ($null -ne[Environment]::GetEnvironmentVariable($varName, 'User'))
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Format-Output {
    param (
        [bool]$shouldString = $false
    )

    if ($shouldString) {
        if ($global:Should_Return_Array) {
            return ($global:outBool | ForEach-Object { if ($_){ "1" } else { "0" }}) -join ""       # "101001"
        }

        return if (-not ($global:outBool -contains $false)){ "1" } else { "0" }     # "1"
    }

    if ($global:Should_Return_Array) {
        return $global:outBool      # [true, false, false, true]
    }

    return -not ($global:outBool -contains $false)      # true
}
#-------------------------------------------------------------------------------------------------------------------------------#



#-------------------------------------------------------------------------------------------------------------------------------#
#                                                          Functions                                                            #
#-------------------------------------------------------------------------------------------------------------------------------#
function Get-UpgradeSpaceCount {
    [OutputType([int16[]])]   # Output type indicator
    param (
        [string]$inputText,
        [string]$dashText
    )
    [int[]]$adds = @(4, 2, 7, 9)

    $spaceCounts = [regex]::Matches($inputText, '\S( +)\S') | ForEach-Object {
        $_.Groups[1].Value.Length
    }

    for ($i = 0; $i -lt $spaceCounts.Count; $i++) {
        if ($i -lt $adds.Length) {
            $spaceCounts[$i] += $adds[$i]
        }
    }
    
    $dashCount = ([regex]::Matches($dashText, '-')).Count
    $leftoverSpace = $dashCount - ($spaceCounts | Measure-Object -Sum).Sum
    $spaceCounts += $leftoverSpace

    return $spaceCounts
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Get-UpgradeVersion {
    [OutputType([int16])]   # Output type indicator
    param (
        [string]$package,
        [bool]$show
    )

    $rawUI = $Host.UI.RawUI
    $originalBufferSize = $rawUI.BufferSize
    $originalWindowSize = $rawUI.WindowSize

    $maxWidth = 120
    $rawUI.BufferSize = New-Object System.Management.Automation.Host.Size ($maxWidth, $originalBufferSize.Height)
    $rawUI.WindowSize = New-Object System.Management.Automation.Host.Size ($maxWidth, $originalWindowSize.Height)

    [bool]$returnVal = $false
    [string[]]$EvalArgs = @(
        "upgrade"
        $package
        "--silent"
        "--accept-package-agreements"
        "--accept-source-agreements"
    )

    if (!$show) {
        [string[]]$lines = winget $EvalArgs
        [int16[]]$spacings = Get-UpgradeSpaceCount $lines[0] $lines[1]
        [int16]$itemAmount = $null

        for ($i = $lines.Length - 1; $i -ge 0; $i--) {
            if ($lines[$i] -match '^\s*(\d+)') {
                $itemAmount = [int16]$matches[1]
                break
            }
        }

        for ($i = 2; $i -lt $itemAmount + 2; $i++) {
            [string]$line = $lines[$i]
            [string]$packageID = $line.Substring($itemAmount[0], $itemAmount[1]).TrimEnd()
            if ($packageID.EndsWith("...")) {
                $packageID = $packageID.Substring(0, $packageID.Length - 3)
            }
            
            if ($package.Contains($packageID)) {
                $global:Package_Version += [Version]::Parse($line.Substring(
                    ($itemAmount[0]+$itemAmount[1]),
                    $itemAmount[2]
                ).TrimEnd())

                $global:Package_Version += [Version]::Parse($line.Substring(
                    ($itemAmount[0]+$itemAmount[1]+$itemAmount[2]),
                    $itemAmount[3]
                ).TrimEnd())
                $returnVal = $true
                break
            }
        }
    } else {
        [string[]]$lines = winget show $package
        
        foreach ($line in $lines) {
            if ($line.ToLower().StartsWith("version:")) {
                $global:Package_Version += [Version]::Parse($line.Split(": ")[1].TrimEnd())
                $returnVal = $true
                break
            }
        }
    }
    
    $rawUI.BufferSize = $originalBufferSize
    $rawUI.WindowSize = $originalWindowSize
    return $returnVal
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Measure-Winget {
    [OutputType([int16])]   # Output type indicator
    param (
        [string[]]$WingetArgs
    )
    
    [int16]$packageIndex = 0
    [bool]$skip
    
    [string[]]$filteredOutput = winget $WingetArgs 2>&1 | Where-Object {
        $_ -notmatch '^[\s\/\\|\-]+$' -and
        $_ -match "[A-Za-z]"
    }
    [string[]]$packages = @($WingetArgs[1..($WingetArgs.Length - 1)] | Where-Object {
        $_ -match '^[^.]+\.[^.]+$'
    })
    
    if (0 -eq $LASTEXITCODE) {
        Write-Text $filteredOutput -join "`n"
        return $true
    } else {
        $global:ErrorCache += $filteredOutput -join "`n"
        return $false
    }
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Invoke-PackageUpgrade {
    [OutputType([bool[]])]
    param (
        [string[]]$WingetArgs
    )
    
    [bool[]]$Outputs = $false
    
    [string[]]$packages = @($WingetArgs[1..($WingetArgs.Length - 1)] | Where-Object {
        $_ -match '^[^.]+\.[^.]+$'
    })
    
    if (0 -eq $packages.Length) {
        $global:ErrorCache += "Keine Validen ID's gegeben"
        return $false
    }
    
    [string[]]$EvalArgs = @(
        "upgrade"
        $fpak
        "--silent"
        "--accept-package-agreements"
        "--accept-source-agreements"
    )
    
    foreach ($fpak in $packages) {
        $global:Package_ID += $fpak
        $global:Package_Version.Clear()
        
        if ( -not (Get-UpgradeVersion $fpak $false)) {  # Get current and upgrade version
            $global:ErrorCache += "Das Paket '$fpak' wurde nicht gefunden"
            $global:outBool += $false
            continue
        }
        
        if ( -not (Measure-Winget $EvalArgs)) {    # Try to upgrade
            $global:outBool += $false
            continue
        }
        
        if ( -not (Get-UpgradeVersion $fpak $true)) {   # Get new current version
            $global:ErrorCache += "Das Paket '$fpak' wurde nicht gefunden (Sollte Eigentlich nicht passieren)"
            $global:outBool += $false
            continue
        }
        
        if ($global:Package_Version[1] -ge $global:Package_Version[2]) {    # Expected version >= current version
            $global:outBool += $true
            continue
        }
    }
    return $true
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Update-EnvVariable {
    [OutputType([void])]
    param(
        [string]$newName
    )
    
    $childName = [Environment]::GetEnvironmentVariable($global:WG_Name, 'User')
    
    if (-not $childName) {
        Write-Host "Master-Variable '$global:WG_Name' hat keinen Wert. Vorgang abgebrochen."
        return 1
    }
    
    $childValue = [Environment]::GetEnvironmentVariable($childName, 'User')
    
    if ($childName) {
        [Environment]::SetEnvironmentVariable($childName, $null, 'User')
        Write-Host "Alte Variable '$childName' wurde entfernt."
    }
    
    [Environment]::SetEnvironmentVariable($newName, $childValue, 'User')
    Write-Host "Neue Variable '$newName' wurde erstellt."
    
    [Environment]::SetEnvironmentVariable($global:WG_Name, $newName, 'User')
    Write-Host "Master-Variable '$global:WG_Name' wurde auf '$newName' aktualisiert."
    
    # Notify system of env var changes
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class NativeMethods {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam,
        string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
'@ -PassThru | Out-Null 
    
    # Broadcast handle to send the message to all top-level windows
    $HWND_BROADCAST = [intptr]0xffff
    
    # Message identifier for "system settings have changed"
    $WM_SETTINGCHANGE = 0x1A
    
    # Flag to abort sending message if the recipient is not responding (hung)
    $SMTO_ABORTIFHUNG = 0x0002
    
    # Variable to receive the result of the SendMessageTimeout call (not used here)
    [UIntPtr]$result = [UIntPtr]::Zero
    
    # Send a system-wide message notifying all windows that environment variables changed
    [NativeMethods]::SendMessageTimeout(
        $HWND_BROADCAST,       # Target: all top-level windows
        $WM_SETTINGCHANGE,     # Message: system setting change notification
        [uintptr]::Zero,       # wParam: not used for this message, set to zero
        "Environment",         # lParam: string specifying environment variables changed
        $SMTO_ABORTIFHUNG,     # SendMessageTimeout flag: abort if the recipient hangs
        5000,                  # Timeout in milliseconds (5 seconds)
        [ref]$result           # Output parameter to receive result (ignored here)
    ) | Out-Null               # Suppress any output from the call
}
#-------------------------------------------------------------------------------------------------------------------------------#
function Update-Script {
    param(
        [string]$VersionUrl = "https://raw.githubusercontent.com/Hilulpython/winget-bool/refs/heads/main/Version.txt",
        [string]$ScriptUrl = "https://github.com/Hilulpython/winget-bool/raw/refs/heads/main/Script/winget-bool.exe"
    )
    
    [string]$CurrentVersion = $global:CurrentVersion
    
    try {
        [string]$RemoteVersion = (Invoke-WebRequest -Uri $VersionUrl -UseBasicParsing -ErrorAction Stop).Content.Trim()
    }
    catch {
        Write-Warning "Fehler beim Abrufen der Remote-Version von $VersionUrl"
        return
    }
    
    if ([version]$RemoteVersion -gt [version]$CurrentVersion) {
        Write-Host "Neue Version verfügbar: $RemoteVersion (aktuell: $CurrentVersion). Aktualisierung..."
        
        try {
            $NewScriptContent = (Invoke-WebRequest -Uri $ScriptUrl -UseBasicParsing -ErrorAction Stop).Content
        }
        catch {
            Write-Warning "Das Herunterladen des neuen Skripts von $ScriptUrl ist fehlgeschlagen."
            return
        }
        
        $CurrentScriptPath = $MyInvocation.MyCommand.Path
        
        if (-not $CurrentScriptPath) {
            Write-Warning "Aktueller Skriptpfad kann nicht ermittelt werden. Aktualisierung abgebrochen."
            return
        }
        
        try {
            $NewScriptContent | Set-Content -Path $CurrentScriptPath -Encoding UTF8
            Write-Host "Skript erfolgreich auf Version $RemoteVersion aktualisiert."
        }
        catch {
            Write-Warning "Die neue Version konnte nicht in $CurrentScriptPath gespeichert werden."
            return
        }
    }
    else {
        Write-Host "Kein Update erforderlich."
    }
}
#-------------------------------------------------------------------------------------------------------------------------------#



#-------------------------------------------------------------------------------------------------------------------------------#
#                                                             Main                                                              #
#-------------------------------------------------------------------------------------------------------------------------------#
#                       
if ($args[0].ToLower().Equals("update")) {           
    Update-Script       
    return              
}                       
#                       
#-------------------------------------------------------------------------------------------------------------------------------#
#                       
foreach ($arg in $args) {    
    [bool]$shouldSkip = $false                       
    switch ($arg.ToLower()) {
        #               
        "-help" {       
            Get-Help   
            return $true
        }               
        #               
        "-h" {          
            Get-Help   
            return $true
        }               
        #               
        "--help" {      
            Get-Help   
            return $true
        }               
        #               
        "-out" {        
            $Should_Output_All = $shouldSkip = $true 
            break       
        }               
        #               
        "-o" {          
            $Should_Output_All = $shouldSkip = $true 
            break       
        }               
        #               
        "-returnarray" {
            $Should_Return_Array = $shouldSkip = $true   
            break       
        }               
        #               
        "-ra" {         
            $Should_Return_Array = $shouldSkip = $true   
            break       
        }               
    }                   
    #                   
    if (-not $shouldSkip) {  
        $WingetArgs += $arg  
    }                   
}                       
#                       
#-------------------------------------------------------------------------------------------------------------------------------#
#                       
if (0 -eq $WingetArgs.Length) {                      
    return $false       
}                       
#                       
#-------------------------------------------------------------------------------------------------------------------------------#
#                       
if ($WingetArgs[0].ToLower() -match 'upgrade') {     
    #                   
    if (1 -eq $WingetArgs.Length) {                  
        winget upgrade  
    }                   
    #                   
    elseif (1 -lt $WingetArgs.Length) {              
        if (0 -ne (Invoke-PackageUpgrade $WingetArgs)) {                                                                      #
            Write-Text $global:ErrorCache[0] $true   
            return $false    
        }               
        #               
        if ($global:Should_Output_All) {             
            foreach ($err in $global:ErrorCache) {   
                Write-Text $err $true                
            }           
        }               
        #               
        if (Get-Active) {    
            [string]$value = Format-Output $true     
            [Environment]::SetEnvironmentVariable($varName, $value, 'User')                                                     #
            return $true
        }               
        #               
        return Format-Output 
    }                   
}                       
#                       
#-------------------------------------------------------------------------------------------------------------------------------#
#                       
if ($WingetArgs[0].ToLower() -match 'changeName') {  
    if (2 -gt $WingetArgs.Length) {                  
        Write-Text "Kein Name wurde gegenen (Script.ps1 changeName <Name>)" $true                                               #
        return $false   
    }                   
    #                   
    Update-EnvVariable $WingetArgs[1]                
    return $true        
}                       
#                       
#-------------------------------------------------------------------------------------------------------------------------------#
#                       
if (-not (Measure-Winget $WingetArgs)) {             
    Write-Text $global:ErrorCache[0]                 
    $global:outBool += $true 
    return Format-Output
}                       
#                       
$global:outBool += $true
return Format-Output    
#                       
#-------------------------------------------------------------------------------------------------------------------------------#