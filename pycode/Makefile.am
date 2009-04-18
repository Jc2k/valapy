
lib_LTLIBRARIES = libpycode.la

libpycode_la_VALASOURCES = \
	node.vala \
	block.vala \
	fragment.vala \
	assignment.vala \
	expression.vala \
	constant.vala \
	functioncall.vala \
	identifier.vala \
	class.vala \
	list.vala \
	function.vala \
	statement.vala \
	returnstatement.vala \
	ifstatement.vala \
	while.vala \
	breakstatement.vala \
	continuestatement.vala \
	writer.vala \
	$(NULL)

libpycode_la_SOURCES = \
	$(libpycode_la_VALASOURCES:.vala=.c) \
	$(libpycode_la_VALASOURCES:.vala=.h) \
	$(NULL)

libpycode_la_CFLAGS = \
	$(VALAPY_CFLAGS) \
	-I$(top_srcdir) \
	$(NULL)

libpycode_la_LIBADD = \
	$(VALAPY_LIBS) \
	$(NULL)

pycode.stamp: $(libpycode_la_VALASOURCES)
	valac $(libpycode_la_VALASOURCES) --pkg gee-1.0 --library pycode --basedir $(top_srcdir) -C
	touch pycode.stamp

BUILT_SOURCES = \
	pycode.stamp \
	$(NULL)

EXTRA_DIST = \
	pycode.stamp \
	$(libpycode_la_VALASOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
