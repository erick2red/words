/* -*- Mode: vala; indent-tabs-mode: nil; c-basic-offset: 2; tab-width: 8 -*- */
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
  Database db_handler;
  Statement add_word_stmt;

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

    result = this.db_handler.prepare_v2 ("INSERT INTO dictionaries VALUES (@i, @word, @def)",
                                         -1,
                                         out this.add_word_stmt);
    if (result != Sqlite.OK)
      stdout.printf ("Something happened: %s\n", this.db_handler.errmsg ());
  }

  /**
   * Inserts a source into db.
   * @name The source name
   * @enabled if it's enable or not
   *
   * @return -1 on fail, the source_id otherwise
   */
  public int create_source (string name, bool enabled) {
    /* escaping */
    var escaped_name = escape_quote (name);
    var stmt = "INSERT INTO sources (name, enabled) VALUES ('%s', %d)".printf (escaped_name, enabled ? 1 : 0);

    string err;
    if (this.db_handler.exec (stmt, null, out err) != 0) {
      stdout.printf ("Something happened: %s\n", err);
      return -1;
    } else {
      stmt = "SELECT id FROM sources WHERE name='%s'".printf (escaped_name);
      string [] results;
      int nr_row, nr_column;
      this.db_handler.get_table (stmt, out results, out nr_row, out nr_column);

      /* it should always be one so */
      return int.parse (results[1]);
    }
  }

  public void set_enable_source (int source_id, bool enabled) {
    ;
  }

  public void fill_source (int source_id, HashMap<string, string> data) {
    ;
  }

  /**
   * This method and its pair below will act as block delimitiers
   * for insertings definitions into db. These will call "BEGIN/END TRANSACTION"
   * accordingly. The should be used like this:
   * {{{
   *   my_db.start_insertions ();
   *   foreach (var s in list) {
   *     my_db.add_definition (source_id, s, def[s]);
   *   }
   *   my_db.end_insertions ();
   * }}}
   */
  public void start_insertions () {
    this.db_handler.exec ("BEGIN TRANSACTION");
  }

  public void end_insertions () {
    this.db_handler.exec ("END TRANSACTION");
  }

  /**
   * Called to add a new word plus definition into a source.
   * This method will assume there's no record for that word into the database.
   * If there's row for that word into the database, will fail silently.
   *
   * @param source_id Id of the source where the word will be added
   * @param word Word for the defintion will be added
   * @param definition Well, definition
   */
  public void add_definition (int source_id, string word, string definition) {
    var escaped_word = escape_quote (word);
    var escaped_definition = escape_quote (definition);

    add_word_stmt.bind_int (1, source_id);
    add_word_stmt.bind_text (2, escaped_word);
    add_word_stmt.bind_text (3, escaped_definition);

    add_word_stmt.step ();
    add_word_stmt.clear_bindings ();
    add_word_stmt.reset ();
  }

  string escape_quote (string str) {
    if (str.contains ("'")) {
      return str.replace ("'", "''");
    }
    return str;
  }
}