
VALA_SOURCES = pytank.vala writer.vala

pytank: $(VALA_SOURCES)
	valac --pkg vala-1.0 $(VALA_SOURCES) -X -I/usr/include/vala-1.0

check: pytank
	./pytank --library pysyncml libsyncml-1.0.vapi
