Write-Host @"
   _____                      _            _     _       _   _             
  / ____|                    | |          | |   | |     | | | |            
 | |     ___  _ __ ___   ___ | | ___   __| | __| |   | || |_ ___  _ __ 
 | |    / _ \| '_ ` _ \ / _ \| |/ _ \ / _| |/ /| | | | | __| __/ _ \| '_|
 | || () | | | | | | () | |  __/ \_ \   < | | || | || || (_) | |   
  \\/|| || ||\/||\| |/|\\||\,|\|\\/|_|   
                                                                       
"@ -ForegroundColor Green

Write-Host "Este script identifica el espacio en disco y mueve carpetas antiguas de un origen a un destino."
Write-Host "La configuración se guarda en el archivo config.json para futuras ejecuciones."
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
    $config | ConvertTo-Json -Depth 10 | Set-Content -Path $configFilePath -Encoding UTF8
    Write-Host "Configuración guardada en $configFilePath"
}

$threshold = 80

if ((Get-ExecutionPolicy) -ne "Unrestricted") {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
    Write-Host "Se ha establecido la política de ejecución a Unrestricted para esta sesión."
}

 function Move-OldestFolders {
    $foldersMoved = 0
    $oldestFolders = Get-ChildItem -Path $sourcePath -Directory | Sort-Object LastWriteTime | Select-Object -First 25
    if ($oldestFolders) {
        foreach ($folder in $oldestFolders) {
            $destinationFolder = Join-Path $destinationPath $folder.Name
            try {
                Move-Item -Path $folder.FullName -Destination $destinationFolder -Force
                Write-Host "Carpeta '$($folder.Name)' movida a '$destinationPath'."
                $foldersMoved++
            } catch {
                Write-Warning "Error al mover la carpeta '$($folder.Name)': $($_.Exception.Message)"
            }
        }
        if ($foldersMoved -gt 0) {
            # Calcular espacio en disco después de mover las carpetas
            $disk = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq "$diskToCheck\" }
            if ($null -ne $disk) {
                $freeSpaceGB = ($disk.Free / 1GB)
                Write-Host "Successfully moved $foldersMoved folders."
                Write-Host "Espacio libre actual: $($freeSpaceGB.ToString('0.00')) GB."
            } else {
                Write-Warning "No se pudo calcular el espacio disponible. Verifique la letra del disco."
            }
        } else {
            Write-Host "No se movieron carpetas en esta ejecución."
        }
          # Cerrar PowerShell después de completar el movimiento
            Write-Host "Cerrando PowerShell..."
        Exit
    } else {
        Write-Host "No se encontraron carpetas en '$sourcePath'."
    }
}


while ($true) {
    try {
        $diskToCheck = "$diskToCheck`:" # Asegurar que el formato sea C:\
        $disk = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq "$diskToCheck\" }

        if ($null -ne $disk) {
            $freeSpaceGB = ($disk.Free / 1GB)
            $totalSpaceGB = ($disk.Used + $disk.Free) / 1GB
            $usedSpacePercent = (($totalSpaceGB - $freeSpaceGB) / $totalSpaceGB) * 100
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
