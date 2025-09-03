cmake_minimum_required(VERSION 3.16)
project(minimal-engine LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

# --------------------------
# 1. Raylib
# --------------------------
set(BUILD_EXAMPLES OFF CACHE INTERNAL "")
set(BUILD_GAMES OFF CACHE INTERNAL "")
add_subdirectory(libs/raylib EXCLUDE_FROM_ALL)

# --------------------------
# 2. ODE
# --------------------------
set(ODE_WITH_DEMOS OFF CACHE INTERNAL "")
set(ODE_WITH_TESTS OFF CACHE INTERNAL "")
set(ODE_WITH_TRIMESH_GIMPACT ON CACHE INTERNAL "")
set(ODE_DOUBLE_PRECISION OFF CACHE INTERNAL "")
add_subdirectory(libs/ode EXCLUDE_FROM_ALL)

if (TARGET ode)
    set(ODE_LIB ode)
elseif (TARGET ODE)
    set(ODE_LIB ODE)
elseif (TARGET ode_double)
    set(ODE_LIB ode_double)
elseif (TARGET ode_single)
    set(ODE_LIB ode_single)
else()
    message(FATAL_ERROR "Could not find ODE library target. Check ODE's CMakeLists.")
endif()

# --------------------------
# 3. AI Toolkit (header-only)
# --------------------------

# --------------------------
# 4. Recast Navigation
# --------------------------
set(RECASTNAVIGATION_DEMO OFF CACHE INTERNAL "")
set(RECASTNAVIGATION_TESTS OFF CACHE INTERNAL "")
add_subdirectory(libs/recastnavigation EXCLUDE_FROM_ALL)

# --------------------------
# 5. Assimp
# --------------------------
set(ASSIMP_BUILD_TESTS OFF CACHE INTERNAL "")
set(ASSIMP_BUILD_SAMPLES OFF CACHE INTERNAL "")
set(ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT ON CACHE INTERNAL "")
add_subdirectory(libs/assimp EXCLUDE_FROM_ALL)

# --------------------------
# 6. Main executable
# --------------------------
add_executable(${PROJECT_NAME} src/main.cpp)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/raylib/src
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/ode/include/ode
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/aitoolkit/include/aitoolkit
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/recastnavigation/Recast/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/recastnavigation/Detour/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/assimp/include/assimp
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    raylib
    ${ODE_LIB}
    Recast
    Detour
    assimp
)

# --------------------------
# 7. Platform-specific linking
# --------------------------
if(APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        "-framework OpenGL" "-framework Cocoa" "-framework IOKit" "-framework CoreVideo"
    )
elseif(UNIX AND NOT APPLE)
    find_package(OpenGL REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${OPENGL_gl_LIBRARY} m pthread dl)
elseif(WIN32)
    find_package(OpenGL REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${OPENGL_gl_LIBRARY} opengl32 gdi32 winmm)
endif()
