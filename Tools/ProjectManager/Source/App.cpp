#include <iostream>
#include "Clone.h"
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
        auto opt = split(args()["fetch"].as<std::string>(), ':');
        clone(std::string("https://github.com/" + opt[0] + '/' + opt[1]).c_str(),
              (mRoot / "Libs" / opt[1]).string().c_str());
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
