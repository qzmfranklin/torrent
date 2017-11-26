#include <gflags/gflags.h>

DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");

int main(int argc, char *argv[])
{
    //gflags::SetVersionString("1.0.0.0");
    //gflags::SetUsageMessage("Usage : ./demo ");
    gflags::ParseCommandLineFlags(&argc, &argv, true);
    gflags::ShutDownCommandLineFlags();
}
