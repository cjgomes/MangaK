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

    Gtk.Window          window;
    Gtk.Stack           main_stack;

    Gtk.HeaderBar       headerbar;
    //Gtk.Button        chooseArt;
    Gtk.Image           image;
    Gtk.ActionGroup     main_actions;
    Granite.Widgets.ModeButton  view_mode;
    Granite.Widgets.ModeButton  viewer_mode;
    Granite.Widgets.ModeButton  nav_mode;
    
    
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
        
        var viewport = new Gtk.Viewport(null, null);
        
        
         var scrolled = new Gtk.ScrolledWindow (null, null);
         scrolled.add(viewport);
          
         viewport.add (image);
        main_stack.add_named(scrolled, "content");
    }
    
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
     
     switch (dialog.run ())
 	{
 		case Gtk.ResponseType.ACCEPT:
 			var filename = dialog.get_filename ();
 			image.set_from_file (filename);
 			//stdout.printf (filename);
 			break;
 		case Gtk.ResponseType.CANCEL:
 			break;
 	}
 	dialog.destroy ();
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
