/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2011-2025 elementary, Inc. (https://elementary.io)
 */

public class AppChooserButtonRow : Gtk.Box {
    public Icon app_icon { get; set; }
    public string app_name { get; set; }

    construct {
        orientation = HORIZONTAL;

        var icon = new Gtk.Image () {
            halign = START
        };

        var label = new Gtk.Label (null) {
            halign = START,
            hexpand = true,
            ellipsize = END
        };

        bind_property ("app-icon", icon, "gicon");
        bind_property ("app-name", label, "label");

        append (icon);
        append (label);
    }
}
