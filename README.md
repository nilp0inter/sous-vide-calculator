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

## Project Goals & Calculator Logic

The application implements mathematical models derived from Baldwin's research to provide the following features:

### 1. Heating & Pasteurization

* **Heating Time-to-Temperature**: Calculates the time required for the coldest part of the food to reach 1°F (0.5°C) less than the water bath temperature.
* **Safety Pasteurization**: Determines the minimum hold time required to reduce pathogens (*Listeria*, *Salmonella*, and *E. coli*) to safe levels based on protein type.
* **Thawed vs. Frozen**: Separate logic for starting temperatures of 41°F (5°C) or 0°F (-18°C).

### 2. Geometric & Thermal Accuracy

* **Shape Factors**: The calculator accounts for different heating rates based on whether the food is shaped as a **Slab** (e.g., steak), a **Cylinder** (e.g., roulade), or a **Sphere** (e.g., meatball).
* **Thermal Diffusivity**: Uses conservative thermal diffusivity values () specific to meat, poultry, and fish to ensure a wide safety margin.

### 3. Safety & Storage

* **Rapid Chilling**: Provides exact timing for chilling sealed pouches in an ice-water bath to reach 41°F (5°C) safely.
* **Storage Calculator**: Estimates shelf-life based on refrigeration temperature (e.g., 10 days at 41°F vs. 31 days at 38°F) to prevent the production of toxins from *Clostridium botulinum*.

---

## Important Safety Limitations

* **Equipment Restriction**: These models are designed specifically for circulating water baths; they are **not** accurate for convection steam ovens, which do not heat uniformly enough.
* **Susceptible Populations**: Raw or unpasteurized food must never be served to highly susceptible or immune-compromised individuals.
* **Maximum Thickness**: Calculations assume the food is completely submerged and not overlapping in the water bath.

## Bibliography

Baldwin, D. E. (2014). *A Practical Guide to Sous Vide Cooking*. Retrieved from [douglasbaldwin.com](https://douglasbaldwin.com/sous-vide.html).

