# Sous Vide Calculator

This is a web application providing a series of calculators based on Dr. Douglas Baldwin's "A Practical Guide to Sous Vide Cooking". The goal is to offer precise tools for sous vide enthusiasts to achieve perfect results.

## Technologies Used

*   **Elm**: A reliable language for building robust web applications.
*   **Tailwind CSS v4**: A utility-first CSS framework for rapid UI development.
*   **Vite**: A fast build tool for modern web projects.
*   **Nix / NixOS**: For a reproducible development environment, ensuring consistent dependencies and tooling.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   [Nix](https://nixos.org/download.html) (preferably NixOS or `nix-shell`/`nix develop` enabled)
*   [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) (though `flake.nix` provides these)

### Installation and Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/nilp0inter/sous-vide-calculator.git
    cd sous-vide-calculator
    ```

2.  **Enter the Development Environment:**
    If you have Nix installed, you can enter the reproducible development environment defined in `flake.nix`:
    ```bash
    nix develop
    ```
    This will provide all necessary tools like `elm`, `node`, `npm`, etc.

3.  **Install Node.js dependencies:**
    ```bash
    npm install
    ```

### Running the Development Server

To start the Vite development server with hot module replacement:

```bash
npm run dev
```

Open your browser to `http://localhost:5173` (or the address provided in your terminal) to see the application.

### Building for Production

To build the application for production:

```bash
npm run build
```

The compiled assets will be located in the `dist/` directory.

### Previewing the Production Build

You can serve the production build locally to test it:

```bash
npm run preview
```
---

## Calculators

The application implements mathematical models derived from Baldwin's research to provide the following tools:

### 1. The Pasteurization (Safety) Calculator
This is the most critical tool based on the document. It ensures the food has reached the required "log reduction" of pathogens like Salmonella, Listeria, and E. coli.

### 2. Heating Time Calculator (Thawed vs. Frozen)
A tool to help users know when the center of their food has actually reached the water bath temperature.

### 3. The Rapid Chilling (Cook-Chill) Calculator
Essential for users who meal-prep (cook-chill/freeze) to ensure they move through the "danger zone" safely to prevent the outgrowth of spores.

### 4. Brine & Marinade Ratio Tool
The guide provides specific percentages for different meats to improve water-holding capacity.

### 5. Doneness & Texture Visualizer
A simple reference tool to help users choose their temperature based on the desired final result.

### 6. Shelf-Life & Storage Timer
A calculator to determine how long a pasteurized, chilled pouch can stay in the fridge before it becomes unsafe due to non-proteolytic C. botulinum.

---

## Important Safety Limitations

* **Equipment Restriction**: These models are designed specifically for circulating water baths; they are **not** accurate for convection steam ovens, which do not heat uniformly enough.
* **Susceptible Populations**: Raw or unpasteurized food must never be served to highly susceptible or immune-compromised individuals.
* **Maximum Thickness**: Calculations assume the food is completely submerged and not overlapping in the water bath.

## Bibliography

Baldwin, D. E. (2014). *A Practical Guide to Sous Vide Cooking*. Retrieved from [douglasbaldwin.com](https://douglasbaldwin.com/sous-vide.html).

