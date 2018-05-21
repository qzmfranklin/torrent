'''Test bazel pex rules.

This file used to validate the Bazel rules pex_library and pex_binary.  Please
do not import it in your own code.
'''

import netaddr


def ip(s):  # pylint: disable=invalid-name
    '''
    Convert a string to an netaddr.IPAddress object.

    If the input string cannot be converted to an ip address, return None.
    '''
    try:
        return netaddr.IPAddress(s)
    except netaddr.core.AddrFormatError:
        return
