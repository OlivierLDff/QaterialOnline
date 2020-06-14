#include <string>

struct Version {
    const std::string hash = QATERIALONLINE_VERSION;
    const std::string date = QATERIALONLINE_BUILD_DATE;
    const std::string runNumber = QATERIALONLINE_BUILD_RUN_NUMBER;
    const std::string runId = QATERIALONLINE_BUILD_RUN_ID;
};
