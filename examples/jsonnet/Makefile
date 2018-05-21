# The test outputs are in test_output.

# TODO (zhongming): Convert this Makefile into Bazel.

all: syntax.json

syntax.json: syntax.jsonnet
	jsonnet eval $^ -o test_output/$@

imports.json: imports/imports.jsonnet
	jsonnet eval $< -o test_output/$@

clean:
	rm -rf test_output/*.jsonnet
