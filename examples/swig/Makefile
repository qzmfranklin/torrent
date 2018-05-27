PYTHON_ROOT:=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu

test: python/_shape.so python/shape.py
	python3 python/shape_test.py

python/_shape.so: cc/Shape.o cc/shape_wrap.o
	clang -shared -o $@ $^ -L$(PYTHON_ROOT) -lpython3.5 -lstdc++

cc/shape_wrap.o: cc/shape_wrap.cc
	clang -o $@ -c $< -fPIC -I/usr/include/python3.5

python/shape.py: cc/interface.i
cc/shape_wrap.cc: cc/interface.i
	swig -c++ -python -outdir python/ -module shape -o $@ $<

%.o: %.cc
	clang -o $@ -c $< -fPIC

clean:
	rm -rf cc/*.o python/_shape.so cc/shape_wrap* python/shape.py
