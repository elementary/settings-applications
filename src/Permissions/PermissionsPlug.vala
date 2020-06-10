/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Permissions.Plug : Gtk.Grid {
    public static GLib.HashTable <unowned string, unowned string> permission_names { get; private set; }

    static construct {
        permission_names = new GLib.HashTable <unowned string, unowned string> (str_hash, str_equal);
        permission_names["filesystems=home"] = _("Home Folder");
        permission_names["filesystems=host"] = _("System Folders");
        permission_names["devices=all"] = _("Devices");
        permission_names["shared=network"] = _("Network");
        permission_names["features=bluetooth"] = _("Bluetooth");
        permission_names["sockets=cups"] = _("Printing");
        permission_names["sockets=ssh-auth"] = _("Secure Shell Agent");
        permission_names["devices=dri"] = _("GPU Acceleration");
    }

    construct {
        var app_list = new Gtk.ListBox ();
        app_list.vexpand = true;
        app_list.selection_mode = Gtk.SelectionMode.SINGLE;

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (app_list);

        var frame = new Gtk.Frame (null);
        frame.halign = Gtk.Align.START;
        frame.width_request = 240;
        frame.add (scrolled_window);

        Permissions.Backend.AppManager.get_default ().apps.foreach ((id, app) => {
            var app_entry = new Permissions.SidebarRow (app);
            app_list.add (app_entry);
        });

        List<weak Gtk.Widget> children = app_list.get_children ();
        if (children.length () > 0) {
            var row = ((Gtk.ListBoxRow)children.nth_data (0));

            app_list.select_row (row);
            show_row (row);
        }

        var app_settings_view = new Widgets.AppSettingsView ();

        column_spacing = 12;
        margin = 12;
        margin_top = 0;
        add (frame);
        add (app_settings_view);
        show_all ();

        app_list.row_selected.connect (show_row);
    }

    private void show_row (Gtk.ListBoxRow? row) {
        if (row == null || !(row is Permissions.SidebarRow)) {
            return;
        }

        Permissions.Backend.AppManager.get_default ().selected_app = ((Permissions.SidebarRow)row).app.id;
    }
}
