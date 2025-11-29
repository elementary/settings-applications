/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2011-2023 elementary, Inc. (https://elementary.io)
 *
 * Authored by: Akshay Shekher <voldyman666@gmail.com>
 *              Chris Triantafillis <christriant1995@gmail.com>
 */

public class Defaults.Plug : Switchboard.SettingsPage {
    public Plug () {
        Object (
            title: _("Defaults"),
            icon: new ThemedIcon ("preferences-system")
        );
    }

    construct {
        var browser_setting = new SettingsChild (
            _("Web Browser"),
            "x-scheme-handler/https"
        );

        var email_setting = new SettingsChild (
            _("Email Client"),
            "x-scheme-handler/mailto"
        );

        var calendar_setting = new SettingsChild (
            _("Calendar"),
            "text/calendar"
        );

        var videos_setting = new SettingsChild (
            _("Video Player"),
            "video/x-ogm+ogg"
        );

        var music_setting = new SettingsChild (
            _("Music Player"),
            "audio/x-vorbis+ogg"
        );

        var images_setting = new SettingsChild (
            _("Image Viewer"),
            "image/jpeg"
        );

        var text_setting = new SettingsChild (
            _("Text Editor"),
            "text/plain"
        );

        var files_setting = new SettingsChild (
            _("File Browser"),
            "inode/directory"
        );

        var maps_setting = new SettingsChild (
            _("Maps"),
            "x-scheme-handler/geo"
        );

        var flowbox = new Gtk.FlowBox () {
            column_spacing = 24,
            row_spacing = 12,
            homogeneous = true,
            max_children_per_line = 2,
            selection_mode = NONE,
            valign = START
        };
        flowbox.append (browser_setting);
        flowbox.append (music_setting);
        flowbox.append (email_setting);
        flowbox.append (images_setting);
        flowbox.append (calendar_setting);
        flowbox.append (text_setting);
        flowbox.append (videos_setting);
        flowbox.append (files_setting);
        flowbox.append (maps_setting);

        child = flowbox;
        show_end_title_buttons = true;
    }

    private class SettingsChild : Gtk.FlowBoxChild {
        public string label { get; construct; }
        public string content_type { get; construct; }

        private static Gtk.SizeGroup size_group;

        public SettingsChild (string label, string content_type) {
            Object (
                label: label,
                content_type: content_type
            );
        }

        static construct {
            size_group = new Gtk.SizeGroup (HORIZONTAL);
        }

        construct {
            var setting_label = new Granite.HeaderLabel (label);

            var app_chooser = new AppChooserButton (content_type) {
                hexpand = true
            };
            setting_label.mnemonic_widget = app_chooser.get_first_child ();

            var box = new Gtk.Box (VERTICAL, 6);
            box.append (setting_label);
            box.append (app_chooser);

            focusable = false;
            child = box;

            size_group.add_widget (setting_label);
        }
    }
}
