#!/usr/bin/env tclsh

package require sqlite3
package require Tk

namespace eval db_handler {
    if {[catch {sqlite3 list_db list.db -create 0} ]} {
        sqlite3 list_db list.db -create 1
        list_db eval {CREATE TABLE anime(id int,
                                   anime_title text,
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
    
}

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
ttk::button .tabs.collection.rightpane.addbutton -text "add"
grid .tabs.collection.rightpane.addbutton -column 0 -row 0
ttk::treeview .tabs.collection.rightpane.list -columns "series type genre no_eps" -show "headings"
.tabs.collection.rightpane.list heading series -text Series
.tabs.collection.rightpane.list heading type -text Type
.tabs.collection.rightpane.list heading genre -text Genre
.tabs.collection.rightpane.list heading no_eps -text Episodes
#.tabs.collection.rightpane.list show "headings"

grid .tabs.collection.rightpane.list -column 1 -row 0 -sticky nsew 

#--------Configure Grid---------------
grid columnconfigure . 0 -weight 1
grid .tabs -column 0 -row 0 -sticky nsew
grid .tabs.collection.rightpane -column 0 -row 0 -padx 10 -pady 10 -sticky nsew 
grid .tabs.collection.leftlist -column 1 -row 0 -padx 10 -pady 10
