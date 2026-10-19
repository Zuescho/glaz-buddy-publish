# GLAZ-Buddy – Deployment

Dieses Repository enthält die signierte Edge-Erweiterung für die Verteilung per Richtlinie.
Quellcode und Lizenz: [Zuescho/glaz-buddy](https://github.com/Zuescho/glaz-buddy) (GNU GPL v3).

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| `glaz-buddy.crx` | Signierte, gepackte Extension (von `tools/pack.ps1` erzeugt) |
| `updates.xml` | Update-Manifest für die Edge-Richtlinie |
| `extension-id.txt` | Extension-ID als Referenz |

Der private Signaturschlüssel liegt **nicht** hier, sondern nur beim Besitzer
(`local/extension-key.pem` im Quell-Repo). Er legt die Extension-ID fest.

## Installation auf Zielrechnern

Die Extension wird per Registry-Richtlinie installiert (als Administrator):

```
HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist
```

Neuer Wert (String, Name frei wählbar, z. B. `1`):

```
<Extension-ID>;https://raw.githubusercontent.com/Zuescho/glaz-buddy-publish/main/updates.xml
```

Beispiel:

```
ijhbmofnkgedjfknliopndpofmeddonp;https://raw.githubusercontent.com/Zuescho/glaz-buddy-publish/main/updates.xml
```

Nach einem Neustart von Edge installiert die Richtlinie die Extension; Nutzer können sie nicht
entfernen. Beim ersten Start fragt die Extension nach der eVAYO-Adresse (oder übernimmt sie aus
einem offenen eVAYO-Tab).

## Updates

Bei jedem Release wird `glaz-buddy.crx` mit einer höheren `version` ersetzt und beide Dateien
gepusht. Edge liest `updates.xml` (ca. alle paar Stunden und beim Start), lädt die neue CRX und
installiert sie selbstständig – ohne Klick, ohne Neustart des Profils.

Der Update-Check der Richtlinie läuft ohne Anmeldung: Dieses Repository **muss öffentlich bleiben**.

## Deinstallation

Den Registry-Eintrag unter `ExtensionInstallForcelist` entfernen und Edge neu starten.
