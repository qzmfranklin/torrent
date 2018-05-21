import pathlib

from src.base.python import gentemplate

THIS_DIR = pathlib.Path(__file__).resolve().parent
TEMPLATE_PATH = THIS_DIR / 'mock_settings.j2'


@gentemplate.template(TEMPLATE_PATH)
def generate_bzl():
    return {'redis': {'url': 'localhost', 'port': 16379}}
