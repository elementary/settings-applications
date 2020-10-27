/*
* Copyright 2013-2017 elementary, Inc. (https://elementary.io)
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
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

public class Startup.Controller : Object {
    public Startup.Plug view { get; construct; }

    private const string APPLICATION_DIRS = "applications";

    public Controller (Startup.Plug view) {
        Object (view: view);
    }

    construct {
        foreach (unowned string path in get_auto_start_files ()) {
            var key_file = get_key_file_from_path (path);
            if (key_file.show) {
                view.add_app (key_file.create_app_info ());
            }
        }

        var app_infos = new Gee.ArrayList <Entity.AppInfo?> ();
        foreach (unowned string path in get_application_files ()) {
            var key_file = get_key_file_from_path (path);
            if (key_file.show) {
                app_infos.add (key_file.create_app_info ());
            }
        }

        view.init_app_chooser (app_infos);
    }

    public void delete_file (string path) {
        var key_file = get_key_file_from_path (path);
        key_file.delete_file ();
    }

    public void edit_file (string path, bool active) {
        var key_file = get_key_file_from_path (path);
        key_file.active = active;
        key_file.write_to_file ();
    }

    public void create_file (string path) {
        var key_file = get_key_file_from_path (path);
        key_file.active = true;
        key_file.copy_to_local ();
        var app_info = key_file.create_app_info ();
        view.add_app (app_info);
    }

    public void create_file_from_command (string command) {
        var key_file = new Backend.KeyFile.from_command (command);
        var app_info = key_file.create_app_info ();
        view.add_app (app_info);
    }

    public static Backend.KeyFile get_key_file_from_path (string path) {
        return Backend.KeyFileFactory.get_or_create (path);
    }

    private string[] get_application_files () {
        string[] app_dirs = {};

        var data_dirs = Environment.get_system_data_dirs ();
        data_dirs += Environment.get_user_data_dir ();
        foreach (unowned string data_dir in data_dirs) {
            var app_dir = Path.build_filename (data_dir, APPLICATION_DIRS);
            if (FileUtils.test (app_dir, FileTest.EXISTS)) {
                app_dirs += app_dir;
            }
        }

        if (app_dirs.length == 0) {
            warning ("No application directories found");
        }

        var enumerator = new Backend.DesktopFileEnumerator (app_dirs);
        return enumerator.get_desktop_files ();
    }

    private string[] get_auto_start_files () {
        var startup_dir = Utils.get_user_startup_dir ();
        var enumerator = new Backend.DesktopFileEnumerator ({ startup_dir });
        return enumerator.get_desktop_files ();
    }
}
