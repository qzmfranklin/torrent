from __future__ import print_function
import sys

if sys.version_info < (3, 0):
    print("This script must not run with python2.X. Abort.")
    sys.exit(1)
else:
    print("This script runs correctly with python3.X. Done.")
    sys.exit(0)
