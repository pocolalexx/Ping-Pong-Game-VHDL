# LED Ping-Pong Game on FPGA (VHDL)

This repository contains the complete **Vivado project** (`.xpr`) and VHDL source files for a hardware-based LED Ping-Pong game implemented on an AMD/Xilinx FPGA development board.

### 🎮 Game Dynamics & Rules
The project implements a fast-paced electronic tennis game using the board's physical I/O:
* **The "Ball" Movement:** The ball is represented by a shifting light across the onboard LEDs (`LED15` to `LED0`). 
* **Controls:** Player 1 uses `btnL` to launch and hit the ball from `LED15`. Player 2 must precisely press `btnR` exactly when the light reaches `LED0` to reverse its direction.
* **Miss Conditions:** If a player misses the timing window, all LEDs light up for 1 second as a visual penalty, the opponent scores a point, and a new round automatically resets.

### ⚙️ Hardware Logic & Features
The core system architecture relies on modular, synchronous VHDL blocks:
* **Finite State Machine (FSM) with Deuce Logic:** Manages the game states (*Idle/Reset, Active Play, Miss Delay, and Game Over*). The winning condition is set to **11 points**, but it dynamically incorporates a **two-point advantage rule (Deuce)**. A player cannot win at 11-10; the hardware continuously checks that $Score_1 \ge 11$ or $Score_2 \ge 11$ alongside $|Score_1 - Score_2| \ge 2$.
* **Clock Dividers & Debouncers:** Step down the high-frequency system clock to control the LED shifting speed and cleanly debounce the mechanical button inputs (`btnL` / `btnR`).
* **Seven-Segment Display Driver:** Time-multiplexes the digital outputs to render both players' scores in real-time on the board's 7-segment display digits.

---
*Developed as part of the Digital Circuits curriculum at the Technical University of Cluj-Napoca.*
