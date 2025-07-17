# Winget-bool
A Winget wrapper script (Compiled with ps2exe)

## What is this script
It's a wrapper to the Windows 'winget' command focusing mostly on the upgrade part of it, where it checks if the procedure went successful or if any Error occured

## Features
- Evaluate all 'winget' commands 
- Will return a boolean or boolean array
- Can be used to store the result in a User variable (Standard name: 'WINGET_BOOL_EVAL')

## Getting Started

### Requirements
- Powershell 7.0 or above

### Installation

```
Download the .exe
Move it to where you want to
Add the path to the User or System Path variable
```

## Help
<pre>
winget-bool - PowerShell Winget wrapper
Verwendung: winget-bool [&lt;Befehl&gt;] [&lt;Optionen&gt;]

Die folgenden Optionen stehen für winget-bool zur Verfügung:
  -help         (-h)          Zeigt diese Hilfe an (überschreibt nicht -? aber --help)
  -out          (-o)          Gibt die Normalen Ausgabe des Befehls
  -returnarray  (-ra)         Gibt die Ausgang als Bool array
  -windowinfo   (-wi)         Zeigt die Größe des Powershell-Fensters an
</pre>