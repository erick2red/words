NULL =

AM_CPPFLAGS = \
	-include config.h \
	$(WORDS_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)

AM_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config --pkg custom --vapidir=$(srcdir)/../egg-list-box --pkg egglistbox \
	@WORDS_PACKAGES@ \
	$(NULL)

bin_PROGRAMS = gnome-words

vala_sources = \
	words-utils.vala \
	words-sources-dialog.vala \
	words-source-loader.vala \
	words-stardict-loader.vala \
	words-definition-box.vala \
	words-storage-manager.vala \
	words-app.vala \
	main.vala \
	$(NULL)

gsettingsschema_in_files = org.gnome.words.gschema.xml.in
gsettings_SCHEMAS = $(gsettingsschema_in_files:.xml.in=.xml)

@INTLTOOL_XML_NOMERGE_RULE@

@GSETTINGS_RULES@

word-resources.c: words.gresource.xml app-menu.ui
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) $(srcdir)/words.gresource.xml \
		--target=$@ --sourcedir=$(srcdir) --c-name words --generate-source

gnome_words_SOURCES = \
	word-resources.c \
	$(vala_sources) \
	$(NULL)

gnome_words_LDADD = $(WORDS_LIBS)

CLEANFILES = \
	$(vala_sources:.vala=.c) \
	$(gsettings_SCHEMAS) \
	*.vapi *.stamp

EXTRA_DIST = \
	words.gresource.xml \
	$(gsettingsschema_in_files)     \
        $(NULL)
