/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 elementary, Inc. (https://elementary.io)
 *
 * Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
 */

public class Permissions.SidebarRow : Gtk.ListBoxRow {
    public Permissions.Backend.App app { get; construct; }
    private Granite.HeaderLabel header_label;

    public SidebarRow (Permissions.Backend.App app) {
        Object (app: app);
    }

    construct {
        var image = new Gtk.Image.from_gicon (app.icon) {
            pixel_size = 32
        };

        header_label = new Granite.HeaderLabel (app.name) {
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
