#include <iostream>
#include "Core/StringUtils.h"
#include "Core/Application.h"

auto invoke(const std::string& v) {
    std::cout << v << std::endl;
    return std::system(v.c_str());
}

class ProjectManager : public Application {
public:
    void updateProjects() {
        auto projRoot = mRoot / "Libs";
        for (auto&& x : filesystem::directory_iterator(projRoot))
            if (x.is_directory())
                invoke(std::string("cd " + filesystem::absolute(x).string() + "&& git pull"));
    }

    void fetchProject() {
        auto fetch = split(args()["fetch"].as<std::string>(), ':');
        filesystem::path x = mRoot / "Libs";
        invoke(std::string("cd " + x.string() + "&& git clone https://github.com/"+ fetch[0] + '/' + fetch[1]));
    }

    void run() override {
        if (args()["root"]) mRoot = args()["root"].as<std::string>();
        if (args()["update"]) updateProjects();
        if (args()["fetch"]) fetchProject();
    }
private:
    filesystem::path mRoot;
};

DECL_APPLICATION(ProjectManager)

CmdOption root {{"root", {"-r", "--root"}, "Set Project Root", 1}};
CmdOption update {{"update", {"-u", "--update"}, "Update Projects", 0}};
CmdOption fetch {{"fetch", {"-f", "--fetch"}, "Fetch Remote Project", 1}};
