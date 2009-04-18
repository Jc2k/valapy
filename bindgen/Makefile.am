NULL = 

noinst_PROGRAMS = bg

bg_VALASOURCES = \
	$(top_srcdir)/pycode/pycode.vapi \
	bindgen.vala \
	pygen.vala \
	cgen.vala \
	$(NULL)

bg_SOURCES = \
	$(bg_VALASOURCES:.vala=.c) \
	$(bg_VALASOURCES:.vala=.h) \
	$(NULL)

bg_CFLAGS = \
	$(VALAPY_CFLAGS) \
	-I$(top_builddir) \
	$(NULL)

bg_LDADD = \
	$(VALAPY_LIBS) \
	$(top_builddir)/pycode/libpycode.la \
	$(NULL)

bg.stamp: $(bg_VALASOURCES)
	valac -C --pkg vala-1.0 $^
	touch bg.stamp

BUILT_SOURCES = bg.stamp

GITIGNOREFILES = \
	$(bg_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
