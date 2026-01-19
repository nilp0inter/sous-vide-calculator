## 1. The Pasteurization (Safety) Calculator

This is the most critical tool based on the document. It ensures the food has reached the required "log reduction" of pathogens like *Salmonella*, *Listeria*, and *E. coli*.

* **Inputs:** Protein Type (Beef/Pork/Lamb, Poultry, Lean Fish, Fatty Fish), Thickness (mm or inches), and Bath Temperature.
* **Logic:** Uses data from **Tables 3.1, 4.1, and 5.1**.
* **Output:** The minimum time required to achieve a 6D or 7D reduction in pathogens.
* **Advanced Feature:** A "Safety Buffer" toggle that accounts for the note that acidified marinades may require doubling pasteurization times.

## 2. Heating Time Calculator (Thawed vs. Frozen)

A tool to help users know when the center of their food has actually reached the water bath temperature.

* **Inputs:** Starting State (Frozen or Refrigerated), Thickness, Shape (Slab, Cylinder, Sphere), and Target Temperature.
* **Logic:** Uses **Tables 2.2 and 2.3**.
* **User Interface Note:** Since most users aren't mathematicians, you could use icons:
* **Slab** = Steak/Chops.
* **Cylinder** = Roulades/Sausages.
* **Sphere** = Meatballs/Stuffed Roasts.


* **Output:** Time to reach within 1°F (0.5°C) of the water bath.

## 3. The Rapid Chilling (Cook-Chill) Calculator

Essential for users who meal-prep (cook-chill/freeze) to ensure they move through the "danger zone" safely to prevent the outgrowth of spores.

* **Inputs:** Thickness and Shape.
* **Logic:** Uses **Table 1.1**.
* **Output:** Required time the sealed pouch must stay in an ice-water bath (at least half ice) to reach 41°F (5°C).

## 4. Brine & Marinade Ratio Tool

The guide provides specific percentages for different meats to improve water-holding capacity.

* **Inputs:** Weight of Water/Liquid and Protein Type (e.g., Pork, Poultry, Brisket).
* **Logic:** * **Pork/Poultry:** 5–10% salt solution.
* **Brisket:** 4% salt and 3% sugar solution.


* **Output:** Exact grams of salt and sugar needed.

## 5. Doneness & Texture Visualizer

A simple reference tool to help users choose their temperature based on the desired final result.

* **Inputs:** Protein type.
* **Logic:** Uses **Table 2.1** and the "Effects of Heat on Meat" section.
* **Output:** * Recommended temperatures (e.g., 131°F for "Filet Mignon" texture in chuck roast).
* Visual descriptions (Rare, Medium-Rare, Medium).



## 6. Shelf-Life & Storage Timer

A calculator to determine how long a pasteurized, chilled pouch can stay in the fridge before it becomes unsafe due to non-proteolytic *C. botulinum*.

* **Inputs:** Current Refrigerator Temperature.
* **Logic:** Uses the four storage rules from the "Pathogens of Interest" section:
* Below 36.5°F (2.5°C) = 90 days.
* Below 38°F (3.3°C) = 31 days.
* Below 41°F (5°C) = 10 days.
* Below 44.5°F (7°C) = 5 days.


* **Output:** Maximum storage duration.

