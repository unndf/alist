#!/usr/bin/env tclsh

package require sqlite3
package require Tk

namespace eval db_handler {
    if {[catch {sqlite3 list_db list.db -create 0} ]} {
        sqlite3 list_db list.db -create 1
        list_db eval {CREATE TABLE anime( anime_title text,
                                   no_eps int,
                                   no_eps_watched int,
                                   eps_titles text,
                                   descr text,
                                   rating text,
                                   type text,
                                   status text,
                                   notes text
                                   )}
    }
    proc mark_completed {id rating notes} {
    }
    proc add_backlog {id eps_no notes} {
    }
    proc remove_backlog {id} {
    }
    proc add_anime {id anime_title no_eps eps_title descr notes} {
    }
    proc remove_anime {id} {
    }
    proc cleanup {} {
        list_db close
    }
    proc search_db {phrase} {
    }
    proc get_completed {} {
    }
    proc get_backlog {} {
    }
    proc get_anime_list {} {
        return [list_db eval {SELECT * FROM anime}]
    }
    proc add_title {title no_eps no_eps_watched eps_titles descr rating type status notes} {
        list_db eval {INSERT INTO anime (anime_title, no_eps, no_eps_watched, eps_titles, descr, rating, type, status, notes)
                             VALUES($title, $no_eps, $no_eps_watched, $eps_titles, $desr, $rating,$type, $status, $notes)
                     }
    }

}
namespace eval alist_gui {
    proc add_dialog {} { 
        #ensure that only a single add_window is open at a time
        if [expr ![catch {toplevel .add_window } ] ] {
            wm title .add_window "Add Title to Database"
            ttk::button .add_window.submit -text "Submit"
            ttk::label .add_window.titlelab -text "Title"
            ttk::entry .add_window.titleen
            ttk::label .add_window.no_epslab -text "No. Episodes"
            ttk::entry .add_window.no_epsen
            ttk::label .add_window.eps_titleslab -text "Episode Titles"
            ttk::entry .add_window.eps_titlesen
            ttk::label .add_window.desclab -text "Title"
            ttk::text .add_window.descrbox
            ttk::label .add_window.typelab -text "Type"
            ttk::listbox .add_window.typebox

            grid .add_window.submit -row 2 -column 0
            grid .add_window.titlelab -row 0 -column 0
            grid .add_window.titleen -row 0 -column 1
        }
    }
    proc start {} { 
#--------Create GUI components---------
    wm title . "alist"

    ttk::notebook .tabs
    ttk::frame .tabs.collection
    ttk::frame .tabs.list

#--------Create Frames----------------
    ttk::frame .tabs.collection.rightpane 
    ttk::frame .tabs.collection.leftlist

    .tabs add .tabs.collection -text "Collection"
    .tabs add .tabs.list -text "List"

#--------Fill frames with Widgets-----
    ttk::button .tabs.collection.rightpane.addbutton -text "add" -command alist_gui::add_dialog
    grid .tabs.collection.rightpane.addbutton -column 0 -row 0
    ttk::treeview .tabs.collection.rightpane.list -columns "series type genre no_eps watched" -show "headings"
    .tabs.collection.rightpane.list heading series -text Series
    .tabs.collection.rightpane.list heading type -text Type
    .tabs.collection.rightpane.list heading genre -text Genre
    .tabs.collection.rightpane.list heading no_eps -text Episodes
    .tabs.collection.rightpane.list heading watched -text Watched

    grid .tabs.collection.rightpane.list -column 1 -row 0 -sticky nsew 

#--------Configure Grid---------------
    grid columnconfigure . 0 -weight 1
    grid .tabs -column 0 -row 0 -sticky nsew
    grid .tabs.collection.rightpane -column 0 -row 0 -padx 10 -pady 10 -sticky nsew 
    grid .tabs.collection.leftlist -column 1 -row 0 -padx 10 -pady 10

    ::db_handler::add_title "generic anime" 12 0 " " " "  1 "TV" " " " " 
    puts [::db_handler::get_anime_list]   }
}

alist_gui::start
