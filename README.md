# Sudoku
ARM Assembly language program which determines whether a Sudoku grid in memory can be solved, and solves it if possible.

NOTE: This .s file may require additional files to be built into an executable. It was designed to work inside a simulation environment of Keil uVision. The usage and known limitations below are from testing within that environment.

USAGE:
- Build and run the program.
- After exectution, R0 will hold #1 if the Sudoku grid was solvable and #0 otherwise.
- If the grid was solveable, the area in memory holding the grid will now contain a solved Sudoku grid.

KNOWN LIMITATIONS:
- Assumes that all memory addresses used in the program are valid and contain valid values.
