# Particle Visualizer

A physics-based particle simulation built with LÖVE2D (Love2D) and Lua. Particles interact with each other and respond to mouse movements with colorful trails, sparks, and glowing effects.

![Particle Visualizer Demo](assets/demo.mp4)

## Features

- Dynamic particle physics simulation
- Particle-to-particle collisions with blended color effects
- Mouse-based force field interaction
- Particle trails and glow effects
- Collision sparks with color blending
- Tokyo Night-inspired color palette

## Requirements

- [LÖVE2D](https://love2d.org/) (version 11.4 or later)

## Installation

1. Install LÖVE2D from https://love2d.org/ or
2. Clone this repository:

```bash
git clone https://github.com/griffinbaker12/particle-viz.git
```

## Running the Project

Navigate to the project directory and run:

```bash
love .
```

## Controls

- Move your mouse around the screen to create a force field
- Particles will interact with the force field and each other
- Watch the colorful collisions and trails!

## Project Structure

```
particle-viz/
├── main.lua           # Entry point and game loop
├── src/
│   ├── constants.lua  # Configuration and constants
│   └── particle.lua   # Particle physics and rendering
├── demo.gif           # Demo animation
└── README.md
```

## Physics Features

- Elastic collisions between particles
- Gravity simulation
- Ground friction
- Wall bouncing with energy loss
- Velocity capping to maintain stability
- Force field repulsion

## Visual Effects

- Particle trails with fade-out
- Dynamic glow based on particle energy
- Spark effects on collision
- Color blending based on collision dynamics
- Additive blending for light effects

## Credits

- Built with [LÖVE2D](https://love2d.org/)
- Color palette inspired by Tokyo Night theme
