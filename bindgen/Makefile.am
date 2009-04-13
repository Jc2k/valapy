NULL = 

noinst_PROGRAMS = bg

bg_VALASOURCES = \
	bindgen.vala \
	pygen.vala \
	cgen.vala \
	$(NULL)

bg_SOURCES = \
	$(bg_VALASOURCES:.vala=.c) \
	$(bg_VALASOURCES:.vala=.h) \
	$(NULL)

bg_CFLAGS = $(PYCODE_CFLAGS)
bg_LDADD = $(PYCODE_LIBS)
