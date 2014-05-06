#!/usr/bin/env tclsh

package require sqlite3
package require Tk

proc init_db {} {
    if {[catch {sqlite3 list_db list.db -create 0} ]} {
        sqlite3 list_db list.db -create 1
        list_db eval {CREATE TABLE queue(title text,position int,episode_name text,episode_number int,notes text)}
        list_db eval {CREATE TABLE completed(title text,episode_name text,episode_num int,num_episodes int,notes text)}
        list_db eval {CREATE TABLE backlog(title text,position int,episode_name text,episode_number int,notes text)}
    }
    return list_db
}


#--------Create GUI components---------
wm title . "alist"

ttk::notebook .tabs
ttk::frame .tabs.completed
ttk::frame .tabs.progress

.tabs add .tabs.completed -text "Completed"
.tabs add .tabs.progress -text "In Progress"


#--------Configure Grid----------------
grid columnconfigure . 0 -weight 1
grid .tabs -column 0 -row 0 -sticky nsew
set list_db [init_db]
