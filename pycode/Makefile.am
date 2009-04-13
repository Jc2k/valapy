
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
	writer.vala \
	$(NULL)

libpycode_la_SOURCES = \
	$(libpycode_la_VALASOURCES:.vala=.c)

libpycode_la_HEADERS = \
	$(libpycode_la_VALASOURCES:.vala=.h)

libpycode_la_CFLAGS = \
	$(NULL)

libpycode_la_LIBADD = \
	$(NULL)

pycode.stamp: $(libpycode_la_VALA_SOURCES)
	valac $(libpycode_la_VALA_SOURCES) --pkg gee-1.0 --library pycode -C

BUILT_SOURES = \
	pycode.stamp \
	$(NULL)

EXTRA_DIST = \
	pycode.stamp \
	$(libpycode_la_VALASOURCES) \
	$(NULL)
