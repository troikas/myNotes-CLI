#!/bin/bash

# My notes is a program with which you can write,
# read, edit and synchronize notes from terminal.

# You can change the folder "/Ubuntu One/notes/"
# And the editor "vim, vi, pico, joe, whatever"

# Author: TROiKAS troikas@pathfinder.gr
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

my_file="$HOME/Dropbox/notes/"
mkdir -p "$my_file"
language="en"
editor="${EDITOR:-nano}"
x=1
notes_array=()

lstxt() {
Ele=()
notes_array=()
x=1

shopt -s nullglob
for i in "$my_file"*.not
do
    filename=$(basename "$i")
    notes_array+=("$filename")
    Ele+=("$x: ${filename%.*}")
    ((x++))
done
shopt -u nullglob

for value in "${Ele[@]}"; do 
    printf "%-8s\n" "${value}"
done | column

((x--))
}

start(){
    shopt -s nullglob
    files=("$my_file"*.not)
    shopt -u nullglob
    x=${#files[@]}

	echo -e '\E[30;46m'""
	if [[ "$language" == "el" ]]; then
		echo "Έχετε $x σημειώσεις στο: $my_file"
	else
		echo "You have $x notes in: $my_file"
	fi
	echo "  <<-------------------------------->>"
	tput sgr0
	x=1
	echo -e '\E[37;43m'""
	if [[ "$language" == "el" ]]; then
		echo "Για να διαβάσετε μια σημείωση, πατήστε \"r\""
		echo "Για να γράψετε μια νέα σημείωση, πατήστε \"w\""
		echo "Για να επεξεργαστείτε μια σημείωση, πατήστε \"e\""
		echo "Για να διαγράψετε μια σημείωση, πατήστε \"d\""
		echo "Για αναζήτηση στις σημειώσεις, πατήστε \"s\""
		echo "Για έξοδο, πατήστε \"οποιοδήποτε άλλο πλήκτρο\""
	else
		echo "To read a note press \"r\""
		echo "To write a new note press \"w\""
		echo "To edit a note press \"e\""
		echo "To delete a note press \"d\""
		echo "To search notes press \"s\""
		echo "To exit, press \"any other key\""
	fi
	tput sgr0
	read ans
}

search_notes() {
	echo ""
	if [[ "$language" == "el" ]]; then
		echo "Πληκτρολογήστε όρο αναζήτησης (ή 'm' για το μενού):"
	else
		echo "Enter search term (or 'm' for menu):"
	fi
	read search_term

	if [[ $search_term == "m" ]]; then
		start
	else
        # Find files containing the term and store their paths in an array
        shopt -s nullglob
        mapfile -t search_results < <(grep -li "$search_term" "$my_file"*.not)
        shopt -u nullglob

        if [ ${#search_results[@]} -eq 0 ]; then
            if [[ "$language" == "el" ]]; then
                echo "Δεν βρέθηκαν αποτελέσματα για '$search_term'."
            else
                echo "No results found for '$search_term'."
            fi
            echo ""
            if [[ "$language" == "el" ]]; then echo "Πατήστε οποιοδήποτε πλήκτρο για να επιστρέψετε στο μενού..."; else echo "Press any key to return to menu..."; fi
            read -n 1 -s
            start
        else
            # Display the numbered list of matching notes
            clear
            local result_count=${#search_results[@]}
            if [[ "$language" == "el" ]]; then
                echo "Βρέθηκαν $result_count σημειώσεις που περιέχουν τον όρο '$search_term':"
            else
                echo "Found $result_count notes containing '$search_term':"
            fi
            echo "  <<-------------------------------->>"
            
            local i=1
            for file_path in "${search_results[@]}"; do
                local filename=$(basename "$file_path")
                echo "$i: ${filename%.*}"
                ((i++))
            done
            echo "  <<-------------------------------->>"
            echo ""

            # Prompt user to select a note to open
            if [[ "$language" == "el" ]]; then echo "Για μενού πατήστε \"m\""; else echo "For menu press \"m\""; fi
            if [[ "$language" == "el" ]]; then echo "Επιλέξτε αριθμό σημείωσης για να την ανοίξετε (1 έως $result_count):"; else echo "Select a note number to open (1 to $result_count):"; fi
            read num

            if [[ $num == "m" ]]; then
                start
            else
                while [ "$num" -lt "1" ] || [ "$num" -gt "$result_count" ] || [[ ! "$num" =~ ^[0-9]+$ ]]; do
                    if [[ "$language" == "el" ]]; then echo "Παρακαλώ δώστε έναν σωστό αριθμό μεταξύ 1 και $result_count."; else echo "Please put a correct number between 1 and $result_count."; fi
                    read num
                done

                local selected_file_path="${search_results[$((num-1))]}"
                local selected_filename=$(basename "$selected_file_path")
                clear
                echo "$num: ${selected_filename%.*}"
                echo "  <<-------------------------------->>"
                echo ""
                # Show the entire file, with the search term highlighted
                grep --color=always -i -E "^|$search_term" "$selected_file_path"
                echo ""
                if [[ "$language" == "el" ]]; then echo "Πατήστε οποιοδήποτε πλήκτρο για να επιστρέψετε στο μενού..."; else echo "Press any key to return to menu..."; fi
                read -n 1 -s
                start
            fi
        fi
	fi
}

start
while true; do
if [[ $ans == "r" ]]; then
	lstxt
	echo ""
	if [[ "$language" == "el" ]]; then
		echo "Για μενού πατήστε \"m\""
		echo "Επιλέξτε τον αριθμό της σημείωσης που θέλετε να διαβάσετε \"1 έως $x\" : "
	else
		echo "For menu press \"m\""
		echo "Please put the number of the note you want to read \"1 to $x\" : "
	fi
	read num
	if [[ $num == "m" ]]; then
		x=1
		start
	else
		while [ "$num" -lt "1" ] || [ "$num" -gt "$x" ] || [[ ! "$num" =~ ^[0-9]+$ ]]
		do
			if [[ "$language" == "el" ]]; then
				echo "Παρακαλώ δώστε έναν σωστό αριθμό μεταξύ 1 και $x."
			else
				echo "Please put a correct number between 1 and $x."
			fi
			read num
		done
		line="${notes_array[$((num-1))]}"
		clear
		echo "$num"\: "${line%.*}"
		echo "  <<-------------------------------->>"
		echo ""
		cat "$my_file$line"
		echo ""
		x=1
		start
	fi

elif [[ $ans == "w" ]]; then
	echo""
	if [[ "$language" == "el" ]]; then
		echo "Για μενού πατήστε \"m\""
		echo "Γράψτε τον τίτλο της νέας σημείωσης:"
	else
		echo "For menu press \"m\""
		echo "Please write the title of a new note:"
	fi
	read n_title
	if [[ $n_title == "m" ]]; then
		x=1
		start
	else
		while [ -f "$my_file$n_title.not" ]
		do
			if [[ "$language" == "el" ]]; then
				echo "Το $n_title υπάρχει ήδη. Δώστε άλλο τίτλο:"
			else
				echo "The $n_title exists. Give another title:"
			fi
			read n_title
		done
		echo ""
		echo "$n_title"
		echo "  <<-------------------------------->>"
		echo ""
		$editor "$my_file$n_title.not"
		cat "$my_file$n_title.not"
		echo ""
		start
	fi

elif [[ $ans == "e" ]]; then
	lstxt
	echo ""
	if [[ "$language" == "el" ]]; then
		echo "Για μενού πατήστε \"m\""
		echo "Επιλέξτε τον αριθμό της σημείωσης προς επεξεργασία \"1 έως $x\" : "
	else
		echo "For menu press \"m\""
		echo "Please put the number of the note you want to edit \"1 to $x\" : "
	fi
	read num
	if [[ $num == "m" ]]; then
		x=1
		start
	else
		while [ "$num" -lt "1" ] || [ "$num" -gt "$x" ] || [[ ! "$num" =~ ^[0-9]+$ ]]
		do
			if [[ "$language" == "el" ]]; then
				echo "Παρακαλώ δώστε έναν σωστό αριθμό μεταξύ 1 και $x :"
			else
				echo "Please put a correct number between 1 and $x :"
			fi
			read num
		done
		line="${notes_array[$((num-1))]}"
		clear
		echo ""
		echo "$num"\: "${line%.*}"
		echo "  <<-------------------------------->>"
		echo ""
		$editor "$my_file$line"
		cat "$my_file$line"
		x=1
		start
	fi
	
elif [[ $ans == "d" ]]; then
	lstxt
	echo ""
	if [[ "$language" == "el" ]]; then
		echo "Για μενού πατήστε \"m\""
		echo "Επιλέξτε τον αριθμό της σημείωσης προς διαγραφή \"1 έως $x\" : "
	else
		echo "For menu press \"m\""
		echo "Please put the number of the note you want to delete \"1 to $x\" : "
	fi
	read num
	if [[ $num == "m" ]]; then
		x=1
		start
	else
		while [ "$num" -lt "1" ] || [ "$num" -gt "$x" ] || [[ ! "$num" =~ ^[0-9]+$ ]]
		do
			if [[ "$language" == "el" ]]; then
				echo "Παρακαλώ δώστε έναν σωστό αριθμό μεταξύ 1 και $x :"
			else
				echo "Please put a correct number between 1 and $x :"
			fi
			read num
		done
		line="${notes_array[$((num-1))]}"
		clear
		echo ""
		echo "$num"\: "${line%.*}"
		if [[ "$language" == "el" ]]; then
			echo "Είστε σίγουροι; y/n"
		else
			echo "Are you sure? y/n"
		fi
		read yeno
		while [[ x$yeno != xy && x$yeno != xn ]]
		do
			if [[ "$language" == "el" ]]; then
				echo "Παρακαλώ επιλέξτε y ή n"
			else
				echo "Please y or n"
			fi
			read yeno
		done
		if [[ $yeno == "y" ]]; then
			rm "$my_file$line"
			if [[ "$language" == "el" ]]; then echo "Διαγράφηκε."; else echo "Deleted."; fi
			echo ""
			x=1
			start
		elif [[ $yeno == "n" ]]; then
			echo ""
			x=1
			start
		fi
	fi
	
elif [[ $ans == "s" ]]; then
	search_notes

else
	if [[ "$language" == "el" ]]; then
		echo "Το MyNotes έκλεισε!!!"
	else
		echo "MyNotes, closed!!!"
	fi
	exit
fi
done
