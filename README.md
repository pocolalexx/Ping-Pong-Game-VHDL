# LED Ping-Pong Game on FPGA (VHDL)

This repository contains the complete **AMD Vivado project** and VHDL source files for a hardware-based LED Ping-Pong game implemented on an FPGA development board (e.g., Digilent Basys 3 or similar Xilinx-based boards).

---

### 🎮 Game Dynamics & Rules
The project implements a fast-paced electronic tennis game using the board's physical I/O peripherals:
* **The "Ball" Movement:** The ball is represented by a single active light shifting across the 16 onboard LEDs (`led(15)` down to `led(0)`).
* **Controls:** 
  * `btnL` controls the left paddle (active when the ball is at `pozitie = 15`).
  * `btnR` controls the right paddle (active when the ball is at `pozitie = 0`).
  * `btnC` acts as a global synchronous reset to restart the game and clear the scores.
* **Serving:** When a point is scored, the ball resets to the respective side, and the corresponding LED blinks rapidly until the player serves by pressing their button.
* **Win Condition (With Advantage):** The first player to reach **11 points** wins the match. However, a player must win by a margin of at least **2 points** (Deuce logic).

---

### ⚙️ Hardware Architecture & Implementation Details

The core system architecture (`PingPongGame.vhd`) relies on synchronous, modular hardware blocks:

#### 1. Finite State Machine (FSM)
The core control unit is modeled using an explicit 5-state FSM (`stari_joc`):
* `asteapta_l` / `asteapta_r`: Idle states awaiting a player serve.
* `la_dreapta` / `la_stanga`: Active gameplay states where the ball position index shifts step-by-step.
* `final_joc`: Match-over state reached when winning conditions are met. All 16 LEDs flash simultaneously in this state.

#### 2. Clock Management & Signal Generation
A main 26-bit synchronous counter (`numara_clk`) divides the onboard master clock (100 MHz):
* `clk_joc <= numara_clk(22)` dictates the shifting speed of the ball.
* `mux_cnt <= numara_clk(18 downto 17)` sets the optimal frequency for 7-segment display digit refreshing to avoid visual flickering.

#### 3. Mathematical Advantage Logic
The point-scoring mechanism evaluates score bounds on the fly. To secure a win, the VHDL process dynamically verifies that the leading player has scored at least 11 points and has achieved a 2-point lead:
$$\text{puncte\_l} \ge 10 \quad \text{AND} \quad (\text{puncte\_l} + 1 - \text{puncte\_r} \ge 2)$$

#### 4. Time-Multiplexed 7-Segment Display Driver
The score for both players is rendered simultaneously on the 4-digit common-anode display:
* **Left Digits:** Display tens and units of `puncte_l` using rapid multiplexing cycles (`00` and `01`).
* **Right Digits:** Display tens and units of `puncte_r` using cycles (`10` and `11`).
* An external structural component, `Dec_7seg`, is instantiated and mapped via ports to decode the integer digits into 7-bit segment configurations (`seg`).

---
*Developed as part of the Digital Circuits / Digital Systems Engineering curriculum at the Technical University of Cluj-Napoca (UTCN).*
