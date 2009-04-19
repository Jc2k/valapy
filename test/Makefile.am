BG = $(top_builddir)/bindgen/bg

check:	$(BG) 
	$(BG) --library pysyncml $(srcdir)/libsyncml-1.0.vapi
	gcc -I/usr/include/libsyncml-1.0 pysyncml.c -o gen-enums
	./gen-enums > enums.py
	python pysyncml.py

EXTRA_DIST = libsyncml-1.0.vapi

-include $(top_srcdir)/git.mk
