$InputDir  = "C:\Users\hp\Input_glb" #change the path to your folder containing .glb files to be compressed
$OutputDir = "C:\Users\hp\Optimized_glb" #change the path where you want to save optimized .glb files
$TempDir   = Join-Path $env:TEMP "gltf_opt_temp"

# Create output and temporary directories if they don't exist
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

# Get all .glb files in the input directory
$Files = Get-ChildItem -Path $InputDir -Filter "*.glb"

if ($Files.Count -eq 0) {
    Write-Host "No .glb files found in $InputDir" -ForegroundColor Yellow
    exit
}

foreach ($File in $Files) {
    Write-Host "Processing: $($File.Name)..." -ForegroundColor Cyan

    $Step1 = Join-Path $TempDir "step1.glb"
    $Step2 = Join-Path $TempDir "step2.glb"
    $Step3 = Join-Path $TempDir "step3.glb"
    $Step4 = Join-Path $TempDir "step4.glb"
    $Step5 = Join-Path $TempDir "step5.glb"
    $Final = Join-Path $OutputDir "$($File.BaseName)_Safe.glb"

    # Run the 6 optimization steps sequentially
    npx --yes @gltf-transform/cli dedup "$($File.FullName)" "$Step1"
    npx --yes @gltf-transform/cli instance "$Step1" "$Step2"
    npx --yes @gltf-transform/cli prune "$Step2" "$Step3"
    npx --yes @gltf-transform/cli resize "$Step3" "$Step4" --width 1024 --height 1024
    npx --yes @gltf-transform/cli webp "$Step4" "$Step5"
    npx --yes @gltf-transform/cli draco "$Step5" "$Final"

    Write-Host "Saved to: $Final`n" -ForegroundColor Green
}

# Clean up intermediate temp files
Remove-Item -Recurse -Force $TempDir
Write-Host "Batch optimization complete!" -ForegroundColor Green
