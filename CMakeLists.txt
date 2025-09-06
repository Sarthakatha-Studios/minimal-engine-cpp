cmake_minimum_required(VERSION 3.16)
project(minimal-engine LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
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
# 6. EnTT (header-only)
# --------------------------

# --------------------------
# 7. SoLoud (auto backend)
# --------------------------
set(SOLOUD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libs/soloud)

file(GLOB SOLOUND_CORE
    ${SOLOUD_DIR}/src/core/*.cpp
)

# Auto-detect backend
if(EXISTS ${SOLOUD_DIR}/src/backend/miniaudio/soloud_miniaudio.cpp)
    set(SOLOUD_BACKEND_SRC ${SOLOUD_DIR}/src/backend/miniaudio/soloud_miniaudio.cpp)
    set(SOLOUD_BACKEND_DEF WITH_MINIAUDIO)
    message(STATUS "SoLoud: Using miniaudio backend")
elseif(EXISTS ${SOLOUD_DIR}/src/backend/sdl2/soloud_sdl2.cpp)
    set(SOLOUD_BACKEND_SRC ${SOLOUD_DIR}/src/backend/sdl2/soloud_sdl2.cpp)
    set(SOLOUD_BACKEND_DEF WITH_SDL2)
    message(STATUS "SoLoud: Using SDL2 backend")
elseif(EXISTS ${SOLOUD_DIR}/src/backend/portaudio/soloud_portaudio.cpp)
    set(SOLOUD_BACKEND_SRC ${SOLOUD_DIR}/src/backend/portaudio/soloud_portaudio.cpp)
    set(SOLOUD_BACKEND_DEF WITH_PORTAUDIO)
    message(STATUS "SoLoud: Using PortAudio backend")
else()
    message(FATAL_ERROR "No suitable SoLoud backend found!")
endif()

# Choose basic decoders (WAV only for now; add OGG/MP3 later if needed)
set(SOLOUD_DECODERS
    ${SOLOUD_DIR}/src/audiosource/wav/soloud_wav.cpp
    ${SOLOUD_DIR}/src/audiosource/wav/soloud_wavstream.cpp
)

add_library(soloud STATIC
    ${SOLOUND_CORE}
    ${SOLOUD_BACKEND_SRC}
    ${SOLOUD_DECODERS}
)

target_include_directories(soloud PUBLIC
    ${SOLOUD_DIR}/include
    ${SOLOUD_DIR}/src
)

# Define backend macro so soloud.cpp doesn't complain
target_compile_definitions(soloud PUBLIC ${SOLOUD_BACKEND_DEF})

# SDL2 backend requires linking SDL2
if(SOLOUD_BACKEND_DEF STREQUAL "WITH_SDL2")
    find_package(SDL2 REQUIRED)
    target_link_libraries(soloud PRIVATE SDL2::SDL2)
endif()

# PortAudio backend requires linking PortAudio
if(SOLOUD_BACKEND_DEF STREQUAL "WITH_PORTAUDIO")
    find_package(PortAudio REQUIRED)
    target_link_libraries(soloud PRIVATE PortAudio::PortAudio)
endif()

# Linux-specific pthread and dl flags
if(UNIX AND NOT APPLE)
    target_link_libraries(soloud PRIVATE pthread dl)
endif()

# --------------------------
# 8. Main executable
# --------------------------
add_executable(${PROJECT_NAME} src/main.cpp)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/raylib/src
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/ode/include/ode
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/aitoolkit/include/aitoolkit
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/recastnavigation/Recast/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/recastnavigation/Detour/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/assimp/include/assimp
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/entt/src/entt
    ${SOLOUD_DIR}/include
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    raylib
    ${ODE_LIB}
    Recast
    Detour
    assimp
    soloud
)

# --------------------------
# 8b. Set Windows executable icon
# --------------------------
if(WIN32)
    target_sources(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/sample.ico.rc")
endif()

# --------------------------
# 9. Platform-specific linking
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
