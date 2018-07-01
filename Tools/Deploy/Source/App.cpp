#include <iostream>
#include "Core/Filesystem.h"
#include "Core/Application.h"

extern "C" int minizip_main(int argc, const char *argv[]);

class Deploy : public Application {
public:
    void deployModule(const std::string &module) {
        deployCopyFiles(module);
        createDeployArchive(module);
    }

    void deployCopyFiles(const std::string &module) const {
        std::cout << "Deploying Module: " << module << " [1/2] Copying Files..." << std::endl;
        filesystem::create_directory(mDeploy / "Modules");
        auto from = filesystem::absolute(mBuild / "Modules" / module);
        auto to = filesystem::absolute(mDeploy / "Modules" / module);
        std::cout << "-- Copying " << from << " Into " << to / module << std::endl;
        copy(from, to, filesystem::copy_options::update_existing | filesystem::copy_options::recursive);
    }

    void createDeployArchive(const std::string &module) const {
        std::cout << "Deploying Module: " << module << " [2/2] Creating Archive..." << std::endl;
        filesystem::create_directory(mDeploy / "Packages");
        auto deployFile = filesystem::absolute(mDeploy / "Packages" / (module + ".zip")).string();
        auto deployPath = filesystem::absolute(mDeploy / "Modules" / module).string();
        filesystem::remove_all(deployFile);
        const char *argv[5] = {"", "-o", "-9", deployFile.c_str(), deployPath.c_str()};
        minizip_main(5, argv);
    }

    void deployEverything() {
        for (auto &&x : filesystem::directory_iterator(mBuild / "Project/Modules/"))
            deployModule(x.path().filename().string());
    }

    void run() override {
        mBuild = args()["build"].as<std::string>();
        mDeploy = args()["deploy"].as<std::string>();
        if (args()["module"])
            deployModule(args()["module"]);
        if (args()["all"])
            deployEverything();
    }

private:
    filesystem::path mBuild, mDeploy;
};

DECL_APPLICATION(Deploy)

CmdOption build{{"build", {"-b", "--build"}, "Set Build Root", 1}};
CmdOption deploy{{"deploy", {"-d", "--deploy"}, "Set Deploy Root", 1}};
CmdOption module{{"module", {"-m", "--module"}, "Module To Deploy", 1}};
CmdOption all{{"all", {"-a", "--all"}, "Deploy Everything", 0}};
