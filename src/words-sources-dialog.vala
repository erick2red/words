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

public class Words.SourcesDialog : Dialog {
  private StorageManager storage_manager;

  public SourcesDialog (Window parent, StorageManager st_mngr) {
    storage_manager = st_mngr;

    set_title (_("Sources"));
    set_modal (true);
    set_transient_for (parent);
    add_button (Stock.CLOSE, ResponseType.CLOSE);
    set_default_size (300, 250);

    var content_area = get_content_area ();

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
  }
}