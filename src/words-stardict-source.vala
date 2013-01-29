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

using Gee;

public class Words.StardictSource : Object, Source {
  public string get_definition (string word) {
    return "Baby, vs, bae, some othre form. Way of calling the babies";
  }

  public ArrayList<string> get_matches (string word) {
    var matches = new ArrayList<string> ();

    matches.add ("barbeque");
    matches.add ("barbeques");
    matches.add ("barbies");
    matches.add ("babies");
    matches.add ("baby");
    matches.add ("babe");

    return matches;
  }
}