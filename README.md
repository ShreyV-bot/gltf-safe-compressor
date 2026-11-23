# Non-Destructive GLTF/GLB Compression Pipeline

This guide outlines a step-by-step pipeline to drastically compress `.glb` 3D models for the web (Three.js / WebGL) without destroying object hierarchies, removing parenting, or breaking animations. 

By avoiding the all-in-one `optimize` macro, this workflow manually chains geometry and texture compression while keeping your scene graph intact.

## Prerequisites

To run these commands, you must have **Node.js** and **npm** (Node Package Manager) installed on your system. 

The pipeline uses `npx` to automatically fetch and execute the `@gltf-transform/cli` package, so no manual global installation of the CLI is required as long as npm is available.

### How to check if prerequisites are satisfied
Open your terminal (PowerShell, Command Prompt, or Bash) and run:
```bash
node -v
npm -v
```
If both commands return a version number (e.g., `v18.16.0`), you are ready to proceed.

### How to satisfy prerequisites (If not installed)
If the commands above return an error (like "command not found"):
1. Go to the official Node.js website: [https://nodejs.org/](https://nodejs.org/)
2. Download and install the **LTS (Long Term Support)** version for your operating system.
3. Restart your terminal and run the version check commands again.

---

## Method 1: Manual Single-File Compression (CLI)

Use this method when you want to compress a single `.glb` file step-by-step on Windows, macOS, or Linux. Run these commands sequentially in your terminal from the directory containing your source `.glb` file (named `Target.glb` in this example).

### Step 1: Dedup
Removes duplicate vertices, textures, and accessors to clean up redundant data.
```bash
npx @gltf-transform/cli dedup Target.glb step1.glb
```

### Step 2: Instance
Creates GPU instances for repeated meshes (e.g., identical chairs or lights). This significantly reduces draw calls in Three.js.
```bash
npx @gltf-transform/cli instance step1.glb step2.glb
```

### Step 3: Prune
Cleans up the file by removing unused properties, orphaned nodes, and unreferenced materials.
```bash
npx @gltf-transform/cli prune step2.glb step3.glb
```

### Step 4: Resize Textures
Scales all heavy textures down to a maximum resolution of 1024x1024. *(Note: You can change `--width` and `--height` to 2048 if you need higher texture fidelity).*
```bash
npx @gltf-transform/cli resize step3.glb step4.glb --width 1024 --height 1024
```

### Step 5: WebP Compression
Re-encodes the resized textures into the highly compressed WebP format, which is universally supported in modern web browsers.
```bash
npx @gltf-transform/cli webp step4.glb step5.glb
```

### Step 6: Draco Geometry Compression
Applies Draco compression to the 3D geometry (vertices, normals, etc.). 
```bash
npx @gltf-transform/cli draco step5.glb Target_Safe.glb
```

### Cleanup
Once the pipeline is complete, test `Target_Safe.glb` in your Three.js environment or a [glTF Viewer](https://gltf-viewer.donmccurdy.com/) to verify the hierarchy and textures.

After verifying, delete the temporary step files:
```bash
# On Windows (PowerShell)
Remove-Item step1.glb, step2.glb, step3.glb, step4.glb, step5.glb

# On Mac/Linux (Bash)
rm step1.glb step2.glb step3.glb step4.glb step5.glb
```

---

## Method 2: Automated Batch Compression (Windows PowerShell)

Use the included `optimize_glb.ps1` script to automatically run all 6 compression steps across an entire folder of `.glb` files at once.

### 1. Clone or Download the Repository
```bash
git clone [https://github.com/ShreyV-bot/gltf-safe-compressor.git](https://github.com/ShreyV-bot/gltf-safe-compressor.git)
cd gltf-safe-compressor
```

### 2. Configure Your Folder Paths
Open `optimize_glb.ps1` in any text editor and update lines 1 and 2 to point to your input and output directories:
```powershell
$InputDir  = "C:\Users\hp\Input_glb"      # Path to your folder containing .glb files to be compressed
$OutputDir = "C:\Users\hp\Optimized_glb"  # Path where you want to save optimized .glb files
```

### 3. Run the Script
Open **PowerShell** in the repository directory and execute:
```powershell
.\optimize_glb.ps1
```
*(Note: If Windows blocks script execution due to execution policies, run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` first, then run `.\optimize_glb.ps1`).*

### What the Script Does Automatically
* **Batch Processes All `.glb` Files:** Loops through every `.glb` file in `$InputDir` and applies all 6 optimization steps (`dedup` -> `instance` -> `prune` -> `resize` -> `webp` -> `draco`). * **Preserves Originals:** Saves compressed models to `$OutputDir` with `_Safe.glb` appended to each filename (e.g., `Model_Safe.glb`).
* **Auto-Cleanup:** Stores intermediate files (`step1.glb` - `step5.glb`) inside your Windows `%TEMP%` directory and automatically deletes them when the batch finishes.

---

## Verification

Test your resulting `*_Safe.glb` files in your Three.js scene or drag and drop them into the [glTF Viewer](https://gltf-viewer.donmccurdy.com/) to verify that meshes, animations, materials, and scene hierarchy remain intact.

## License
This project is licensed under the MIT License.
