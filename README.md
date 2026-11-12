# Non-Destructive GLTF/GLB Compression Pipeline

This guide outlines a step-by-step pipeline to drastically compress `.glb` 3D models for the web (Three.js / WebGL) without destroying object hierarchies, removing parenting, or breaking animations. 

By avoiding the all-in-one `optimize` macro, this workflow manually chains geometry and texture compression while keeping your scene graph intact.

## 📋 Prerequisites

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

## The Compression Pipeline

Run these commands sequentially in your terminal from the directory containing your source `.glb` file. In this example, the source file is named `Target.glb`.

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

---

## Cleanup

Once the pipeline is complete, test `Target_Safe.glb` in your Three.js environment or a [glTF Viewer](https://gltf-viewer.donmccurdy.com/) to verify the hierarchy and textures. 

After verifying, delete the temporary step files:
```bash
# On Windows (PowerShell)
Remove-Item step1.glb, step2.glb, step3.glb, step4.glb, step5.glb

# On Mac/Linux (Bash)
rm step1.glb step2.glb step3.glb step4.glb step5.glb
```

## 📄 License
This project is licensed under the MIT License.
