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

public class Words.StardictSourceLoader : Object, SourceLoader {
  string ifo_file;
  string idx_file;
  string dict_file;

  string bookname;
  int wordcount;
  int idxfilesize;
  string sametypesequence;

  /* others */
  private string description;
  private string date;

  public bool open (string source_path) {
    /* FIXME: Let's for now assume we alredy unpacked the thing */
    try {
      string filename;
      var dir = Dir.open (source_path);
      /* FIXME: Check for every dict file with the same name */
      while ((filename = dir.read_name ()) != null) {
        if (filename.has_suffix (".ifo")) {
          ifo_file = Path.build_filename (source_path, filename);
        } else if (filename.has_suffix (".idx") ||
                   filename.has_suffix (".idx.gz")) {
          idx_file = Path.build_filename (source_path, filename);
        } else if (filename.has_suffix (".dict") ||
                   filename.has_suffix (".dict.dz")) {
          dict_file = Path.build_filename (source_path, filename);
        }
      }

      if (ifo_file == null ||
          idx_file == null ||
          dict_file == null) {
        return false;
      }

      /* reading data: ifo file */

      var regex = new Regex (".*=");

      var file = File.new_for_path (ifo_file);
      var dis = new DataInputStream (file.read ());
      string line;
      while ((line = dis.read_line (null)) != null) {
        if (line.has_prefix ("bookname")) {
          bookname = regex.replace (line, -1, 0, "");
        } else if (line.has_prefix ("wordcount")) {
          wordcount = int.parse (regex.replace (line, -1, 0, ""));
        } else if (line.has_prefix ("idxfilesize")) {
          idxfilesize = int.parse (regex.replace (line, -1, 0, ""));
        } else if (line.has_prefix ("sametypesequence")) {
          sametypesequence = regex.replace (line, -1, 0, "");
        } else if (line.has_prefix ("description")) {
          description = regex.replace (line, -1, 0, "");
        } else if (line.has_prefix ("date")) {
          date = regex.replace (line, -1, 0, "");
        }
      }
    } catch {
      return false;
    }

    return true;
  }

  public void load (StorageManager storage_manager) {
    int source_id = storage_manager.create_source (bookname, true);
    if (source_id != -1) {
      /* opening idx,dict file */
      /* FIXME: if idx,dict files are dictzipped should be unzipped before opening
       * for reading */
      var infile = File.new_for_path (idx_file);
      var idx_stream = new DataInputStream (infile.read ());
      var file_stream = File.new_for_path (dict_file).read ();

      size_t read_chars;
      string word;
      uint def_offset;
      uint def_size;

     storage_manager.start_insertions ();
      for (int i = 0; i < wordcount; i++) {
        word = idx_stream.read_upto ("\0", 1, out read_chars);
        idx_stream.skip (1);
        def_offset = idx_stream.read_uint32 ();
        def_size = idx_stream.read_uint32 ();

        uint8[] buffer = new uint8[def_size];

        file_stream.seek (def_offset, SeekType.SET);
        file_stream.read (buffer);

        /* will gather def into builder.str */
        var builder = new StringBuilder ();

        for (int j = 0; j < def_size; j++) {
          builder.append_c ((char) buffer[j]);
        }

       storage_manager.add_definition (source_id, word, builder.str);
      }
     storage_manager.end_insertions ();
    }
  }
}