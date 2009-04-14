AC_INIT([valapy], [0.1.0], [john.carr@unrouted.co.uk], [valapy])
AC_CONFIG_SRCDIR([Makefile.am])

AM_INIT_AUTOMAKE([dist-bzip2])
AM_MAINTAINER_MODE

AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_LIBTOOL
AC_PATH_PROG(VALAC, valac, valac)

PKG_CHECK_MODULES(VALAPY, glib-2.0 gobject-2.0 vala-1.0)
AC_SUBST(VALAPY_CLFALGS)
AC_SUBST(VALAPY_LIBS)

AC_CONFIG_FILES([
	Makefile
	pycode/Makefile
	bindgen/Makefile
	test/Makefile
])
AC_OUTPUT
