#include <iostream>
#include "Core/Debug.h"
#include "Core/Application.h"

class TestApp : public Application {
public:
    void run() override {
        std::cout << stacktrace << std::endl;
    }
};

DECL_APPLICATION(TestApp)
