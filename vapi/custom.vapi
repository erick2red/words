[CCode (cprefix = "Gtk", lower_case_cprefix = "gtk_")]
namespace Gtk {
	[CCode (cname = "gtk_builder_add_from_resource")]
	public static unowned uint my_builder_add_from_resource (Gtk.Builder builder, string path) throws GLib.Error;
}
