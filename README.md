# Soft Bridge Solutions Corporate Accounting Platform - Technical Documentation

This repository contains the source code for the high-end, multi-page corporate accounting platform designed under the Soft Bridge Solutions brand. The system is built entirely using SwiftUI, coordinating low-overhead layouts with a clean, vector-driven visual engine.

---
## Walkthrough Demonstration Video

Below is the screen recording capturing the application execution, including biometrics authorization, transaction approval, ledger search filters, share sheet export, interactive chart dragging, and document upload scanning.



https://github.com/user-attachments/assets/cdf428ed-2f7d-44ad-aafc-470b7ff84e08



---
## System Architecture

The application is structured around a centralized state manager, separating database properties, calculations, and animations from the rendering layers. 

### Core Components Directory Hierarchy

- **Theme** (Theme.swift): Houses linear gradients, custom shadows, and view extensions that handle navigation hiding and conditional sensory feedback triggers.
- **CommonComponents** (CommonComponents.swift): Houses scalable UI containers, status capsule badges, and vendor initials avatar creators.
- **Models** (Models.swift): Structs declaring the type safe schema of the ledger data, KPIs, chart data points, and document files.
- **AppState** (AppState.swift): The dynamic data controller. Publishes calculations, ledger filtering states, and triggers biometric checks.
- **Views**: Main page classes representing bottom tab view layers:
  - **DashboardView.swift**: Displays overview panels, authorization modules, and concentric capacity rings.
  - **TransactionsView.swift**: Controls high-density list items, search querying, detail sheets, and ShareLink exporters.
  - **AnalyticsView.swift**: Handles line graph canvases, drag Snapping highlights, budget ratios, and donut charts.
  - **VaultView.swift**: Handles directories, scanning timelines, and receipt preview drawers.
- **ContentView** (ContentView.swift): Configures global TabView settings and instantiates the shared state.

---

## Technical Feature Breakdown

### 1. Biometric Security Layer (Face ID Integration)
To restrict database access, a full-screen glassmorphic overlay locks the dashboard at launch. 
- **Mechanism**: The block conditionally presents when `AppState.isBiometricallyLocked` is true.
- **Interactions**: Tapping the unlock button rotates the biometric image icon via continuous rotation transitions and scales it outwards. A timer simulates verification, toggles the success haptic state, and hides the overlay using a spring animation (`Theme.bouncySpring`).
- **Performance**: The blur effects are rendered using standard system compositing filters, ensuring zero frame rate drops on multi-core GPU targets.

### 2. Concentric Liquidity Runway Widgets
Displays operating burn rate capacities compared to allocated safety runway metrics.
- **Graphics**: Built using nested circles with custom stroke parameters.
- **Animations**: The trim properties bind to dynamic model states. When transactions are approved, burn rates fluctuate, updating ring trim fractions using smooth spring transitions.

### 3. High-Density Transactions Ledger
The ledger list is designed for rapid audit check scanning and data export.
- **Category Colors**: Every row is bound to a 5px vertical rectangle tag filled with category linear gradients:
  - Revenue: Emerald Green Gradient
  - SaaS: Indigo Blue Gradient
  - Operations: Purple Gradient
  - Marketing: Orange Gradient
- **CSV Data Exporter**: An integrated ShareLink button invokes `AppState.generateLedgerCSV()`, which parses the filtered array into a comma-separated text file natively.
- **Detail Sheets**: Rows support gesture triggers that present a slide-sheet with metadata and a step-by-step compliance timeline audit log.

### 4. Interactive Insights Canvas
Provides visual cash flow tracking and expense proportions.
- **Donut Chart**: Drawn using custom angular paths (`DonutSliceShape`). Selecting a slice triggers scale transformation offsets and updates the centered totals readouts.
- **Interactive Line Chart**: Uses custom canvas grids and vector lines. The line is styled using the custom `.glow()` extension. It supports a DragGesture; dragging a finger across the grid maps the X-coordinate to the nearest month index, showing snapped highlights and tooltips.

### 5. Document Vault and OCR Scanner
A folder-based directory showing receipt files and tax agreements.
- **Gradients Folders**: Active folder selections display full-gradient backdrops. Inactive folders show gradient folder symbols to direct contrast hierarchy.
- **Linear Scanline Animation**: Selecting files triggers a progress bar and scanning line. The scanner laser is represented by a linear gradient rectangle. When active, it slides vertically via linear offsets. The animation runs on the GPU, avoiding CPU rendering overhead.

---




   ```bash
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl launch booted Business.Muhasebe
   ```

# Softbridge-Accountancy-Mobile-App
