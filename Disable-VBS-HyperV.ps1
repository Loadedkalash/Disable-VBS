#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Désactivation / Réactivation de VBS via DG_Readiness_Tool v3.6
.NOTES
    - Exécuter en tant qu'Administrateur
    - Option 1 : Désactiver VBS → Au redémarrage : Échap (Credential Guard), F3 (Hyper-V/VBS)
    - Option 2 : Réactiver VBS  → Au redémarrage : Entrée pour confirmer
#>

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# ─────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────
function Write-Step { param([string]$m)
    Write-Host "`n────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  $m" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────────" -ForegroundColor Cyan
}
function Write-OK   { param([string]$m) Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-WARN { param([string]$m) Write-Host "  [!!] $m" -ForegroundColor Yellow }
function Write-SKIP { param([string]$m) Write-Host "  [--] $m" -ForegroundColor DarkGray }

# ─────────────────────────────────────────────────────────────
# MENU
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║         VBS Manager — DG_Readiness_Tool      ║" -ForegroundColor Cyan
Write-Host "  ╠══════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "  ║  1  →  Désactiver VBS  (gain de perfs)       ║" -ForegroundColor Cyan
Write-Host "  ║  2  →  Réactiver VBS   (paramètres défaut)   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

do {
    $choice = Read-Host "  Votre choix (1 ou 2)"
} while ($choice -notin @("1", "2"))

# ─────────────────────────────────────────────────────────────
# ÉTAPE 1 — Téléchargement
# ─────────────────────────────────────────────────────────────
Write-Step "ÉTAPE 1 — Téléchargement de DG_Readiness_Tool v3.6"

$dgZipUrl  = "https://download.microsoft.com/download/B/D/8/BD821B1F-05F2-4A7E-AA03-DF6C4F687B07/dgreadiness_v3.6.zip"
$dgZipPath = "$env:TEMP\dgreadiness_v3.6.zip"
$dgExtract = "$env:TEMP\DGReadiness"
$dgScript  = "$dgExtract\DG_Readiness_Tool_v3.6.ps1"

if (-not (Test-Path $dgScript)) {
    try {
        Write-Host "  Téléchargement en cours..." -ForegroundColor White
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $dgZipUrl -OutFile $dgZipPath -UseBasicParsing -ErrorAction Stop
        Expand-Archive -Path $dgZipPath -DestinationPath $dgExtract -Force
        Write-OK "Téléchargement et extraction réussis."
    } catch {
        Write-WARN "Échec du téléchargement automatique : $_"
        Write-WARN "Téléchargez manuellement : https://www.microsoft.com/en-us/download/details.aspx?id=53337"
        Write-WARN "Placez DG_Readiness_Tool_v3.6.ps1 dans : $dgExtract"
        Read-Host "`n  Appuyez sur Entrée une fois le fichier en place"
    }
} else {
    Write-SKIP "Script déjà présent, téléchargement ignoré."
}

# ─────────────────────────────────────────────────────────────
# ÉTAPE 2 — Exécution selon le choix
# ─────────────────────────────────────────────────────────────
if ($choice -eq "1") {
    Write-Step "ÉTAPE 2 — Désactivation de VBS / Hyper-V"
} else {
    Write-Step "ÉTAPE 2 — Réactivation de VBS (paramètres défaut)"
}

if (Test-Path $dgScript) {
    try {
        if ($choice -eq "1") {
            & $dgScript -Disable -ErrorAction SilentlyContinue
        } else {
            & $dgScript -Enable -AutoReboot -ErrorAction SilentlyContinue
        }
        Write-OK "DG_Readiness_Tool exécuté avec succès."
    } catch {
        Write-WARN "Erreur lors de l'exécution : $_"
        exit 1
    }
} else {
    Write-WARN "Script introuvable — abandon."
    exit 1
}

# ─────────────────────────────────────────────────────────────
# ÉTAPE 3 — Restauration de la politique d'exécution
# ─────────────────────────────────────────────────────────────
Write-Step "ÉTAPE 3 — Restauration de la politique d'exécution"

try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted -Force
    Write-OK "ExecutionPolicy remise à Restricted."
} catch {
    Write-WARN "Impossible de restaurer ExecutionPolicy : $_"
}

# ─────────────────────────────────────────────────────────────
# FIN
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "────────────────────────────────────────────────" -ForegroundColor Green
Write-Host "  TERMINÉ" -ForegroundColor Green
Write-Host "────────────────────────────────────────────────" -ForegroundColor Green
Write-Host ""

if ($choice -eq "1") {
    Write-Host "  Au redémarrage, deux écrans vont apparaître :" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    Credential Guard  →  Échap  (ignorer)"           -ForegroundColor White
    Write-Host "    Hyper-V / VBS     →  F3     (confirmer désactivation)" -ForegroundColor White
} else {
    Write-Host "  Au redémarrage, confirmez la réactivation" -ForegroundColor Yellow
    Write-Host "  de VBS en appuyant sur Entrée si demandé." -ForegroundColor Yellow
}

Write-Host ""
$reboot = Read-Host "  Redémarrer maintenant ? (O/N)"
if ($reboot -match "^[Oo]$") {
    Restart-Computer -Force
}