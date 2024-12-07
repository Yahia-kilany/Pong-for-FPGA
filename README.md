# Pong Game for FPGA  

This project implements the classic Pong game on an FPGA using Verilog. The game features real-time paddle and ball mechanics, collision detection, scoring, and output to a VGA display.  

---

## Table of Contents  
- [Introduction](#introduction)  
- [Features](#features)  
- [Project Structure](#project-structure)  
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
├── Paddle.v                # Manages paddle movement and boundaries  
├── RisingEdgeDetector.v    # Detects rising edges in inputs for synchronizing events  
├── Score.v                 # Tracks player scores  
├── Score_text.v            # Displays textual scores  
├── Sound.v                 # Adds sound for collisions (in progress)  
├── Top2.v                  # Top-level module integrating all components  
├── ascii_rom.v             # ASCII font data for rendering text  
├── ball.v                  # Handles ball mechanics and collisions  
├── clk_div_7_seg.v         # Clock divider for 7-segment display multiplexing  
├── color_mux.v             # Determines colors for game elements on the VGA display  
├── const_pong.xdc          # Constraints file for FPGA pin mapping  
├── debouncer.v             # Debounces button inputs for reliable operation  
├── decode.v                # Decodes signals for specific functionalities  
├── score_7seg.v            # Displays scores on a 7-segment display  
├── vga_controller.v        # VGA controller for display synchronization  
```

---


## How to Run  

1. **Set Up Environment:**  
   - Use a Verilog simulator (e.g., Vivado) for simulation and synthesis.  
   - Connect the FPGA board (e.g., Basys 3) for physical testing.  

2. **Simulation:**  
   - Simulate each module independently to verify functionality.  

3. **Synthesize and Program:**  
   - Synthesize the Verilog code in your FPGA toolchain.  
   - Program the bitstream onto the FPGA.  

4. **Play the Game:**  
   - Use the buttons to control the paddles and enjoy Pong on a VGA-connected display.  

---

## Challenges Faced  

- **Collision Detection:** Initially, paddle collision was buggy, allowing the ball to pass through. Fixed by refining logic.  
- **VGA Synchronization:** Early issues with screen flickering were resolved by improving timing constraints.  
- **Score Display:** Integrating ASCII text with the VGA was challenging but successful using the `ascii_rom`.  

---

## Contributors  

- **Yahia Kilany**  
- **Mahmoud Refaie**  
- **Seifeldin Elwan**  

---

