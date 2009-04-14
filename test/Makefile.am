BG = $(top_builddir)/bindgen/bg

check:	$(BG) 
	$(BG) --library pysyncml libsyncml-1.0.vapi
	gcc -I/usr/include/libsyncml-1.0 pysyncml.c -o gen-enums
	./gen-enums > enums.py
	python pysyncml.py

