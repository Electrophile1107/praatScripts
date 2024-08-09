##############################################################################
# Author: Xie Huangyang
# Title: Wordlist Labeler
# Usage: 1. Get a 2-column tab-separated text file containing labels
#        2. Input paths or select the sound and textgrid files
#        3. Start labeling
#        4. Press "Done" to finish
##############################################################################


form: "Start"
    comment: "Sound and textgrid files for labeling (check if loaded already)."
        sentence: "sound_path", ""
        sentence: "textgrid_path", ""
        boolean: "is_loaded", 1
    comment: "Label table (Must be two tab-separated columns: Label & Description)."
        sentence: "label_path", "D:\01_San-weh\01_RA_Wenzhou\Praat_annWordlist\wz_labels.txt"
    comment: "Target tier number:"
        integer: "tier", "1"
endform

# Read the duo if not loaded
if is_loaded = 0
    if fileReadable (sound_path$) = 0
        sound_path$ = chooseReadFile$ ("Choose a sound file")
    endif
    if fileReadable (textgrid_path$) = 0
        textgrid_path$ = chooseReadFile$ ("Choose a textgrid file")
    endif
    sound = Read from file: sound_path$
    tg = Read from file: textgrid_path$
    selectObject: sound
    plusObject: tg
endif
tg_name$ = selected$("TextGrid")
View & Edit

# Handle label table
if fileReadable (label_path$) = 0
    label_path$ = chooseReadFile$ ("Choose a label table")
endif
table = Read Table from tab-separated file: label_path$
selectObject: table
column_num = Get number of columns
if column_num <> 2
    exitScript: "Not a 2-column table"
endif
c1_name$ = Get column label: 1
c2_name$ = Get column label: 2
row_num = Get number of rows
cur_row = 1
label$ = Get value: cur_row, c1_name$
description$ = Get value: cur_row, c2_name$

# Main window
while 1
    beginPause: "Set labels"
        sentence: "label", label$
        comment: "description: " + description$
    clicked = endPause: "Set", "Next", "Previous", "Search", "Done", 1, 5
    if clicked = 1
        editor: "TextGrid " + tg_name$
            cur_time = Get cursor
        endeditor
        selectObject: "TextGrid " + tg_name$
        intv = Get interval at time: tier, cur_time
        Set interval text: tier, intv, label$
        cur_row = if cur_row < row_num then cur_row + 1 else row_num fi
    elif clicked = 2
        cur_row = if cur_row < row_num then cur_row + 1 else row_num fi
    elif clicked = 3
        cur_row = if cur_row > 1 then cur_row - 1 else 1 fi
    elif clicked = 4
        temp = nocheck Search column: c1_name$, label$
        if temp = 0
            writeInfoLine: label$, "not found"
        else
            cur_row = temp
        endif
    elif clicked = 5
        exit
    endif
    selectObject: table
    label$ = Get value: cur_row, c1_name$
    description$ = Get value: cur_row, c2_name$
endwhile

selectObject: table
Remove