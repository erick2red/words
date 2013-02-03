// This file is part of GNOME Boxes. License: LGPLv2+
using Config;

namespace Words {
    public string get_user_pkgdata (string? file_name = null) {
        var dir = Path.build_filename (Environment.get_user_data_dir (), Config.PACKAGE_NAME);

        ensure_directory (dir);

        return Path.build_filename (dir, file_name);
    }

    public string get_utf8_basename (string path) {
        var file = File.new_for_path (path);
        string name = file.get_parse_name ();
        try {
            var info = file.query_info (FileAttribute.STANDARD_DISPLAY_NAME, 0);
            name = info.get_display_name ();
        } catch (GLib.Error e) {
        }
        return name;
    }

    public void ensure_directory (string dir) {
        try {
            var file = GLib.File.new_for_path (dir);
            file.make_directory_with_parents (null);
        } catch (IOError.EXISTS error) {
        } catch (GLib.Error error) {
            warning (error.message);
        }
    }

    public void delete_file (File file) throws GLib.Error {
        try {
            debug ("Removing '%s'..", file.get_path ());
            file.delete ();
            debug ("Removed '%s'.", file.get_path ());
        } catch (IOError.NOT_FOUND e) {
            debug ("File '%s' was already deleted", file.get_path ());
        }
    }

    public delegate bool ForeachFilenameFromDirFunc (string filename) throws GLib.Error;

    public async void foreach_filename_from_dir (File dir, ForeachFilenameFromDirFunc func) {
        try {
            var enumerator = yield dir.enumerate_children_async (FileAttribute.STANDARD_NAME, 0);
            while (true) {
                var files = yield enumerator.next_files_async (10);
                if (files == null)
                    break;

                foreach (var file in files) {
                    if (func (file.get_name ()))
                        break;
                }
            }
        } catch (GLib.Error error) {
            warning (error.message);
        }
    }
}
