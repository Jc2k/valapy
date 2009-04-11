NULL = 

VALA_SOURCES = \
		bindgen/bindgen.vala \
		bindgen/pygen.vala \
		bindgen/cgen.vala \
		pycode/node.vala \
		pycode/block.vala \
		pycode/fragment.vala \
		pycode/assignment.vala \
		pycode/expression.vala \
		pycode/constant.vala \
		pycode/functioncall.vala \
		pycode/identifier.vala \
		pycode/class.vala \
		pycode/list.vala \
		pycode/function.vala \
		pycode/writer.vala \
		$(NULL)

bg: $(VALA_SOURCES)
	valac -o bg --pkg vala-1.0 $(VALA_SOURCES) -X -I/usr/include/vala-1.0 --save-temps

check: bg
	./bg --library pysyncml test/libsyncml-1.0.vapi
	gcc -I/usr/include/libsyncml-1.0 pysyncml.c -o gen-enums
	./gen-enums > enums.py
	python pysyncml.py
