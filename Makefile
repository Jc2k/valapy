NULL = 
VALA_SOURCES =	pytank.vala \
		tankwriter.vala \
		pycode/node.vala \
		pycode/block.vala \
		pycode/fragment.vala \
		pycode/assignment.vala \
		pycode/expression.vala \
		pycode/constant.vala \
		pycode/functioncall.vala \
		pycode/identifier.vala \
		pycode/class.vala \
		pycode/writer.vala \
		$(NULL)

pytank: $(VALA_SOURCES)
	valac --pkg vala-1.0 $(VALA_SOURCES) -X -I/usr/include/vala-1.0 --save-temps

check: pytank
	./pytank --library pysyncml libsyncml-1.0.vapi
