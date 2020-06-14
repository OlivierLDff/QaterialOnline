#include "version.h"

#ifdef EMSCRIPTEN

#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>

EMSCRIPTEN_BINDINGS(version) {
    emscripten::class_<Version>("Version")
        .constructor<>()
        .property("hash", &Version::hash)
        .property("date", &Version::date)
        .property("runId", &Version::runId)
        .property("runNumber", &Version::runNumber)
        .property("qtVersion", &Version::qtVersion);
}

#endif
