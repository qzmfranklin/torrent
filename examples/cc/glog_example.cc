#include <gflags/gflags.h>
#include <glog/logging.h>

DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");

int main(int argc, char **argv)
{
    google::SetVersionString("1.0.0.0");
    google::SetUsageMessage("Usage : ./demo ");
    google::ParseCommandLineFlags(&argc, &argv, true);
    google::InitGoogleLogging(argv[0]);
    google::InstallFailureSignalHandler();
    // google::InstallFailureFunction(&YourFailureFunction);
    google::ShutDownCommandLineFlags();

    LOG(WARNING) << "Found " << 123213L << " cookies";
    LOG(INFO) << "FOO";
    LOG(ERROR) << "big_menu= " << FLAGS_big_menu;

    LOG(ERROR) << "About to hit a check failure and abort ...";
    CHECK_EQ(1, 0);
}
