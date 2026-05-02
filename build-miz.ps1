#Requires -Version 5.0
<#
.SYNOPSIS
    Builds a .miz mission file from the LODP_DML folder with auto-incrementing version numbers.

.DESCRIPTION
    This script compresses the LODP_DML folder into a ZIP archive (renamed to .miz format).
    It automatically detects the latest version in the "Miz files" folder and increments
    the minor version number. The final .miz file is saved to the "Miz files" folder.
    
    Note: .miz files are ZIP archives. DCS requires ZIP compression, not RAR.

.EXAMPLE
    .\build-miz.ps1
    
    If latest version is LODP_DML_v1.0.miz, creates LODP_DML_v1.1.miz

.NOTES
    Requires: PowerShell 5.0+, .NET Framework with System.IO.Compression
    Location: Run from the LODP project root directory
#>

param(
    [string]$ProjectRoot = (Get-Location).Path
)

# Configuration
$MizFilesFolder = Join-Path $ProjectRoot "Miz files"
$LodpDmlFolder = Join-Path $ProjectRoot "LODP_DML"
$VersionPattern = "LODP_DML_v(\d+)\.(\d+)\.miz"

# Validate folders exist
if (-not (Test-Path $LodpDmlFolder)) {
    Write-Error "LODP_DML folder not found at: $LodpDmlFolder"
    exit 1
}

if (-not (Test-Path $MizFilesFolder)) {
    Write-Error "Miz files folder not found at: $MizFilesFolder"
    exit 1
}

Write-Host "Building LODP_DML.miz..." -ForegroundColor Cyan

# Find latest version
$VersionedMizFiles = Get-ChildItem -Path $MizFilesFolder -Filter "LODP_DML_v*.miz" | 
    Where-Object { $_.Name -match $VersionPattern }

$NextMajor = 1
$NextMinor = 0

if ($VersionedMizFiles) {
    # Parse existing versions
    $Versions = @()
    foreach ($File in $VersionedMizFiles) {
        if ($File.Name -match $VersionPattern) {
            $Major = [int]$matches[1]
            $Minor = [int]$matches[2]
            $Versions += @{ Major = $Major; Minor = $Minor; Name = $File.Name }
        }
    }
    
    # Find latest version
    $Latest = $Versions | Sort-Object -Property Major, Minor | Select-Object -Last 1
    $NextMajor = $Latest.Major
    $NextMinor = $Latest.Minor + 1
    
    Write-Host "Latest version found: $($Latest.Name)" -ForegroundColor Green
}

$NewVersionString = "v$NextMajor.$NextMinor"
$NewMizName = "LODP_DML_$NewVersionString.miz"
$NewMizPath = Join-Path $MizFilesFolder $NewMizName
$TempZipPath = Join-Path $MizFilesFolder "$NewMizName.tmp"

# Remove existing temp file if it exists
if (Test-Path $TempZipPath) {
    Remove-Item $TempZipPath -Force
}

# Create ZIP archive from LODP_DML folder
try {
    Write-Host "Compressing LODP_DML folder..." -ForegroundColor Yellow
    
    # Load the System.IO.Compression assembly
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    # Create ZIP file directly with files at root level
    # This preserves file integrity and DCS mission compatibility
    $zipArchive = [System.IO.Compression.ZipFile]::Open($TempZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    
    try {
        # Get all items from LODP_DML folder
        $rootItems = Get-ChildItem -Path $LodpDmlFolder -Force
        
        foreach ($item in $rootItems) {
            if ($item.PSIsContainer) {
                # Recursively add all files in subdirectories (like l10n/DEFAULT/)
                $subItems = Get-ChildItem -Path $item.FullName -Recurse -File -Force
                foreach ($file in $subItems) {
                    # Calculate relative path from LODP_DML folder
                    $relativePath = $file.FullName.Substring($LodpDmlFolder.Length + 1)
                    # Add file to ZIP
                    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $relativePath) | Out-Null
                }
            } else {
                # Add root-level files directly
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $item.FullName, $item.Name) | Out-Null
            }
        }
        
        Write-Host "ZIP created successfully with proper file structure" -ForegroundColor Green
    }
    finally {
        $zipArchive.Dispose()
    }
    
    # Rename to .miz
    if (Test-Path $NewMizPath) {
        Write-Host "Removing existing $NewMizName..." -ForegroundColor Yellow
        Remove-Item $NewMizPath -Force
    }
    
    Rename-Item -Path $TempZipPath -NewName $NewMizName -Force
    
    Write-Host ""
    Write-Host "DONE - Mission file created successfully!" -ForegroundColor Green
    Write-Host "  Version: $NewVersionString" -ForegroundColor Cyan
    Write-Host "  File: $NewMizPath" -ForegroundColor Cyan
    $MizSize = [math]::Round((Get-Item $NewMizPath).Length / 1MB, 2)
    Write-Host "  Size: $MizSize MB" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to create .miz file: $_"
    if (Test-Path $TempZipPath) {
        Remove-Item $TempZipPath -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
