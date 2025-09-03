# A Minimal Game Engine in C++

## External Dependencies

* [GLFW3](https://www.glfw.org/) for ``raylib``.
* [Google Tests](https://google.github.io/googletest/) for ``BehaviorTree.CPP``.
* [SQLite 3](https://sqlite.org/) for ``BehaviorTree.CPP``.
* [ZeroMQ](https://zeromq.org/) for ``BehaviorTree.CPP``.

Use ``install_deps.sh`` in any Debian-based environment (Debian, Ubuntu, Pop!_OS, etc.) to install these dependencies before building the project, or if you are on Windows/Mac/BSD or any other Linux flavour, install these dependencies manually.

## Libraries Used

* [``raylib``](https://www.raylib.com/) for graphics rendering.
* [``Open Dynamics Engine``](https://www.ode.org/) for physics.
* [``assimp``](https://www.assimp.org/) for asset import from [Blender](https://www.blender.org/).
* [``BehaviorTree.CPP``](https://www.behaviortree.dev/) for behavior tree logic.
* [``Recast Navigation``](https://recastnav.com/) for AI pathfinding.

Requires ``cmake>=3.16`` to build the project. The workflow has been tested on CMake version 3.22.1 successfully. We used ``gcc`` (not ``clang``) as our C++ compiler.
