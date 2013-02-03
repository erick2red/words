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
using Sqlite;

static const string schema =
"""CREATE TABLE "sources" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "enabled" integer);
CREATE TABLE "dictionaries" ("source_id" integer NOT NULL, "word" varchar(255), "definition" varchar(255));
CREATE UNIQUE INDEX "index_sources_on_id" ON "sources" ("id");
CREATE UNIQUE INDEX "index_sources_on_name" ON "sources" ("name");
""";

public class Words.StorageManager : Object {
	private Database db_handler;

	public StorageManager () {
		var db_filename = Words.get_user_pkgdata ("words.db");
		var existed = FileUtils.test (db_filename, FileTest.IS_REGULAR);

		var result = Database.open_v2 (db_filename, out this.db_handler);
		if (result != 0)
			stdout.printf ("Something happened: %s\n", this.db_handler.errmsg ());

		if (! existed) {
			/* Will load default schema */
			string err;
			result = this.db_handler.exec (schema, null, out err);
			if (result != 0)
				stdout.printf ("There were some error loading schema: %s\n", err);
		}
	}

	public bool create_source (string name, bool enabled, out int source_id) {
		var stmt = "INSERT INTO sources (name, enabled) VALUES ('%s', %d)".printf (name, enabled ? 1 : 0);
		string err;
		source_id = 0;
		if (this.db_handler.exec (stmt, null, out err) != 0) {
			stdout.printf ("Something happened: %s\n", err);
			return false;
		} else {
			stmt = "SELECT id FROM sources WHERE name='%s'".printf (name);
			string [] results;
			int nr_row, nr_column;
			this.db_handler.get_table (stmt, out results, out nr_row, out nr_column);

			/* it should always be one so */
			source_id = int.parse (results[1]);
			return true;
		}
	}

	public void fill_source (int source_id, HashMap<string, string> data) {
		;
	}

	public void add_definition (int source_id, string word, string definition) {
		/* definitions are appended */
		var stmt = "SELECT rowid,definition FROM dictionaries WHERE source_id=%d and word='%s'".printf (source_id, word);
		string err;
		string [] results;
		int nr_row, nr_column;
		if (this.db_handler.get_table (stmt, out results, out nr_row, out nr_column, out err) == 0) {
			if (results.length > 0) {
				int rowid = int.parse (results[2]);
				string new_definition = results[3] + "\n" + definition;
				stmt = "UPDATE dictionaries SET definition='%s' WHERE rowid=%d".printf (new_definition, rowid);
				if (this.db_handler.exec (stmt, null, out err) != 0)
					stdout.printf ("Something happened: %s\n", err);
			} else {
				stmt = "INSERT INTO dictionaries (source_id, word, definition) VALUES (%d, '%s', '%s')".printf (source_id, word, definition);
				if (this.db_handler.exec (stmt, null, out err) != 0)
					stdout.printf ("Something happened: %s\n", err);
			}
		}
	}
}