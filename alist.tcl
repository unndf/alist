#!/usr/bin/env tclsh

package require sqlite3
package require Tk

namespace eval db_handler {
    if {[catch {sqlite3 list_db list.db -create 0} ]} {
        sqlite3 list_db list.db -create 1
        list_db eval {CREATE TABLE anime( anime_title text,
                                   no_eps int,
                                   no_eps_watched int,
                                   descr text,
                                   rating text,
                                   status text,
                                   notes text
                                   )}
    }
    proc remove_anime {id} {
        list_db eval {DELETE FROM anime WHERE rowid == id}
    }
    proc cleanup {} {
        list_db close
    }
    proc search_db {phrase} {
        return [list_db eval {SELECT anime_title FROM anime WHERE anime_title LIKE "%$phrase%"}]
    }
    proc get_completed {} {
        return [list_db eval {SELECT * FROM anime WHERE no_eps_watched == no_eps}]
    }
    proc get_backlog {} {
        return [list_db eval {SELECT * FROM anime WHERE no_eps_watched == 0}]
    }
    proc get_anime_list {} {
        return [list_db eval {SELECT * FROM anime}]
    }
    proc add_title {title no_eps no_eps_watched descr rating status notes} {
        list_db eval {INSERT INTO anime (anime_title, no_eps, no_eps_watched, descr, rating, status, notes)
                             VALUES($title, $no_eps, $no_eps_watched, $desr, $rating, $status, $notes)
                     }
    }
}
#TODO: Actually make the gui look good
namespace eval alist_gui {
    namespace eval event_handlers {
        proc add_dialog {title noeps descr status notes} {
           ::db_handler::add_title $title $noeps 0 $descr 0 $status $notes
        }
    }
    proc add_dialog {} { 
        #ensure that only a single add_window is open at a time
        if [expr ![catch {toplevel .add_window } ] ] {
            wm title .add_window "Add Title to Database"
            ttk::label .add_window.titlelab -text "Title"
            ttk::entry .add_window.titleen
            ttk::label .add_window.no_epslab -text "No. Episodes"
            ttk::entry .add_window.no_epsen
            ttk::label .add_window.descrlab -text "Description" -textvariable descr
            text .add_window.descrbox
            ttk::label .add_window.statuslab -text "Status" 
            listbox .add_window.statusbox 
            .add_window.statusbox insert 0 Watching Backlogged "Plan to Watch"

            ttk::label .add_window.noteslab -text "Description"
            text .add_window.notesbox 

            ttk::button .add_window.submit -text "Submit" 
            
            grid .add_window.submit -row 4 -column 0
            grid .add_window.titlelab -row 0 -column 0
            grid .add_window.titleen -row 0 -column 1
            grid .add_window.no_epslab -row 1 -column 0
            grid .add_window.no_epsen -row 1 -column 1
            grid .add_window.descrlab -row 2 -column 0
            grid .add_window.descrbox -row 2 -column 1
            grid .add_window.statuslab -row 3 -column 0
            grid .add_window.statusbox -row 3 -column 1
        }
    }
    proc populate_list {} {
        #populates the treeview "list" in the GUI
        #test
        #.tabs.collection.rightpane.list insert {} end -id serie  -values {asas asas asasa asa asas}
        #.tabs.collection.rightpane.list insert {} end -id series -text "asasa"
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
    ttk::treeview .tabs.collection.rightpane.list -columns "series no_eps watched status" -show "headings"
    .tabs.collection.rightpane.list heading series -text Series
    .tabs.collection.rightpane.list heading no_eps -text Episodes
    .tabs.collection.rightpane.list heading watched -text Watched
    .tabs.collection.rightpane.list heading status -text Status

    grid .tabs.collection.rightpane.list -column 1 -row 0 -sticky nsew 
    ::alist_gui::populate_list
#--------Configure Grid---------------
    grid columnconfigure . 0 -weight 1
    grid .tabs -column 0 -row 0 -sticky nsew
    grid .tabs.collection.rightpane -column 0 -row 0 -padx 10 -pady 10 -sticky nsew 
    grid .tabs.collection.leftlist -column 1 -row 0 -padx 10 -pady 10

    }
}

alist_gui::start
