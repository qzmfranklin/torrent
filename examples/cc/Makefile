# This Makefile builds llvm_toy from llvm_toy.cc.
# It is a low-level playground for anyone with interest to get comfortable with
# building LLVM-based applications.

llvm_toy: llvm_toy.o
	clang -o $@ $^ \
	    -fcolor-diagnostics \
	    -lrt -ldl -lpthread -lm \
	    -lstdc++ \
	    `llvm-config --ldflags --libs all`

%.o: %.cc
	clang -o $@ -c $< \
	    -fcolor-diagnostics \
	    `llvm-config --cxxflags`

clean:
	rm -rf llvm_toy llvm_toy.o
