/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2011-2025 elementary, Inc. (https://elementary.io)
 */

public class Defaults.AppChooserButton : Granite.Bin {
    public string content_type { get; construct; }

    public AppChooserButton (string content_type) {
        Object (
            content_type: content_type
        );
    }

    construct {
        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (factory_setup);
        factory.bind.connect (factory_bind);

        var apps_store = new ListStore (typeof (AppInfo));

        // Ignore result of load so that we always continue to setup the UI widgets
        load_apps (apps_store, content_type);

        var app_expr = new Gtk.ObjectExpression (apps_store);

        var app_name_expr = new Gtk.CClosureExpression (
            typeof (string), null, { app_expr },
            (Callback) get_app_name,
            null, null
        );

        var dropdown = new Gtk.DropDown (apps_store, app_name_expr) {
            factory = factory
        };

        dropdown.selected = find_default_app_pos (apps_store, content_type);

        dropdown.notify["selected-item"].connect (() => run_in_thread (() => {
            var app = (AppInfo) dropdown.selected_item;
            change_default (app, content_type);
            return null;
        }));

        apps_store.bind_property ("n-items", dropdown, "sensitive", DEFAULT | SYNC_CREATE,
            (binding, _n_items, ref _sensitive) => {
                _sensitive = ((uint) _n_items > 0);
                return true;
            }
        );

        child = dropdown;
    }

    private void load_apps (ListStore store, string content_type) {
        store.remove_all ();

        var apps = AppInfo.get_recommended_for_type (content_type);
        if (apps == null) {
            warning ("AppInfo.get_all_for_type() error. content_type=%s", content_type);
            return;
        }

        apps.foreach ((item) => {
            store.append (item);
        });
    }

    private uint find_default_app_pos (ListStore store, string content_type) {
        var default_app = AppInfo.get_default_for_type (content_type, false);
        if (default_app == null) {
            warning ("AppInfo.get_default_for_type() error. content_type=%s", content_type);
            return Gtk.INVALID_LIST_POSITION;
        }

        uint pos;
        bool found = store.find_with_equal_func (default_app,
            ((a, b) => {
                return ((AppInfo) a).get_id () == ((AppInfo) b).get_id ();
            }),
            out pos
        );
        if (!found) {
            // Wouldn't happen, probably all apps store is not initialized
            warning ("BUG: default app not found in all apps store! default_app=%s", default_app.get_id ());
            return Gtk.INVALID_LIST_POSITION;
        }

        return pos;
    }

    private void factory_setup (Object object) {
        var item = object as Gtk.ListItem;

        var row = new AppChooserButtonRow ();
        item.child = row;
    }

    private void factory_bind (Object object) {
        var item = object as Gtk.ListItem;
        var app = item.item as AppInfo;
        var row = item.child as AppChooserButtonRow;

        row.app_icon = app.get_icon ();
        row.app_name = app.get_name ();
    }

    private string get_app_name (AppInfo app) {
        return app.get_name ();
    }

    private void run_in_thread (owned ThreadFunc<void*> func) {
        try {
            new Thread<void*>.try (null, (owned) func);
        } catch (Error e) {
            warning ("Could not create a new thread: %s", e.message);
        }
    }

    private void change_default (AppInfo app, string content_type) {
        var types = get_types_for_app (content_type);
        var supported_types = app.get_supported_types ();

        foreach (unowned var type in types) {
            AppInfo.reset_type_associations (type);
            if (type in supported_types) {
                try {
                    app.set_as_default_for_type (type);
                    debug ("%s now default for content type %s", app.get_name (), type);
                } catch (Error e) {
                    critical ("Error setting default app: %s", e.message);
                }
            } else {
                critical ("%s does not support content type %s", app.get_name (), type);
            }
        }
    }

    private string[] get_types_for_app (string app) {
        switch (app) {
            case "x-scheme-handler/mailto":
            case "text/calendar":
            case "x-scheme-handler/geo":
            case "application/pdf":
                return { app };

            case "x-scheme-handler/https":
                return {
                    "x-scheme-handler/http",
                    "x-scheme-handler/https",
                    "text/html",
                    "application/xhtml+xml",
                };

            case "video/x-ogm+ogg":
                return {
                    "application/x-quicktimeplayer",
                    "application/vnd.rn-realmedia",
                    "application/asx",
                    "application/x-mplayer2",
                    "application/x-ms-wmv",
                    "video/quicktime",
                    "video/x-quicktime",
                    "video/vnd.rn-realvideo",
                    "video/x-ms-asf-plugin",
                    "video/x-msvideo",
                    "video/msvideo",
                    "video/x-ms-asf",
                    "video/x-ms-wm",
                    "video/x-ms-wmv",
                    "video/x-ms-wmp",
                    "video/x-ms-wvx",
                    "video/mpeg",
                    "video/x-mpeg",
                    "video/x-mpeg2",
                    "video/mp4",
                    "video/3gpp",
                    "video/fli",
                    "video/x-fli",
                    "video/x-flv",
                    "video/vnd.vivo",
                    "video/x-matroska",
                    "video/matroska",
                    "video/x-mng",
                    "video/webm",
                    "video/x-webm",
                    "video/mp2t",
                    "video/vnd.mpegurl",
                    "video/x-ogm+ogg"
                };

            case "audio/x-vorbis+ogg":
                return {
                    "audio/ogg",
                    "audio/mpeg",
                    "audio/mp4",
                    "audio/flac",
                    "application/x-musepack",
                    "application/musepack",
                    "application/x-ape",
                    "application/x-id3",
                    "application/ogg",
                    "application/x-ogg",
                    "application/x-vorbis+ogg",
                    "application/x-flac",
                    "application/vnd.rn-realaudio",
                    "application/x-nsv-vp3-mp3",
                    "audio/x-musepack",
                    "audio/musepack",
                    "audio/ape",
                    "audio/x-ape",
                    "audio/x-mp3",
                    "audio/mpeg",
                    "audio/x-mpeg",
                    "audio/x-mpeg-3",
                    "audio/mpeg3",
                    "audio/mp3",
                    "audio/mp4",
                    "audio/x-m4a",
                    "audio/mpc",
                    "audio/x-mpc",
                    "audio/mp",
                    "audio/x-mp",
                    "audio/x-vorbis+ogg",
                    "audio/vorbis",
                    "audio/x-vorbis",
                    "audio/ogg",
                    "audio/x-ogg",
                    "audio/x-flac",
                    "audio/flac",
                    "audio/x-s3m",
                    "audio/x-mod",
                    "audio/x-xm",
                    "audio/x-it",
                    "audio/x-pn-realaudio",
                    "audio/x-realaudio",
                    "audio/x-pn-realaudio-plugin",
                    "audio/x-ms-wmv",
                    "audio/x-ms-wax",
                    "audio/x-ms-wma",
                    "audio/wav",
                    "audio/x-wav",
                    "audio/mpeg2",
                    "audio/x-mpeg2",
                    "audio/x-mpeg3",
                    "audio/x-mpegurl",
                    "audio/basic",
                    "audio/x-basic",
                    "audio/midi",
                    "audio/x-scpls",
                    "audio/webm",
                    "audio/x-webm",
                    "x-content/audio-player"
                };

            case "image/jpeg":
                return {
                    "image/jpeg",
                    "image/jpg",
                    "image/pjpeg",
                    "image/png",
                    "image/tiff",
                    "image/x-3fr",
                    "image/x-adobe-dng",
                    "image/x-arw",
                    "image/x-bay",
                    "image/x-bmp",
                    "image/x-canon-cr2",
                    "image/x-canon-crw",
                    "image/x-cap",
                    "image/x-cr2",
                    "image/x-crw",
                    "image/x-dcr",
                    "image/x-dcraw",
                    "image/x-dcs",
                    "image/x-dng",
                    "image/x-drf",
                    "image/x-eip",
                    "image/x-erf",
                    "image/x-fff",
                    "image/x-fuji-raf",
                    "image/x-iiq",
                    "image/x-k25",
                    "image/x-kdc",
                    "image/x-mef",
                    "image/x-minolta-mrw",
                    "image/x-mos",
                    "image/x-mrw",
                    "image/x-nef",
                    "image/x-nikon-nef",
                    "image/x-nrw",
                    "image/x-olympus-orf",
                    "image/x-orf",
                    "image/x-panasonic-raw",
                    "image/x-pef",
                    "image/x-pentax-pef",
                    "image/x-png",
                    "image/x-ptx",
                    "image/x-pxn",
                    "image/x-r3d",
                    "image/x-raf",
                    "image/x-raw",
                    "image/x-raw",
                    "image/x-rw2",
                    "image/x-rwl",
                    "image/x-rwz",
                    "image/x-sigma-x3f",
                    "image/x-sony-arw",
                    "image/x-sony-sr2",
                    "image/x-sony-srf",
                    "image/x-sr2",
                    "image/x-srf",
                    "image/x-x3f"
                };

            case "text/plain":
                return {
                    "application/xml",
                    "application/x-perl",
                    "text/mathml",
                    "text/plain",
                    "text/xml",
                    "text/x-c++hdr",
                    "text/x-c++src",
                    "text/x-xsrc",
                    "text/x-chdr",
                    "text/x-csrc",
                    "text/x-dtd",
                    "text/x-java",
                    "text/x-python",
                    "text/x-sql"
                };

            case "inode/directory":
                return {
                    "inode/directory",
                    "x-directory/normal",
                    "x-directory/gnome-default-handler"
                };

            default:
                return {};
        }
    }
}
