/*
 * SettingsWindow.vala
 *
 * Copyright 2013 Tony George <teejee@tony-pc>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */

using Gtk;
using Gee;

using TeeJee.Logging;
using TeeJee.FileSystem;
using TeeJee.Devices;
using TeeJee.JsonHelper;
using TeeJee.ProcessHelper;
using TeeJee.GtkHelper;
using TeeJee.System;
using TeeJee.Misc;

class SettingsWindow : Gtk.Window{
	private Gtk.Box vbox_main;
	private Gtk.Notebook notebook;

	private BackupDeviceBox backup_dev_box;
	private ScheduleBox schedule_box;
	private IncludeBox include_box;
	private ExcludeBox exclude_box;
	private FinishBox notes_box;

	private uint tmr_init;

	public SettingsWindow () {

		this.title = _("Settings");
        this.window_position = WindowPosition.CENTER;
        this.modal = true;
        this.set_default_size (500, 500);
		this.icon = get_app_icon(16);

		this.delete_event.connect(on_delete_event);
		
        vbox_main = new Box (Orientation.VERTICAL, 6);
        vbox_main.margin = 12;
        add(vbox_main);

		// add notebook
		notebook = add_notebook(vbox_main, true, true);

		var label = new Gtk.Label(_("Location"));
		backup_dev_box = new BackupDeviceBox(this);
		notebook.append_page (backup_dev_box, label);

		label = new Gtk.Label(_("Schedule"));
		schedule_box = new ScheduleBox(this);
		notebook.append_page (schedule_box, label);

		label = new Gtk.Label(_("Include"));
		include_box = new IncludeBox(this);
		notebook.append_page (include_box, label);

		label = new Gtk.Label(_("Exclude"));
		exclude_box = new ExcludeBox(this, false);
		notebook.append_page (exclude_box, label);

		label = new Gtk.Label(_("Notes"));
		notes_box = new FinishBox(this, true);
		notebook.append_page (notes_box, label);

		// TODO: Add a tab for excluding browser cache and other items

		create_actions();

		//log_debug("ui created");

		show_all();

		tmr_init = Timeout.add(100, init_delayed);
    }

    private bool init_delayed(){

		if (tmr_init > 0){
			Source.remove(tmr_init);
			tmr_init = 0;
		}

		backup_dev_box.refresh();

		return false;
	}
	
	private bool on_delete_event(Gdk.EventAny event){
		
		save_changes();
		
		return false; // close window
	}
	
	private void save_changes(){
		include_box.save_changes();
		exclude_box.save_changes();
		App.cron_job_update();
	}

	private void create_actions(){
		var hbox = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
		hbox.set_layout (Gtk.ButtonBoxStyle.CENTER);
		hbox.margin = 0;
		hbox.margin_top = 6;
        vbox_main.add(hbox);

		Gtk.SizeGroup size_group = null;
		
		// close
		
		var img = new Image.from_stock("gtk-close", Gtk.IconSize.BUTTON);
		var btn_close = add_button(hbox, _("Close"), "", ref size_group, img);

        btn_close.clicked.connect(()=>{
			save_changes();
			this.destroy();
		});
	}
	
	public enum Tabs{
		BACKUP_DEVICE = 0,
		SCHEDULE = 1,
		INCLUDE = 2,
		EXCLUDE = 3,
		NOTES = 4
	}
}


