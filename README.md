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

```bash
Download the .exe
!!! There is no build-in installer... yet !!!
```

## Help
<pre>
winget-bool - PowerShell Winget wrapper
Verwendung: winget-bool \[\<Befehl\>\] \[\<Optionen\>\]

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
</pre>