#!/usr/bin/env tclsh

package require sqlite3
package require Tk


namespace eval alist_gui {
#-----Connect to database---------
    if {[catch {sqlite3 alist_db list.db -create 0} ]} {
        sqlite3 alist_db list.db -create 1
        alist_db eval {CREATE TABLE anime(title text,
                                   japanese text,
                                   total_episodes int,
                                   total_watched int,
                                   type text,
                                   description text,
                                   rating text,
                                   status text,
                                   notes text
                                   )}

    }
    proc add_dialog {} { 
        #ensure that only a single add_window is open at a time
        if [expr ![catch {toplevel .add_window } ] ] {
            variable ::title
            variable ::no_eps
            variable ::descr
            variable ::status

            wm title .add_window "Add Title to Database"
            ttk::label .add_window.titlelab -text "Title"
            ttk::entry .add_window.titleen -textvariable title
            ttk::label .add_window.no_epslab -text "No. Episodes"
            ttk::entry .add_window.no_epsen -textvariable no_eps
            ttk::label .add_window.descrlab -text "Description" 
            text .add_window.descrbox 
            ttk::label .add_window.statuslab -text "Status" 
            ttk::combobox .add_window.statusbox -state readonly -textvariable status -values [list "Watching" "On Hold" "Plan to Watch" "Dropped" "Completed"]
            .add_window.statusbox current 0
            ttk::label .add_window.noteslab -text "Description"
            tk::text .add_window.notesbox -width 10 -height 10

            ttk::button .add_window.submit -text "Submit" -command {
                set watched 0
                if { [string equal $status "Completed"] } {
                    set watched $no_eps
                }
                alist_db eval {INSERT INTO anime (title, japanese, total_episodes, total_watched, type, description, rating, status, notes)
                             VALUES($title,"",$no_eps, $watched,"" ,$desr, 0, $status, "")
                }
                set last [alist_db last_insert_rowid]
                alist_db eval {SELECT rowid, * FROM anime WHERE rowid == $last} {
                    .mylist insert {} end -id $rowid -values  [list $title $total_episodes $total_watched $status]
                }
                destroy .add_window
            }
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
        alist_db eval {SELECT rowid, * FROM anime} {
            .mylist insert {} end -id $rowid -values  [list $title $total_episodes $total_watched $status]
        }
    }
    proc start {} { 
#--------Create GUI components---------
    wm title . "alist"
    
    ttk::button .addbutton -text "add" -command alist_gui::add_dialog
    grid .addbutton -column 0 -row 0
    ttk::treeview .mylist -columns "series no_eps watched status" -show "headings"
    .mylist heading series -text Series
    .mylist heading no_eps -text Episodes
    .mylist heading watched -text Watched
    .mylist heading status -text Status

    grid .mylist -column 1 -row 0 -sticky nsew 
    ::alist_gui::populate_list
#--------Configure Grid---------------
    grid columnconfigure . 1 -weight 1
    grid rowconfigure . 0 -weight 1
    }
}
alist_gui::start
