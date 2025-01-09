Write-Host @"
   _____                      _            _     _       _   _             
  / ____|                    | |          | |   | |     | | | |            
 | |     ___  _ __ ___   ___ | | ___   ___| | __| |_   _| |_| |_ ___  _ __ 
 | |    / _ \| '_ ` _ \ / _ \| |/ _ \ / __| |/ /| | | | | __| __/ _ \| '__|
 | |___| (_) | | | | | | (_) | |  __/ \__ \   < | | |_| | |_| || (_) | |   
  \_____\___/|_| |_| |_|\___/|_|\___| |___/_|\_\|_|\__,_|\__|\__\___/|_|   
                                                                       
"@ -ForegroundColor Green

Write-Host "this Script identify the space disk and move those file from one destination to another."
Write-Host "It's easier to set up and the script will run after first time settings."
Write-Host "the configuracion is saved at config.json."
Write-Host "---------------------------------------------------------------------"

$configFilePath = Join-Path $PSScriptRoot "config.json"

if (Test-Path $configFilePath) {
    $config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
    $sourcePath = $config.sourcePath
    $destinationPath = $config.destinationPath
    $diskToCheck = $config.diskToCheck
} else {
    $sourcePath = Read-Host "Ingrese la ruta de origen (ej. C:\Logs):"
    $destinationPath = Read-Host "Ingrese la ruta de destino (ej. C:\Logs-Backup):"
    $diskToCheck = Read-Host "Ingrese la letra de la unidad a verificar (ej. C):"

    $config = @{
        sourcePath = $sourcePath
        destinationPath = $destinationPath
        diskToCheck = $diskToCheck
    }
    $config | ConvertTo-Json | Set-Content -Path $configFilePath
    Write-Host "Configuración guardada en $configFilePath"
}

$threshold = 80

if ((Get-ExecutionPolicy) -ne "Unrestricted") {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
    Write-Host "Se ha establecido la política de ejecución a Unrestricted para esta sesión."
}

function Move-OldestFolders {
    $oldestFolders = Get-ChildItem -Path $sourcePath -Directory | Sort-Object LastWriteTime | Select-Object -First 10
    if ($oldestFolders) {
        foreach ($folder in $oldestFolders) {
            $destinationFolder = Join-Path $destinationPath $folder.Name
            try {
                Move-Item -Path $folder.FullName -Destination $destinationFolder -Force
                Write-Host "Carpeta '$($folder.Name)' movida a '$destinationPath'."
            } catch {
                Write-Warning "Error al mover la carpeta '$($folder.Name)': $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "No se encontraron carpetas en '$sourcePath'."
    }
}

while ($true) {
    try {
        $disk = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -eq "$($diskToCheck)\"}
        if ($disk) {
            $freeSpaceGB = ($disk.Free / 1GB)
            $totalSpaceGB = ($disk.Used + $disk.Free) / 1GB
            $usedSpacePercent = (($totalSpaceGB - $freeSpaceGB) / $totalSpaceGB) * 100 # Cálculo real del espacio usado
            Write-Host "Espacio usado: $($usedSpacePercent.ToString('0.00'))% (Libre: $($freeSpaceGB.ToString('0.00')) GB de $($totalSpaceGB.ToString('0.00')) GB)"
            if ($usedSpacePercent -ge $threshold) {
                Write-Host "El espacio en disco ha superado el $($threshold)%. Iniciando movimiento de carpetas."
                Move-OldestFolders
            }
        } else {
            Write-Warning "No se encontró el disco '$diskToCheck'. Verifique la letra de la unidad."
        }
    } catch {
        Write-Warning "Error al obtener información del disco: $($_.Exception.Message)"
    }
    Start-Sleep -Seconds 300
}
