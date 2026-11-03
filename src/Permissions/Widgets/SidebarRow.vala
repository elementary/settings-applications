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

public class Permissions.SidebarRow : Granite.ListItem {
    public Permissions.Backend.App app { get; construct; }
    private Granite.HeaderLabel header_label;

    public SidebarRow (Permissions.Backend.App app) {
        Object (app: app);
    }

    construct {
        var image = new Gtk.Image.from_gicon (app.icon) {
            pixel_size = 32
        };

        var header_label = new Granite.HeaderLabel (app.name) {
            ellipsize = END,
            mnemonic_widget = this,
            size = H3,
            valign = CENTER,
            vexpand = true
        };

        var box = new Granite.Box (HORIZONTAL, HALF);
        box.append (image);
        box.append (header_label);

        accessible_role = TAB;
        child = box;
        hexpand = true;
        update_property (Gtk.AccessibleProperty.LABEL, app.name, -1);

        for (var i = 0; i < app.settings.length; i++) {
            app.settings.get (i).notify.connect (update_description);
        }

        update_description ();
    }

    private void update_description () {
        var current_permissions = new GenericArray<string> ();
        for (var i = 0; i < app.settings.length; i++) {
            var settings = app.settings.get (i);
            if (settings.enabled) {
                current_permissions.add (Backend.App.permission_names[settings.context]);
            }
        }

        if (current_permissions.length > 0) {
            /// Translators: This is a delimiter that separates types of permissions in the sidebar description
            var description = string.joinv (_(", "), current_permissions.data);
            header_label.secondary_text = description;
            tooltip_text = description;
        } else {
            header_label.secondary_text = null;
            tooltip_text = null;
        }
    }
}
