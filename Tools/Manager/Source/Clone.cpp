#include "Clone.hpp"
#include <git2.h>
#include <git2/clone.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <iostream>

namespace {
    struct ProgressData {
        git_transfer_progress fetch_progress;
        size_t completed_steps;
        size_t total_steps;
        const char *path;
    };

    int cred_acquire_cb(git_cred **out, const char *, const char *, unsigned int, void *) {
        std::string username, password;
        printf("Username: ");
        std::getline(std::cin, username);
        printf("Password: ");
        std::getline(std::cin, password);
        return git_cred_userpass_plaintext_new(out, username.c_str(), password.c_str());
    }

    void printResolveDeltaProgress(const ProgressData &pd) {
        printf("Resolving deltas %d/%d\r", pd.fetch_progress.indexed_deltas, pd.fetch_progress.total_deltas);
    }

    bool isResolvingDelta(const ProgressData &pd) {
        return pd.fetch_progress.total_objects && pd.fetch_progress.received_objects == pd.fetch_progress.total_objects;
    }

    unsigned int computeNetworkPercent(const ProgressData &pd) {
        return pd.fetch_progress.total_objects > 0 ?
               (100 * pd.fetch_progress.received_objects) / pd.fetch_progress.total_objects : 0;
    }

    unsigned int computeIndexPercent(const ProgressData &pd) {
        return pd.fetch_progress.total_objects > 0 ?
               (100 * pd.fetch_progress.indexed_objects) / pd.fetch_progress.total_objects : 0;
    }

    int computeCheckoutPercent(const ProgressData &pd) {
        return static_cast<int>(pd.total_steps > 0 ? (100 * pd.completed_steps) / pd.total_steps : 0);
    }

    void printDownloadProgress(const ProgressData &pd) {
        auto kBytes = pd.fetch_progress.received_bytes / 1024;
        printf("net %3d%% (%zu kb, %5d/%5d)  /  idx %3d%% (%5d/%5d)  /  chk %3d%% (%zu/%zu) %s\n",
               computeNetworkPercent(pd), kBytes, pd.fetch_progress.received_objects, pd.fetch_progress.total_objects,
               computeIndexPercent(pd), pd.fetch_progress.indexed_objects, pd.fetch_progress.total_objects,
               computeCheckoutPercent(pd), pd.completed_steps, pd.total_steps,
               pd.path);
    }

    void printProgress(const ProgressData &pd) {
        if (isResolvingDelta(pd))
            printResolveDeltaProgress(pd);
        else
            printDownloadProgress(pd);
    }

    int sidebandProgress(const char *str, int len, void *) {
        printf("remote: %.*s", len, str);
        fflush(stdout);
        return 0;
    }

    int fetchProgress(const git_transfer_progress *stats, void *payload) {
        auto &pd = *reinterpret_cast<ProgressData *>(payload);
        pd.fetch_progress = *stats;
        printProgress(pd);
        return 0;
    }

    void checkoutProgress(const char *path, size_t cur, size_t tot, void *payload) {
        auto &pd = *reinterpret_cast<ProgressData *>(payload);
        pd.completed_steps = cur;
        pd.total_steps = tot;
        pd.path = path;
        printProgress(pd);
    }

    void printErrorData(int error) {
        const git_error *err = giterr_last();
        if (err)
            printf("ERROR %d: %s\n", err->klass, err->message);
        else
            printf("ERROR %d: no detailed info\n", error);
    }

    int doClone(const git_clone_options& clone_opts, const char *url, const char *path) {
        git_repository *cloned_repo = nullptr;
        int error = git_clone(&cloned_repo, url, path, &clone_opts);
        if (error == 0) {
            if (cloned_repo)
                git_repository_free(cloned_repo);
        } else
            printErrorData(error);
        return error;
    }

    git_clone_options setupOptions(ProgressData &pd) {
        git_clone_options clone_opts = GIT_CLONE_OPTIONS_INIT;
        git_checkout_options checkout_opts = GIT_CHECKOUT_OPTIONS_INIT;
        checkout_opts.checkout_strategy = GIT_CHECKOUT_SAFE;
        checkout_opts.progress_cb = checkoutProgress;
        checkout_opts.progress_payload = &pd;
        clone_opts.checkout_opts = checkout_opts;
        clone_opts.fetch_opts.callbacks.sideband_progress = sidebandProgress;
        clone_opts.fetch_opts.callbacks.transfer_progress = &fetchProgress;
        clone_opts.fetch_opts.callbacks.credentials = cred_acquire_cb;
        clone_opts.fetch_opts.callbacks.payload = &pd;
        return clone_opts;
    }
}

int clone(const char *url, const char *path) {
    ProgressData pd = {{0}};
    git_libgit2_init();
    int error = doClone(setupOptions(pd), url, path);
    git_libgit2_shutdown();
    return error;
}
