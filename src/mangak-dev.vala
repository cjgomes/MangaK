/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * main.c
 * Copyright (C) 2015 Carlos Gomes <cjgomes@gmail.com>
 * 
 * mangaK-dev is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * mangaK-dev is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace MangaK {

public class MangaK : Granite.Application {

    Gtk.Window                  window;
    Gtk.Stack                   main_stack;

    Gtk.HeaderBar               headerbar;
    //Gtk.Button                chooseArt;
    Granite.Widgets.AppMenu 	newButton;
    Gtk.Image                   image;
    Gtk.Paned                   paned;
    Gtk.ActionGroup             main_actions;
    Granite.Widgets.ModeButton  view_mode;
    Granite.Widgets.ModeButton  viewer_mode;
    Granite.Widgets.ModeButton  nav_mode;
    Gtk.ScrolledWindow          scrolled_image;
    Gtk.ListStore               liststore;
    Gtk.TreeView                treeview;
    Gtk.ScrolledWindow          scrolled_thumbs;
    Gtk.Revealer                revealer;
    Gtk.EventBox                eventbox_image;
    Gtk.Adjustment              hadj;
    Gtk.Adjustment              vadj;
    Gdk.Pixbuf                  pixbuf;
    Gdk.Pixbuf                  pixbuf_scaled;
    
    
    double zoom = 1.00;
    int pixbuf_width;
    int pixbuf_height;
    bool list_visible;
    string file;
    string basename; 
    
    
    
    construct {
        application_id = "org.pantheon.mangaK";
        flags = ApplicationFlags.FLAGS_NONE;

        program_name = "MangaK";
        app_years = "2015";

        build_version = "0.1";
        app_icon = "default";
        main_url = "";
        bug_url = "";
        help_url = "";
        translate_url = "";

        about_documenters = { null };
        about_artists = { "Carlos Gomes <cjgomes.it@gmail.com>" };
        about_authors = {
            "Carlos Gomes <cjgomes.it@gmail.com>"
        };

        about_comments = "A manga reader app for elementary OS";
        about_translators = "Launchpad Translators";
        about_license_type = Gtk.License.GPL_3_0;
    }
    
    public override void activate () {
        window = new Gtk.Window();
        window.window_position = Gtk.WindowPosition.CENTER;
        add_window (window);
        
        //Allow dark theme to this app
		//Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
        
        main_stack = new Gtk.Stack();
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
   
   
        create_headerbar();
        create_welcome();
        create_content();
        
        
        window.add (main_stack);
        window.set_default_size (800, 500);
        window.show_all ();
        viewer_mode.hide();
        view_mode.hide();
        nav_mode.hide();
    }     

    private void create_headerbar() {
        headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true; 
        headerbar.set_title ("Mangak");
        headerbar.set_subtitle ("Manga Reader");
        
        //Button on headerbar to open file
        /*chooseArt = new Gtk.Button.from_icon_name("document-open",Gtk.IconSize.LARGE_TOOLBAR);
        chooseArt.clicked.connect(show_file_dialog);
        chooseArt.set_tooltip_text("Open Document");*/
        
        var accel_group = new Gtk.AccelGroup();
        
        Gtk.Menu newModel = new Gtk.Menu ();
		newModel.set_accel_group(accel_group);
		
		Gtk.MenuItem preferences = new Gtk.MenuItem.with_label ("Preferences");
		preferences.activate.connect(() =>{
			create_preferences();
		});
		newModel.add(preferences);
		
		newButton = new Granite.Widgets.AppMenu(newModel);
		newButton.set_stock_id("new");
        
        view_mode = new Granite.Widgets.ModeButton ();
        view_mode.append_icon ("view-dual-symbolic", Gtk.IconSize.BUTTON);
        view_mode.append_icon ("view-paged-symbolic", Gtk.IconSize.BUTTON);
        
        viewer_mode = new Granite.Widgets.ModeButton();
        viewer_mode.append_icon ("zoom-fit-best-symbolic", Gtk.IconSize.BUTTON);
        viewer_mode.append_icon ("zoom-original-symbolic", Gtk.IconSize.BUTTON);
        viewer_mode.append_icon ("zoom-in-symbolic", Gtk.IconSize.BUTTON);
        
        nav_mode = new Granite.Widgets.ModeButton ();
        nav_mode.append_icon ("go-first-symbolic", Gtk.IconSize.BUTTON);
        nav_mode.append_icon ("go-previous-symbolic", Gtk.IconSize.BUTTON );
        nav_mode.append_icon ("go-next-symbolic", Gtk.IconSize.BUTTON);
        nav_mode.append_icon ("go-last-symbolic", Gtk.IconSize.BUTTON);

        headerbar.pack_start(view_mode);
        headerbar.pack_start(nav_mode);
        //headerbar.pack_start(chooseArt);
        headerbar.pack_end(newButton);
        headerbar.pack_end(viewer_mode);
        window.set_titlebar(headerbar);
    }
    
    private void create_welcome(){
        var welcome  = new Granite.Widgets.Welcome ("No Mangas Open", "Select a chapter to begin reading.");
        welcome.append ("document-open", "Open file", "Open a saved file.");
        welcome.activated.connect ((index) => {
            switch (index) {
            case 0:
                view_mode.show();
                nav_mode.show();
                viewer_mode.show();
                open_file_dialog();
                main_stack.set_visible_child_name ("content");
                break;
            default:
                break;
            }
        });
        
        
       main_stack.add_named (welcome, "welcome");
    }
    
        
    public void create_content(){
    
        image = new Gtk.Image ();
        
        //var viewport = new Gtk.Viewport(null, null);
        
        //paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
        paned.set_position(150);
        scrolled_image = new Gtk.ScrolledWindow (null, null);
        scrolled_image.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_image.expand = true;
        scrolled_image.set_size_request(200, 0);
        scrolled_image.add(image);
          
         //viewport.add (image);
       
        
        
        liststore = new Gtk.ListStore(3, typeof (Gdk.Pixbuf), typeof (string), typeof (string));

        treeview = new Gtk.TreeView();
        treeview.set_model(liststore);
        treeview.set_headers_visible(false);
        treeview.set_activate_on_single_click(true);
        treeview.row_activated.connect(show_selected_image);
        treeview.insert_column_with_attributes (1, ("Preview"), new Gtk.CellRendererPixbuf(), "pixbuf");
        
        scrolled_thumbs = new Gtk.ScrolledWindow (null,null);
        scrolled_thumbs.add(treeview);
        
        eventbox_image = new Gtk.EventBox();
        eventbox_image.add(scrolled_image);
        eventbox_image.show();
        
        //paned.add1(scrolled_thumbs);
        //paned.add2(eventbox_image);
        
        revealer = new Gtk.Revealer();
        revealer.add(scrolled_thumbs);
        revealer.set_reveal_child(true);
        revealer.set_transition_duration(300);
        revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_LEFT);
        
        var grid = new Gtk.Grid();
        grid.attach(revealer, 0, 0, 1, 1);
        grid.attach_next_to(eventbox_image, revealer, Gtk.PositionType.RIGHT, 1, 1);
        
        hadj = scrolled_image.get_hadjustment();
        vadj = scrolled_image.get_vadjustment();
        
        main_stack.add_named(grid, "content");
    }
    
    public override void open(File[] files, string hint)
    {
        activate();
        foreach (File f in files)
        {
            file = f.get_path();
        }

        list_images(Path.get_dirname(file));
    }
    
    // Treeview
    private void list_images(string directory)
    {
        try {
            liststore.clear();
            Environment.set_current_dir(directory);
            var d = File.new_for_path(directory);
            var enumerator = d.enumerate_children(FileAttribute.STANDARD_NAME, 0);
            FileInfo info;
            while((info = enumerator.next_file()) != null) {
                string output = info.get_name();
                var file_check = File.new_for_path(output);
                var file_info = file_check.query_info("standard::content-type", 0, null);
                string content = file_info.get_content_type();
                if ( content.contains("image")) {
                    string fullpath = directory + "/" + output;
                    Gdk.Pixbuf pixbuf = null;
                    Gtk.TreeIter? iter = null;
                    load_thumbnail.begin(fullpath, (obj, res) =>
                    {
                        pixbuf = load_thumbnail.end(res);
                        liststore.append(out iter);
                        liststore.set(iter, 0, pixbuf, 1, fullpath, 2, output, -1);
                        if (file == fullpath) {
                            treeview.get_selection().select_iter(iter);
                            Gtk.TreePath path = treeview.get_model().get_path(iter);
                            treeview.scroll_to_cell(path, null, false, 0, 0);
                        }
                    });
                }
            }
            treeview.grab_focus();
        } catch(Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
    }
    
    private async Gdk.Pixbuf load_thumbnail(string name)
    {
        Gdk.Pixbuf? pix = null;
        var file = GLib.File.new_for_path(name);
        try
        {
            GLib.InputStream stream = yield file.read_async();
            pix = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, 140, 100, true, null);
        }
        catch (Error e)
        {
            stderr.printf("%s\n", e.message);
        }
        return pix;
    }
    
    private void load_pixbuf_with_size(int pixbuf_width, int pixbuf_height)
    {
        try
        {
            pixbuf = new Gdk.Pixbuf.from_file(file);
            if (pixbuf.get_width() <= 400)
            {
                pixbuf_scaled = pixbuf;
                zoom = 1.00;
                image.set_from_pixbuf(pixbuf);
            }
            else
            {
                try
                {
                    pixbuf_scaled = new Gdk.Pixbuf.from_file_at_size(file, pixbuf_width, pixbuf_width);
                    zoom = (double)pixbuf_scaled.get_width() / pixbuf.get_width();
                    image.set_from_pixbuf(pixbuf_scaled);
                }
                catch(Error error)
                {
                    stderr.printf("error: %s\n", error.message);
                }
            }
            //update_title();
            
        }
        catch(Error error)
        {
            stderr.printf("error: %s\n", error.message);
        }
    }
    
    // load pixbuf on start
    private void load_pixbuf_on_start()
    {
        int width, height;
        window.get_size(out width, out height);
        if ((window.get_window().get_state() & Gdk.WindowState.FULLSCREEN) != 0)
        {
            pixbuf_width = width;
            pixbuf_height = height;
        }
        else
        {
            pixbuf_width = scrolled_image.get_allocated_width();
            pixbuf_height = scrolled_image.get_allocated_height();
        }
        load_pixbuf_with_size(pixbuf_width, pixbuf_height);
    }

    private void show_selected_image()
    {
        Gtk.TreeIter iter;
        Gtk.TreeModel model;
        var selection = treeview.get_selection();
        selection.get_selected(out model, out iter);
        model.get(iter, 1, out file);
        load_pixbuf_on_start();
    }
    
    public void create_preferences(){
    var preferences = new Gtk.Dialog();
    //preferences.set_size_request (400, 500);
    //preferences.set_modal (true);
         
    preferences.get_content_area ().add (dialog_ui());
    preferences.show_all ();
    
        }
        
        private Gtk.Widget dialog_ui () {
            
            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.row_spacing = 6;
            grid.column_spacing = 6;
  
            var label = new Gtk.Label ("Mostrar thumbnails");
  
             
  
        
            Gtk.Switch _switch = new Gtk.Switch ();
		    //window.add (_switch);
    
		    _switch.notify["active"].connect (() => {
			if (_switch.active) {
				revealer.set_reveal_child(true);
                list_visible = true;
			} else {
				revealer.set_reveal_child(false);
                list_visible = false;
			}
		});
    
		// Changes the state to on:
		_switch.set_active (true);
		grid.attach (label, 0, 0, 1, 1);
        grid.attach_next_to (_switch, label, Gtk.PositionType.RIGHT, 1, 1);
//grid.add (label);
//grid.add (_switch);
    
            return grid;
        }
    
    /*private void action_reveal_thumbs()
    {
        if (list_visible == false)
        {
            revealer.set_reveal_child(true);
            list_visible = true;
        }
        else
        {
            revealer.set_reveal_child(false);
            list_visible = false;
        }
    }*/
    
 private void open_file_dialog(){
     var filter = new Gtk.FileFilter ();
     var dialog = new Gtk.FileChooserDialog ("Open File",
                                   window,
                                   Gtk.FileChooserAction.OPEN,
                                   "_Cancel",
                                   Gtk.ResponseType.CANCEL,
                                   "_Open",
                                   Gtk.ResponseType.ACCEPT);
     //dialog.set_select_multiple(true);
     filter.add_pixbuf_formats ();
     dialog.add_filter (filter);
     //set preview sidebar on filechooser dialog
     var preview = new Gtk.Image();
     preview.valign = Gtk.Align.CENTER;
     dialog.set_preview_widget (preview);
     dialog.update_preview.connect(()=> {

         string filename = dialog.get_preview_filename();
         Gdk.Pixbuf pix = null;

         try {
             pix = new Gdk.Pixbuf.from_file_at_size(filename, 128, 128);
		} catch (GLib.Error error) {
              warning("There was a problem loading preview.");
	    }

         if(pix!=null){
             preview.set_from_pixbuf(pix);
             dialog.set_preview_widget_active(true);
         }
     });
     
     if (file != null)
     {
         dialog.set_current_folder(Path.get_dirname(file));
     }
     if (dialog.run() == Gtk.ResponseType.ACCEPT)
     {
         file = dialog.get_filename();
         list_images(Path.get_dirname(file));
     }
     dialog.destroy();
 }
    
    
    private void open_folder_dialog(){
        	var file_chooser = new Gtk.FileChooserDialog ("Open Folder",
        	                          window,
                                      Gtk.FileChooserAction.SELECT_FOLDER,
                                      "_Cancel", Gtk.ResponseType.CANCEL,
                                      "_OK", Gtk.ResponseType.ACCEPT);

	        if (file_chooser.run () == Gtk.ResponseType.ACCEPT) {
	            var docName = file_chooser.get_filename();
				//image.set_from_file (docName);
				stdout.printf (docName);
	        }
	        file_chooser.destroy ();
        }
       

    public static int main (string[] args) {
        var application = new MangaK ();
        return application.run (args);
    }
}
}
