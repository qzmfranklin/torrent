# pylint: disable=missing-docstring
import pathlib
import yaml

from src.base.python import gentemplate

THIS_DIR = pathlib.Path(__file__).resolve().parent
TEMPLATE_PATH = THIS_DIR / 'load_maven_jars.bzl.j2'


# pylint: disable=missing-docstring
@gentemplate.template(TEMPLATE_PATH)
def generate_bzl():
    jars_path = THIS_DIR / 'jars.yaml'
    # pylint: disable=invalid-name
    with open(str(jars_path), 'r') as f:
        data = yaml.load(f.read())
        return {'jars': data}
