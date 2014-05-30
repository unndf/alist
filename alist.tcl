#!/usr/bin/env tclsh

package require sqlite3
package require Tk
package require Tcl 8.6

namespace eval alist_gui {
#-----Connect to database---------
    #TODO: add user preference table
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
    proc add_dialog {{rwid ""}} { 
        #TODO: Allow grabbing info from MAL and ANILIST
        #ensure that only a single add_window is open at a time
        if [expr ![catch {toplevel .add_window } ] ] {
            variable ::title {}
            variable ::japanese {}
            variable ::no_eps 12
            variable ::watched 0
            variable ::descr {}
            variable ::status {}
            variable ::rating {}
            variable ::rowid {}
            
            set rowid $rwid
            if { [expr {![string equal $rowid ""] } ] } {
                alist_db eval {SELECT rowid, * FROM anime WHERE rowid == $rowid} vals {
                    set title $vals(title)
                    set japanese $vals(japanese)
                    set no_eps $vals(total_episodes)
                    set watched $vals(total_watched)
                    set descr $vals(description)
                    set status $vals(status)
                    set rating $vals(rating)
                    wm title .add_window "Edit Title"
                }
            } else {
                wm title .add_window "Add Title to Database"
            }

            bind .add_window <Destroy> {
                if {"%W" == ".add_window"} {
                    unset title
                    unset japanese
                    unset no_eps
                    unset watched
                    unset descr
                    unset status
                    unset rating
                    unset rowid
                }
            }

            ttk::frame .add_window.leftframe
            ttk::label .add_window.leftframe.titlelab -text "Title"
            ttk::entry .add_window.leftframe.titleen -textvariable title
            ttk::label .add_window.leftframe.japlab -text "Japanese Title"
            ttk::entry .add_window.leftframe.japen -textvariable japanese 
            ttk::label .add_window.leftframe.no_epslab -text "No. Episodes"
            ttk::entry .add_window.leftframe.no_epsen -textvariable no_eps -width 3 -validate focusout -validatecommand {
                return [expr {[string is integer -strict %P] && [expr {%P > 1}] }]
            } -invalidcommand {
                bell
                tk_messageBox -message "Invalid Value for this Field" -icon error -type ok
                %W delete 0 [string length [%W get]]
                %W insert 0 12
                %W select range 0 2
            }
            ttk::label .add_window.leftframe.watchedlab -text "Watched" 
            ttk::entry .add_window.leftframe.watcheden -textvariable watched -width 3 -validate focusout -validatecommand {
                return [expr {[string is integer -strict %P] && [expr {%P <= $no_eps }] && [expr {%P >= 0}] } ]
                } -invalidcommand {
                bell
                tk_messageBox -message "Invalid Value for this Field" -icon error -type ok
                %W delete 0 [string length [%W get]]
                %W insert 0 0
                %W select range 0 1
            }

            ttk::label .add_window.descrlab -text "Description" 
            text .add_window.descrbox -width 40 -height 10
            .add_window.descrbox insert 1.0 $descr
            ttk::label .add_window.statuslab -text "Status" 
            ttk::combobox .add_window.statusbox -state readonly -textvariable status -values [list "Watching" "On Hold" "Plan to Watch" "Dropped" "Completed"]
            .add_window.statusbox current 0
            ttk::label .add_window.ratinglab -text "Rating" 
            ttk::combobox .add_window.ratingbox -state readonly -textvariable rating -values [list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10"]
            .add_window.ratingbox current 0
            
            ttk::label .add_window.noteslab -text "Notes"
            tk::text .add_window.notesbox -width 10 -height 5

            ttk::button .add_window.submit -text "Submit" -command {
                set descr [.add_window.descrbox get 1.0 end]
                if { [string equal $status "Completed"] } {
                    set watched $no_eps
                }
                if {[expr {![string equal $rowid ""]} ]} {
                     alist_db eval {UPDATE anime SET title=$title, japanese=$japanese, total_episodes=$no_eps, total_watched=$watched, description=$descr, rating=$rating, status=$status 
                     WHERE rowid = $rowid 
                     }
                     .mylist set $rowid title $title
                     .mylist set $rowid no_eps $no_eps
                     .mylist set $rowid watched $watched
                     .mylist set $rowid status $status
                } else {
                    alist_db eval {INSERT INTO anime (title, japanese, total_episodes, total_watched, type, description, rating, status, notes)
                                 VALUES($title,$japanese,$no_eps, $watched,"" ,$descr, $rating, $status, "")
                    }
                    set last [alist_db last_insert_rowid]
                    alist_db eval {SELECT rowid, * FROM anime WHERE rowid == $last} {
                        .mylist insert {} end -id $rowid -values  [list $title $total_episodes $total_watched $status $rating] -tags "$rowid $status $rating"
                    }
                }
                .mylist tag bind $rowid <Double-1>  {
                    ::alist_gui::add_dialog [%W focus]
                }

                destroy .add_window
            }
            grid .add_window.leftframe -row 0 -column 0 -ipadx 0 -ipady 0
            grid .add_window.submit -row 4 -column 0 -columnspan 2 -padx 5 -pady 5
            grid .add_window.leftframe.titlelab -row 0 -column 0 -padx 5 -pady 5
            grid .add_window.leftframe.titleen -row 0 -column 1 -padx 10 -pady 5 -sticky W
            grid .add_window.leftframe.japlab -row 1 -column 0 -padx 5
            grid .add_window.leftframe.japen -row 1 -column 1 -padx 10 -pady 5 -sticky W
            grid .add_window.leftframe.no_epslab -row 2 -column 0 -padx 5 
            grid .add_window.leftframe.no_epsen -row 2 -column 1 -padx 10 -pady 5 -sticky W
            grid .add_window.leftframe.watchedlab -row 3 -column 0 -padx 1
            grid .add_window.leftframe.watcheden -row 3 -column 1 -padx 10 -pady 10 -sticky W
            grid .add_window.descrlab -row 0 -column 2 -padx 5
            grid .add_window.descrbox -row 0 -column 3 -padx 10 -pady 5
            grid .add_window.statuslab -row 1 -column 2 -pady 2
            grid .add_window.statusbox -row 1 -column 3 -pady 2
            grid .add_window.ratinglab -row 2 -column 2 -pady 2
            grid .add_window.ratingbox -row 2 -column 3 -pady 2
        }
    }
    proc populate_list {} {
        alist_db eval {SELECT rowid, * FROM anime} {
            .mylist insert {} end -id $rowid -values  [list $title $total_episodes $total_watched $status $rating] -tags "$rowid $status $rating"
            .mylist tag bind $rowid <Double-1>  {
                ::alist_gui::add_dialog [%W focus]
            }
        }
    }
    proc start {} { 
#--------Create GUI components---------
        wm title . "alist"
        option add *tearOff 0 ;#disable menu tearoff

        menu .menubar 
        menu .menubar.file
        menu .menubar.edit
        .menubar add cascade -menu .menubar.file -label File
        .menubar add cascade -menu .menubar.edit -label Edit
        .menubar.edit add command -label Preferences
        .menubar.edit add command -label "Add Title to DB" -command alist_gui::add_dialog 
        . configure -menu .menubar
        
        ttk::treeview .mylist -columns "title no_eps watched status rating" -show "headings"
        .mylist heading title -text Title
        .mylist heading no_eps -text Episodes
        .mylist heading watched -text Watched
        .mylist heading status -text Status

        grid .mylist -column 0 -row 0 -sticky nsew 
        ::alist_gui::populate_list
#--------Configure Grid---------------
        grid columnconfigure . 1 -weight 1
        grid rowconfigure . 0 -weight 1

#--------Cleanup---------------------
        bind . <Destroy> {
            alist_db close        
        }

    }
}
alist_gui::start
