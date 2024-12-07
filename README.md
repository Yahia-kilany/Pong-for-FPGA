# Pong Game for BASYS3 FPGA  

This project implements the classic Pong game on an FPGA using Verilog. The game features real-time paddle and ball mechanics, collision detection, scoring, and output to a VGA display.  

---

## Table of Contents  
- [Introduction](#introduction)  
- [Features](#features)  
- [Project Structure](#project-structure)  
- [Modules](#modules)  
- [How to Run](#how-to-run)  
- [Challenges Faced](#challenges-faced)  
- [Contributors](#contributors)  

---

## Introduction  

The Pong game is a retro arcade game where players control paddles to bounce a ball and prevent it from falling off the screen. This project demonstrates the implementation of a fully functional Pong game using Verilog, showcasing:  
- Real-time interaction with paddles and the ball.  
- Smooth graphical output via VGA.  
- Modular design for easy extensibility and debugging.  

---

## Features  

- **Real-Time Gameplay:** Smooth ball movement and paddle controls.  
- **Collision Detection:** Handles interactions between the ball, paddles, and walls.  
- **Scoring System:** Tracks and displays player scores in real time.  
- **VGA Output:** Visualizes the game on a 640x480 VGA display.  

---

## Project Structure  

```
/pong-game  
├── src  
│   ├── paddle.v              # Manages paddle movement and boundaries  
│   ├── ball.v                # Handles ball mechanics, including position and collision  
│   ├── score.v               # Tracks player scores  
│   ├── score_7seg.v          # Displays scores on a 7-segment display  
│   ├── color_mux.v           # Determines colors for ball, paddles, and background  
│   ├── vga_controller.v      # VGA controller for display synchronization  
│   ├── debouncer.v           # Debounces input buttons for reliable paddle control  
│   ├── top.v                 # Top-level module integrating all components  
├── constraints.xdc           # FPGA pin assignments for VGA, inputs, and display  
├── README.md                 # Project documentation  
```  

---

## Modules  

### 1. **Paddle Module (`paddle.v`)**  
Handles paddle movement based on user input and ensures paddles remain within screen boundaries.  

### 2. **Ball Module (`ball.v`)**  
Manages ball position, direction, and collision detection with paddles and walls. Updates ball velocity upon collision.  

### 3. **Score Module (`score.v`)**  
Tracks player scores based on ball position and updates the score when a player misses the ball.  

### 4. **Score Display Module (`score_7seg.v`)**  
Displays scores on a 7-segment display using multiplexing and decoding logic.  

### 5. **Color Mux Module (`color_mux.v`)**  
Assigns colors for each game element (ball, paddles, and background) for rendering on the VGA screen.  

### 6. **VGA Controller Module (`vga_controller.v`)**  
Generates synchronization signals for the VGA display and tracks pixel positions.  

### 7. **Debouncer Module (`debouncer.v`)**  
Ensures reliable input by removing noise from button presses.  

### 8. **Top-Level Module (`top.v`)**  
Integrates all game components, including ball, paddles, VGA, scoring, and input handling.  

---

## How to Run  

1. **Set Up Environment:**  
   - Use a Verilog simulator (e.g., Vivado) for simulation and synthesis.  
   - Connect the FPGA board (e.g., Basys 3) for physical testing.  

2. **Simulation:**  
   - Run simulations for individual modules to verify functionality.  

3. **Synthesize and Program:**  
   - Synthesize the Verilog code in your FPGA toolchain.  
   - Program the bitstream onto the FPGA.  

4. **Play the Game:**  
   - Use buttons to control paddles and play Pong on a VGA-connected display.  

---

## Challenges Faced  

- **Collision Detection:** Left paddle collision was initially buggy due to a simple logic error, allowing the ball to pass through. This was resolved by refining the collision algorithm.  
- **Scoring System:** Early versions failed to update scores correctly. Boundary detection logic was improved to ensure accurate scoring.  
- **Ball Appearance:** The ball was initially square. A circle was implemented to improve realism.  

---



## Contributors  

- **Yahia Kilany**  
- **Mahmoud Refaie**  
- **Seifeldin Elwan**  

---

