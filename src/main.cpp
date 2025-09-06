// -----------------------------
// Minimal Engine Integration Test
// -----------------------------

// Graphics
#include "raylib.h"

// ECS
#include "entt.hpp"

// Physics
#include "ode.h"

// AI
#include "Recast.h"
#include "DetourNavMesh.h"
#include "behtree.hpp"

// Assets
#include "Importer.hpp"
#include "postprocess.h"
#include "scene.h"

// Audio
#include "soloud.h"

#include <iostream>

int main() {
    // -----------------------------
    // 1. Raylib: open a window & draw text
    // -----------------------------
    InitWindow(800, 600, "Minimal Engine Test");
    SetTargetFPS(60);
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Raylib OK", 10, 10, 20, DARKGRAY);
    EndDrawing();
    CloseWindow();

    // -----------------------------
    // 2. EnTT: simple ECS entity test
    // -----------------------------
    entt::registry registry;
    auto entity = registry.create();
    registry.emplace<int>(entity, 42);
    std::cout << "EnTT OK, component value = " << registry.get<int>(entity) << "\n";

    // -----------------------------
    // 3. ODE: basic world simulation
    // -----------------------------
    dInitODE();
    dWorldID world = dWorldCreate();
    dBodyID body = dBodyCreate(world);

    dMass mass;
    dMassSetSphere(&mass, 1.0, 0.5);
    dBodySetMass(body, &mass);
    dWorldStep(world, 0.01);

    const dReal* pos = dBodyGetPosition(body);
    std::cout << "ODE OK, body y-pos = " << pos[1] << "\n";

    dWorldDestroy(world);
    dCloseODE();

    // -----------------------------
    // 4. AI Toolkit: minimal behavior tree
    // -----------------------------
    struct MyBlackboard { int counter{0}; };
    MyBlackboard bb;

    auto task_node = aitoolkit::bt::task<MyBlackboard>([](auto& blackboard){
        blackboard.counter++;
        return aitoolkit::bt::execution_state::success;
    });

    auto state = task_node.evaluate(bb);

    std::cout << "AI Toolkit OK, task node evaluated to "
              << (state == aitoolkit::bt::execution_state::success ? "Success" :
                  state == aitoolkit::bt::execution_state::failure ? "Failure" : "Running")
              << ", counter = " << bb.counter << "\n";

    // -----------------------------
    // 5. Recast + Detour: basic navmesh sanity check
    // -----------------------------
    rcConfig cfg{};
    cfg.cs = 0.3f;
    cfg.ch = 0.2f;
    cfg.walkableSlopeAngle = 45.0f;
    cfg.walkableHeight = 2;
    cfg.walkableClimb = 1;
    cfg.walkableRadius = 1;
    cfg.maxEdgeLen = 12;
    cfg.maxSimplificationError = 1.3f;
    cfg.minRegionArea = 8;
    cfg.mergeRegionArea = 20;
    cfg.maxVertsPerPoly = 6;
    cfg.detailSampleDist = 6.0f;
    cfg.detailSampleMaxError = 1.0f;

    rcContext ctx;
    rcHeightfield* hf = rcAllocHeightfield();
    float bmin[3] = {0.0f, 0.0f, 0.0f};
    float bmax[3] = {10.0f, 5.0f, 10.0f};
    bool success = rcCreateHeightfield(&ctx, *hf, 10, 10, bmin, bmax, cfg.cs, cfg.ch);
    std::cout << "Recast heightfield creation: " << (success ? "OK" : "FAIL") << "\n";
    rcFreeHeightField(hf);

    dtNavMesh* navmesh = dtAllocNavMesh();
    dtNavMeshParams params{};
    params.maxPolys = 1;
    params.maxTiles = 1;
    dtStatus dtStatus = navmesh->init(&params);
    std::cout << "Detour navmesh init: " << ((dtStatus & DT_SUCCESS) ? "OK" : "FAIL") << "\n";
    dtFreeNavMesh(navmesh);

    // -----------------------------
    // 6. Assimp: attempt to load a test model
    // -----------------------------
    Assimp::Importer importer;
    const aiScene* scene = importer.ReadFile("assets/models/test.fbx",
        aiProcess_Triangulate | aiProcess_GenNormals | aiProcess_JoinIdenticalVertices);

    if (!scene) {
        std::cout << "Assimp load test.fbx: FAIL (" << importer.GetErrorString() << ")\n";
    } else {
        std::cout << "Assimp OK, meshes loaded = " << scene->mNumMeshes << "\n";
    }

    // -----------------------------
    // 7. SoLoud: init & cleanup
    // -----------------------------
    SoLoud::Soloud soloud;
    soloud.init();
    soloud.deinit();
    std::cout << "SoLoud OK\n";

    std::cout << "All libraries linked and tested successfully.\n";
    return 0;
}
