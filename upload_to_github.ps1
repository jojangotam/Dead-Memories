# upload_to_github.ps1
# Script para inicializar repo (si hace falta), commitear y hacer push al remoto HTTPS
# Uso: abre PowerShell en la carpeta del proyecto y ejecuta:
#   .\upload_to_github.ps1

$ErrorActionPreference = 'Stop'

$repoPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "Ejecutando en: $repoPath"
Set-Location -Path $repoPath

# Comprueba que git está disponible
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git no está disponible en este entorno. Asegúrate de instalar Git para Windows y volver a intentarlo. https://git-scm.com/download/win"
    exit 1
}

# Inicializa repo si no existe
if (-not (Test-Path .git)) {
    Write-Host "Inicializando repositorio git..."
    git init
} else {
    Write-Host "Repositorio git ya inicializado."
}

# Crear/usar rama main
try {
    git checkout -b main
} catch {
    git switch main 2>$null | Out-Null; git checkout main 2>$null | Out-Null
}

# Añadir y commitear
Write-Host "Añadiendo archivos y creando commit..."
git add .

# Si no hay cambios, evita crear commit vacío
$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
    Write-Host "No hay cambios para commitear."
} else {
    git commit -m "Initial commit: subir sitio Dead Memories"
}

# Configura remoto
$remoteUrl = 'https://github.com/jojangotam/Dead-Memories.git'
# Remueve remoto si existe
git remote remove origin -f 2>$null
git remote add origin $remoteUrl
Write-Host "Remoto 'origin' apuntando a: $remoteUrl"

# Forzar nombre de rama a main y push
git branch -M main
Write-Host "Haciendo push a origin/main (te pedirá credenciales si es necesario)..."
try {
    git push -u origin main
    Write-Host "Push completado. Revisa: https://github.com/jojangotam/Dead-Memories"
} catch {
    Write-Error "git push falló. Si usas HTTPS, asegúrate de tener Git Credential Manager configurado o usa un Personal Access Token (PAT) como contraseña cuando se solicite."
    exit 1
}

Write-Host "Script finalizado."