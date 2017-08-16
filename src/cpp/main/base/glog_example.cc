#include <glog/logging.h>
#include <gflags/gflags.h>

DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");

int main(int argc, char *argv[])
{
	gflags::SetVersionString("1.0.0.0");
	gflags::SetUsageMessage("Usage : ./demo ");
    gflags::ParseCommandLineFlags(&argc, &argv, true);
	google::InitGoogleLogging(argv[0]);

    //google::InstallFailureSignalHandler();
    //google::InstallFailureFunction(&YourFailureFunction);

	LOG(INFO) << "Found " << 123213L << " cookies" ;
    LOG(WARNING) << "big_menu= " << FLAGS_big_menu;
	LOG(ERROR) << "FOO";
    gflags::ShutDownCommandLineFlags();

}
