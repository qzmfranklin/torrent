#include <gflags/gflags.h>
#include <glog/logging.h>

// Note that this function is not declared with `extern "C"`, thus having a C++
// linkage.  This is made so deliberately to guard against subtle difference in
// the function signatures, e.g., `int MAIN(int, char const **)`.
extern int MAIN(int argc, char **argv);

int main(int argc, char **argv)
{
    //google::SetVersionString("1.0.0.0");
    //google::SetUsageMessage("Usage : ./demo ");
    google::ParseCommandLineFlags(&argc, &argv, true);
    google::InitGoogleLogging(argv[0]);
    google::InstallFailureSignalHandler();
    // google::InstallFailureFunction(&YourFailureFunction);
    google::ShutDownCommandLineFlags();

    return MAIN(argc, argv);
}
