# A Minimal Game Engine in C++

## External Dependencies

* GLFW3
* Google Tests
* SQLite 3
* ZeroMQ

Use ``install_deps.sh`` in any Debian-based environment (Debian, Ubuntu, Pop!_OS, etc.) to install these dependencies before building the project.

## Libraries Used

* [``raylib``](https://www.raylib.com/) for graphics rendering.
* [``Open Dynamics Engine``](https://www.ode.org/) for physics.
* [``assimp``](https://www.assimp.org/) for asset import from Blender.
* [``BehaviorTree.CPP``](https://www.behaviortree.dev/) for behavior tree logic.
* [``Recast Navigation``](https://recastnav.com/) for AI pathfinding.

Requires ``cmake>=3.16`` to build the project.
