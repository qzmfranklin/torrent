# pylint: disable=missing-docstring
import pathlib
import platform

from src.base.python import gentemplate

THIS_DIR = pathlib.Path(__file__).resolve().parent
TEMPLATE_PATH = THIS_DIR / '.bazelrc.j2'


@gentemplate.template(TEMPLATE_PATH)
def generate_bzl():
    return {'architecture': platform.system()}
