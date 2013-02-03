/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 8 -*- */
/*
 * Copyright (C) 2011 Erick Pérez Castellanos <erick.red@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

using Gtk;

public class Words.App : Gtk.Application {
  public static App app;
  public GLib.Settings settings;
  public ApplicationWindow window;

  private StorageManager storage_manager;

  private Grid main_grid;
  private SearchEntry search_entry;
  private DefinitionBox def_box;

  private static string word = null;
  private static string unimported = null;
  private static const OptionEntry[] options = {
    { "word", 'w', 0, OptionArg.STRING, ref word,
      N_("Search word"), null },
    { "import", 'i', 0, OptionArg.STRING, ref unimported,
      N_("Import dictionary"), null },
    { null }
  };

  private void create_window () {
    var action = new GLib.SimpleAction ("quit", null);
    action.activate.connect (() => { window.destroy (); });
    this.add_action (action);

    action = new GLib.SimpleAction ("import", null);
    action.activate.connect (() => { import_dict (); });
    this.add_action (action);

    action = new GLib.SimpleAction ("sources", null);
    action.activate.connect (() => { manage_sources (); });
    this.add_action (action);

    action = new GLib.SimpleAction ("about", null);
    action.activate.connect (() => { show_about (); });
    this.add_action (action);

    var builder = new Builder ();
    builder.set_translation_domain (Config.GETTEXT_PACKAGE);
    try {
      Gtk.my_builder_add_from_resource (builder, "/org/gnome/words/app-menu.ui");
      set_app_menu ((MenuModel)builder.get_object ("app-menu"));
    } catch {
      warning ("Failed to parsing ui file");
    }

    window = new ApplicationWindow (this);
    window.set_title (_("Words"));
    window.set_default_size (400, 600);
    window.set_border_width (12);

    main_grid = new Grid ();
    main_grid.set_orientation (Orientation.VERTICAL);

    search_entry = new SearchEntry ();
    search_entry.set_hexpand (true);
    main_grid.add (search_entry);

    var scrolled_window = new ScrolledWindow (null, null);
    scrolled_window.set_shadow_type (ShadowType.OUT);

    def_box = new DefinitionBox ();
    def_box.set_vexpand (true);

    scrolled_window.add (def_box);
    main_grid.add (scrolled_window);

    main_grid.show_all ();
    window.add (main_grid);

    search_entry.activate.connect (() => {
	stdout.printf ("Will search %s\n", search_entry.get_text ());
      });
  }

  private void manage_sources () {
    var dialog = new Dialog.with_buttons (_("Sources"),
					  this.window,
					  DialogFlags.MODAL,
					  Stock.CLOSE, ResponseType.CLOSE);
    dialog.set_default_size (300, 250);
    var content_area = dialog.get_content_area ();

    var scrolled = new ScrolledWindow(null, null);
    scrolled.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
    scrolled.set_vexpand (true);
    scrolled.set_hexpand (true);
    scrolled.set_shadow_type (ShadowType.OUT);

    var sources_view = new Egg.ListBox ();
    /* TODO: missing separator */
    sources_view.set_selection_mode (SelectionMode.NONE);

    sources_view.add_to_scrolled (scrolled);
    sources_view.show_all ();
    scrolled.set_no_show_all (true);

    content_area.add (scrolled);

    /* adding demo stuff */
    for (int i = 0; i < 2; i++) {
      var grid = new Grid ();
      grid.add (new Label ("Boston Globe Dicts"));
      var sw = new Switch ();
      sw.set_hexpand (true);
      sw.set_halign (Align.END);
      grid.add (sw);

      sources_view.add (grid);
      grid.show_all ();
    }

    scrolled.show ();
    dialog.run ();
    dialog.destroy ();
  }

  private void import_dict () {
    var dialog = new Gtk.FileChooserDialog (_("Select dictionary file or folder"),
					    this.window,
					    FileChooserAction.OPEN,
					    Stock.CANCEL, ResponseType.CANCEL,
					    Stock.OPEN, ResponseType.ACCEPT);
    if (dialog.run () == ResponseType.ACCEPT) {
      var f = dialog.get_file ();
      stdout.printf ("Selected file was: %s\n", f.get_uri ());
    }
    dialog.destroy ();

    int source_id;
    if (this.storage_manager.create_source ("Larousse Biggest", true, out source_id))
      stdout.printf ("Inserted source: %d\n", source_id);
    if (this.storage_manager.create_source ("Brittanica Lessons", true, out source_id))
      stdout.printf ("Inserted source: %d\n", source_id);
    if (this.storage_manager.create_source ("Oxford Advanced Leaners", true, out source_id))
      stdout.printf ("Inserted source: %d\n", source_id);

    source_id = 1;
    this.storage_manager.add_definition (source_id, "kitten", "a cute cat");
    this.storage_manager.add_definition (source_id, "baby", "a human poppy");
  }

  public App() {
    Object (application_id: "org.gnome.Words", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    app = this;
    settings = new GLib.Settings ("org.gnome.words");
  }

  public override void startup () {
    this.storage_manager = new StorageManager ();
    base.startup ();
  }

  public override void activate () {
    if (window == null)
      create_window ();

    window.present ();
  }

  public override int command_line (ApplicationCommandLine command_line) {
    var args = command_line.get_arguments ();
    unowned string[] _args = args;
    var context = new OptionContext (N_("— dictionary"));
    context.add_main_entries (options, Config.GETTEXT_PACKAGE);
    context.set_translation_domain (Config.GETTEXT_PACKAGE);
    context.add_group (Gtk.get_option_group (true));

    word = null;

    try {
      context.parse (ref _args);
    } catch (Error e) {
      printerr ("Unable to parse: %s\n", e.message);
      return 1;
    }

    activate ();

    if (word != null) {
      stdout.printf ("Will match the word: %s\n", word);
    }

    if (unimported != null)
      stdout.printf ("will import from : %s\n", unimported);

    return 0;
  }

  public void show_about () {
    string[] authors = {
      "Erick Pérez Castellanos <erick.red@gmail.com>"
    };
    string[] artists = {
      "Allan Day <allanpday@gmail.com>"
    };
    Gtk.show_about_dialog (window,
			   "artists", artists,
			   "authors", authors,
			   "translator-credits", _("translator-credits"),
			   "program-name", _("Words"),
			   "title", _("About Words"),
			   "comments", _("Dictionary application for GNOME"),
			   "license-type", Gtk.License.GPL_2_0,
			   "logo-icon-name", "accessories-dictionary",
			   "version", Config.PACKAGE_VERSION,
			   "website", "https://github.com/erick2red/words",
			   "wrap-license", true);
  }
}