# Swarm Intelligence Lab

> **Explore Collective Intelligence. Simulate Swarms. Optimize Solutions.**

**Small Agents. Collective Intelligence. Better Solutions.**

*Swarm Intelligence Lab* is a comprehensive, offline computational intelligence laboratory and interactive optimization simulator built using Flutter and Dart (Material 3). The application models and visualizes how groups of decentralized, relatively simple agents collectively solve complex mathematical and routing problems through local interactions, stigmergy, shared memory, and natural emergent behavior.

Designed specifically for engineering college projects, practical viva demonstrations, and academic presentations.

---

## 🌟 Key Highlights

- **100% Client-Side & Offline**: No backend, no Firebase, no cloud APIs, no database, and no mandatory internet connection. All computations execute on device in pure Dart.
- **Genuine Mathematical Algorithms**:
  - **Ant Colony Optimization (ACO)**:
    - *Traveling Salesman Problem (TSP)*: Probabilistic transition selection over real geographical coordinates (Mumbai, Pune, Nashik, Surat, Goa, Nagpur, Ahmedabad, Aurangabad) with evaporation and pheromone deposits.
    - *2D Grid Pathfinding*: Feasible obstacle avoidance on interactive grid maps with interactive obstacle placement.
  - **Particle Swarm Optimization (PSO)**: Continuous 2D mathematical optimization on benchmark functions (Sphere, Rastrigin, Rosenbrock) using standard velocity equations with inertia, cognitive, and social memory.
  - **Artificial Bee Colony (ABC)**: Complete 3-phase biological model with Employed Bee neighbor mutations, Onlooker Bee waggle-dance probabilistic recruitment, and Scout Bee abandonment replacements.
- **Scientific Visualization Engine**: Custom Flutter `CustomPainter` implementations rendering real-time 2D function landscapes, velocity arrows, pheromone heatmaps, ant circuits, and interactive convergence charts.
- **Dedicated Modes**:
  - **Interactive Swarm Simulator**: Full playback controls (Start, Pause, Resume, Step, Reset, Speed), live metrics, parameter sliders.
  - **Presentation Mode**: Step-by-step viva demo with auto-play animation and mathematical breakdowns for viva examiners.
  - **Experiment Mode**: Controlled laboratory with reproducible random seeds, evaluation budgets, delta improvement calculations, and JSON telemetry export.
  - **Algorithm Comparison**: Side-by-side benchmarking of PSO vs ABC with identical seeds and evaluation budgets.
- **Comprehensive Educational Content**:
  - **21 In-Depth Topics**: Definitions, plain-English explanations, formulas, and connections to the app.
  - **12 Real-World Case Studies**: Robotics, logistics, smart power grids, AGV routing, and neural network hyperparameter tuning.
  - **Advantages & Limitations**: In-depth analysis of algorithmic trade-offs, causes, effects, and engineering mitigations.

---

## 🎨 Color Palette & Design System

Built with a modern scientific laboratory aesthetic:

| Token | Hex Code | Purpose |
|---|---|---|
| **Primary Navy** | `#002350` | Primary brand accent and light-mode headers |
| **Gold** | `#D2AE39` | Optimum markers, best solutions, highlights |
| **Blue** | `#1769AA` | PSO accents, secondary series, interactive controls |
| **Green** | `#2E8B57` | ABC accents, successes, start markers |
| **Dark Background** | `#0B1220` | High-contrast scientific laboratory background |
| **Dark Surface** | `#111C2E` | Elevated panels and toolbars |
| **Light Background** | `#F5F7FA` | Clean day mode canvas |
| **Main Text** | `#172033` | Primary typography |

---

## 📂 Project Architecture

```
lib/
├── main.dart                               # Application entrypoint & navigation shell
├── core/
│   ├── constants/
│   │   └── app_colors.dart                 # Color palette specifications
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 light & dark themes
│   └── utils/
│       ├── formatters.dart                 # Number, duration, and metric formatting
│       └── random_provider.dart            # Seedable deterministic random provider
├── models/
│   ├── algorithm_type.dart                 # ACO, PSO, ABC enums & properties
│   ├── application_model.dart              # 12 real-world application models
│   ├── benchmark_function.dart             # Sphere, Rastrigin, Rosenbrock formulas
│   ├── city.dart                           # Geographical TSP cities (Haversine distance)
│   ├── comparison_result.dart              # Side-by-side benchmark models
│   ├── food_source_state.dart              # ABC food source & fitness state
│   ├── learning_topic.dart                 # 21 educational learning topic structures
│   ├── particle_state.dart                 # PSO particle vectors & memories
│   ├── presentation_step.dart              # Viva presentation step models
│   ├── route_solution.dart                 # ACO TSP tour models
│   └── simulation_metric_point.dart        # Real-time convergence chart data points
├── algorithms/
│   ├── aco/
│   │   ├── aco_grid_solver.dart            # 2D Grid pathfinding ACO solver
│   │   ├── aco_tsp_solver.dart             # Traveling Salesman Problem ACO solver
│   │   └── pheromone_matrix.dart           # Stigmergic pheromone matrix operations
│   ├── pso/
│   │   └── pso_solver.dart                 # Continuous Particle Swarm Optimizer
│   └── abc/
│       └── abc_solver.dart                 # Artificial Bee Colony 3-phase optimizer
├── problems/
│   ├── grid_environment.dart              # 2D grid matrix with obstacles
│   └── tsp_cities.dart                     # 8 Indian cities coordinates & distance matrix
├── services/
│   ├── settings_service.dart               # Theme and preference state with SharedPreferences
│   └── simulation_controller.dart          # Central simulation execution engine
├── screens/
│   ├── home_screen.dart                    # Hero dashboard, workflow & quick launch
│   ├── simulator_screen.dart               # Main interactive simulation workbench
│   ├── algorithms_screen.dart              # Algorithm math breakdowns & PSO vs ABC benchmarking
│   ├── learn_screen.dart                   # 21 searchable educational topics
│   ├── applications_screen.dart            # 12 real-world industrial case studies
│   ├── analytics_screen.dart               # Telemetry dashboard & JSON exporter
│   ├── experiment_screen.dart              # Controlled experiment lab with delta metrics
│   ├── presentation_screen.dart            # Step-by-step viva presentation mode
│   ├── how_it_works_screen.dart            # Complete 10-stage execution pipeline
│   ├── advantages_limitations_screen.dart  # Detailed pros, cons & mitigations
│   └── settings_screen.dart                # Laboratory settings & project info
└── widgets/
    ├── common/
    │   ├── custom_card.dart                # Styled container card
    │   ├── metric_badge.dart               # Key performance indicator badge
    │   └── responsive_scaffold.dart        # Mobile bottom bar, tablet rail, desktop sidebar
    └── simulation/
        ├── abc_landscape_canvas.dart       # Honeycomb & scout replacement custom painter
        ├── convergence_chart.dart          # Real-time multi-series chart with scrubber
        ├── grid_canvas.dart                # Interactive grid with obstacle toggling
        ├── parameter_slider.dart           # Formula symbol parameter sliders
        ├── pso_landscape_canvas.dart       # 2D contour & velocity vector custom painter
        ├── simulation_controls_bar.dart    # Playback toolbar (Start, Pause, Step, etc.)
        └── tsp_canvas.dart                 # Glowing pheromone circuit custom painter
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.10+ / 3.38+ recommended)
- Dart SDK (version 3.10+)

### Setup Instructions

1. Clone or navigate to the workspace directory:
   ```bash
   cd "c:\Fuzzy\swarm intelligence"
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run code analysis (verifies zero warnings or errors):
   ```bash
   flutter analyze
   ```

4. Run all unit and widget tests:
   ```bash
   flutter test
   ```

5. Launch the application:
   ```bash
   # On Windows Desktop
   flutter run -d windows

   # On Web
   flutter run -d chrome

   # On Android
   flutter run -d android
   ```

---

## 🧪 Unit Testing Suite

The project includes unit tests located in `test/`:
- `aco_test.dart`: Tour validity, Haversine distances, pheromone evaporation, elitist deposit, and grid pathfinding.
- `pso_test.dart`: Mathematical accuracy of Sphere, Rastrigin, Rosenbrock functions, velocity clamping, personal best updates, and swarm dispersion.
- `abc_test.dart`: Candidate generation, greedy replacement, onlooker roulette-wheel selection, abandonment limit, and scout replacements.
- `general_and_reproducibility_test.dart`: Deterministic random seed reproducibility across all algorithms, stopping conditions, and numerical safety (NaN and infinity bounds).
- `widget_test.dart`: UI mounting and smoke tests.

All tests can be executed via:
```bash
flutter test
```

---

## 🎓 Academic Viva Reference

When presenting this project for an academic evaluation:
1. **Explain the Biological Inspiration**: Ants finding food via trails, birds flocking without colliding, and honeybees communicating nectar via the waggle dance.
2. **Open Presentation Mode**: Use the built-in Presentation Mode to step through each algorithm stage-by-stage with formula explanations.
3. **Run Experiment Mode**: Demonstrate reproducible trials by locking the seed to `42` to show examiners consistent algorithmic behavior.
4. **Demonstrate Comparative Benchmarking**: Compare PSO vs ABC on the Rastrigin function to illustrate how scouts help ABC escape local minima traps.
