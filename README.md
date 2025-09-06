# A Minimal Game Engine in C++20

This is a template repository, and can be forked to build custom games in ``raylib`` without any dependency hell or compilation headaches. The sample icon has been sourced from [Hieroglyphs by Ahmad Najiullah](https://icon-icons.com/pack/Hieroglyphs/2396). For the Windows build, you need to ship your ``assets`` directory along with the builds. For Linux, packaging as an AppImage takes care of this.

## External Dependencies

* [``GLFW3``](https://www.glfw.org/) and its dependencies for ``raylib``.

Use the following command in any Debian-based environment (Debian, Ubuntu, Pop!_OS, etc.) to install these dependencies before building the project:

```bash
sudo apt update
sudo apt install -y \
            libxinerama-dev \
            libxcursor-dev \
            libxrandr-dev \
            libxi-dev \
            libgl1-mesa-dev \
            libglu1-mesa-dev \
            libglfw3-dev
```

If you are on Windows/Mac/BSD or any other Linux flavour, install these dependencies manually.

## Building the Project

To build the project, run the following commands:

```bash
cmake -B build .
cmake --build build 
```
Delete the ``build`` directory to clean the build.

**Note.** The project requires ``cmake>=3.16`` to build. CMake version 3.22.1 is known to work successfully with ``g++`` (not ``clang``) as the C++ compiler.

## Libraries Used

* [``raylib``](https://www.raylib.com/) for graphics rendering.
* [``SoLoud``](https://github.com/jarikomppa/soloud) for audio rendering.
* [``EnTT``](https://github.com/skypjack/entt) for ECS.
* [``Open Dynamics Engine``](https://www.ode.org/) for physics.
* [``assimp``](https://www.assimp.org/) for asset import from [Blender](https://www.blender.org/).
* [``AI Toolkit``](https://github.com/linkdd/aitoolkit/tree/main) for AI behavior tree and finite state machine logic.
* [``Recast Navigation``](https://recastnav.com/) for AI pathfinding.

**To-Do.** Add libraries for networking.

**Note.** A GitHub Actions workflow has been set up to compile binaries for Linux and Windows (both on Ubuntu 24.04LTS, uses ``mingw-w64`` for Windows compilation).
