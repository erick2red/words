NULL =

AM_CPPFLAGS = \
	-include config.h \
	$(WORDS_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)

AM_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@WORDS_PACKAGES@ \
	$(NULL)

bin_PROGRAMS = gnome-words

gnome_words_SOURCES = \
	words-app.vala \
	main.vala \
	$(NULL)

gnome_words_LDADD = $(WORDS_LIBS)

CLEANFILES = *.h *.c *.vapi *.stamp
