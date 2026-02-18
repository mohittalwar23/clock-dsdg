# Smart Alarm Clock

(Digital System Design using Verilog HDL on DE10-Lite FPGA)

## Project Description

This module describes a clock application implemented on Altera's DE10-Lite FPGA Development Board using Verilog HDL.

## How to Run the Design

Follow these steps to program and run the project:

1. Download all project files.
2. Open Quartus Prime Software.
3. Create a new project targeting Altera DE10-Lite FPGA.
4. Set Timer.v as the Top-Level Module.
5. Compile the design using the Quartus Compile tool.
6. Go to Tools → Programmer.
7. Program the DE10-Lite board.

## Functional Modes

### 1. Select Mode
Used to set the initial time.

- Switches 5–0 → Enter time
- Switch 7 → Lock time for Clock mode
- Switch 6 → Lock time for Countdown mode
- KEY0 → Select number
- KEY1 → Reset selection

### 2. Clock Mode
Displays the current time.

- KEY0 → Pause
- KEY1 → Reset

### 3. Countdown Mode
Counts down from the selected time.

- KEY0 → Pause
- KEY1 → Reset
- Alarm triggers when time reaches zero

### 4. Stopwatch Mode
Measures elapsed time and records lap times.

- Switch 5 → Start / Pause
- KEY0 → Record lap
- KEY1 → Reset
- Switches 4–0 → Display lap records

## More Details : https://drive.google.com/file/d/1K4I-1q-xs_Zl7NmLLGtMxRVPoeUryLts/view

