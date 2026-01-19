# Sous Vide Calculator Project Context

## Project Overview

**Sous Vide Calculator** is a web application designed to provide precise cooking tools for sous vide enthusiasts, based on the scientific research of Dr. Douglas Baldwin. It aims to offer calculators for heating times, pasteurization, and food safety storage.

### Architecture & Tech Stack

*   **Language**: [Elm](https://elm-lang.org/) (0.19.1) - A functional language for reliable web apps.
*   **Styling**: [Tailwind CSS](https://tailwindcss.com/) (v4) - Utility-first CSS framework.
*   **Build Tool**: [Vite](https://vitejs.dev/) - Fast frontend build tool, integrated with `vite-plugin-elm`.
*   **Environment**: [Nix](https://nixos.org/) - Reproducible development environment defined in `flake.nix`.
*   **Deployment**: GitHub Pages (via GitHub Actions).

## Directory Structure

*   `src/`: Contains the application source code.
    *   `Main.elm`: The main entry point for the Elm application.
    *   `index.js`: The JavaScript entry point that initializes the Elm app.
    *   `style.css`: Tailwind CSS imports.
*   `dist/`: The production build output directory (generated).
*   `flake.nix`: Defines the Nix development shell with Elm and Node.js tools.
*   `elm.json`: Elm package configuration.
*   `package.json`: Node.js dependencies and scripts.
*   `vite.config.js`: Vite configuration, including the Elm plugin and base path.
*   `tailwind.config.js` & `postcss.config.js`: Tailwind CSS configuration.
*   `.github/workflows/deploy.yml`: CI/CD workflow for building and deploying to GitHub Pages.

## Development Workflow

### 1. Environment Setup
The project uses **Nix** to ensure a consistent environment.
```bash
nix develop
```
This shell provides `elm`, `elm-format`, `elm-test`, `node`, and `npm`.

### 2. Dependency Installation
After entering the Nix shell:
```bash
npm install
```

### 3. Running Locally
Start the Vite development server with hot module replacement (HMR):
```bash
npm run dev
```
The app will be accessible at `http://localhost:5173`.

### 4. Building for Production
To create a production build in the `dist/` folder:
```bash
npm run build
```

### 5. Previewing Production Build
To serve the production build locally:
```bash
npm run preview
```

## Key Commands & Scripts

| Command | Description |
| :--- | :--- |
| `npm run dev` | Starts the Vite development server. |
| `npm run build` | Builds the application for production. |
| `npm run preview` | Previews the production build locally. |
| `elm make` | Manually compiles Elm code (handled automatically by Vite). |
| `elm-format` | Formats Elm code. |

## Deployment

The project is configured to automatically deploy to **GitHub Pages** on push to the `main` branch.
*   **Workflow**: `.github/workflows/deploy.yml`
*   **Process**: Builds inside the Nix environment, then uploads the `dist` artifact to GitHub Pages.
*   **Base Path**: Configured in `vite.config.js` as `/sous-vide-calculator/`.

## Coding Conventions

*   **Elm**: Follow standard Elm architecture (Model-View-Update).
*   **Tailwind**: Use utility classes directly in Elm `Html.Attributes.class`.
*   **Formatting**: Use `elm-format` to maintain code style.

## Calculators

### 1. The Pasteurization (Safety) Calculator

This is the most critical tool based on the document. It ensures the food has reached the required "log reduction" of pathogens like Salmonella, Listeria, and E. coli.

*   **Inputs**: Protein Type (Beef/Pork/Lamb, Poultry, Lean Fish, Fatty Fish), Thickness (mm or inches), and Bath Temperature.
*   **Logic**: Uses data from Tables 3.1, 4.1, and 5.1.
*   **Output**: The minimum time required to achieve a 6D or 7D reduction in pathogens.
*   **Advanced Feature**: A "Safety Buffer" toggle that accounts for the note that acidified marinades may require doubling pasteurization times.

### 2. Heating Time Calculator (Thawed vs. Frozen)

A tool to help users know when the center of their food has actually reached the water bath temperature.

*   **Inputs**: Starting State (Frozen or Refrigerated), Thickness, Shape (Slab, Cylinder, Sphere), and Target Temperature.
*   **Logic**: Uses Tables 2.2 and 2.3.
*   **User Interface Note**: Since most users aren't mathematicians, you could use icons:
    *   Slab = Steak/Chops.
    *   Cylinder = Roulades/Sausages.
    *   Sphere = Meatballs/Stuffed Roasts.
*   **Output**: Time to reach within 1°F (0.5°C) of the water bath.

### 3. The Rapid Chilling (Cook-Chill) Calculator

Essential for users who meal-prep (cook-chill/freeze) to ensure they move through the "danger zone" safely to prevent the outgrowth of spores.

*   **Inputs**: Thickness and Shape.
*   **Logic**: Uses Table 1.1.
*   **Output**: Required time the sealed pouch must stay in an ice-water bath (at least half ice) to reach 41°F (5°C).

### 4. Brine & Marinade Ratio Tool

The guide provides specific percentages for different meats to improve water-holding capacity.

*   **Inputs**: Weight of Water/Liquid and Protein Type (e.g., Pork, Poultry, Brisket).
*   **Logic**:
    *   Pork/Poultry: 5–10% salt solution.
    *   Brisket: 4% salt and 3% sugar solution.
*   **Output**: Exact grams of salt and sugar needed.

### 5. Doneness & Texture Visualizer

A simple reference tool to help users choose their temperature based on the desired final result.

*   **Inputs**: Protein type.
*   **Logic**: Uses Table 2.1 and the "Effects of Heat on Meat" section.
*   **Output**:
    *   Recommended temperatures (e.g., 131°F for "Filet Mignon" texture in chuck roast).
    *   Visual descriptions (Rare, Medium-Rare, Medium).

### 6. Shelf-Life & Storage Timer

A calculator to determine how long a pasteurized, chilled pouch can stay in the fridge before it becomes unsafe due to non-proteolytic C. botulinum.

*   **Inputs**: Current Refrigerator Temperature.
*   **Logic**: Uses the four storage rules from the "Pathogens of Interest" section:
    *   Below 36.5°F (2.5°C) = 90 days.
    *   Below 38°F (3.3°C) = 31 days.
    *   Below 41°F (5°C) = 10 days.
    *   Below 44.5°F (7°C) = 5 days.
*   **Output**: Maximum storage duration.
