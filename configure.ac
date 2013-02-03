AC_PREREQ([2.68])
AC_INIT([words],[0.1.0],[https://github.com/erick2red/words])
AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE

# Enable silent rules is available
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE
AC_CONFIG_FILES([Makefile
		vapi/Makefile
		src/Makefile
		po/Makefile.in])

LT_INIT
AC_PROG_CC
AM_PROG_VALAC([0.17.2])
AC_PROG_INSTALL

GLIB_GSETTINGS

# i18n stuff
IT_PROG_INTLTOOL([0.40])

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])

GETTEXT_PACKAGE=words
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)

# EggListBox submodule
prev_top_build_prefix=$ac_top_build_prefix
prev_ac_configure_args=$ac_configure_args
AX_CONFIG_DIR([egg-list-box])
ac_top_build_prefix=$prev_top_build_prefix
ac_configure_args=$prev_ac_configure_args

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:"$ac_top_build_prefix"egg-list-box

pkg_modules="gtk+-3.0
	     gee-1.0
	     webkitgtk-3.0
	     sqlite3
	     egg-list-box
	     "

PKG_CHECK_MODULES(WORDS, [$pkg_modules])

WORDS_PACKAGES="--pkg gtk+-3.0 --pkg gee-1.0 --pkg webkitgtk-3.0 --pkg sqlite3"
AC_SUBST(WORDS_PACKAGES)

#############
# Resources #
#############

GLIB_COMPILE_RESOURCES=`$PKG_CONFIG --variable glib_compile_resources gio-2.0`
AC_SUBST(GLIB_COMPILE_RESOURCES)

AC_OUTPUT
