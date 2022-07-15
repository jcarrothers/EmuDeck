#!/bin/bash



function changeLine() {

    local KEYWORD=$1; shift
    local REPLACE=$1; shift
    local FILE=$1

    local OLD=$(escapeSedKeyword "$KEYWORD")
    local NEW=$(escapeSedValue "$REPLACE")

    sed -i "/${OLD}/c\\${NEW}" $FILE

}
function escapeSedKeyword(){
    local INPUT=$1;
    local OUTPUT=$(printf '%s\n' "$INPUT" | sed -e 's/[]\/$*.^[]/\\&/g')
    echo $OUTPUT
}

function escapeSedValue(){
    local INPUT=$1
    local OUTPUT=$(printf '%s\n' "$INPUT" | sed -e 's/[\/&]/\\&/g')
    echo $OUTPUT
}

function getSDPath(){
    if [ -b "/dev/mmcblk0p1" ]; then	    
		echo "$(findmnt -n --raw --evaluate --output=target -S /dev/mmcblk0p1)"
	fi
}

function testRealDeck(){
    case $(cat /sys/devices/virtual/dmi/id/product_name) in
	  Win600|Jupiter)
		isRealDeck=true
	;;
	  *)
		isRealDeck=false
	;;
	esac
}

function testLocationValid(){
    local locationName=$1
	local testLocation=$2
	local return=""

    touch $testLocation/testwrite
    
	if [ ! -f  $testLocation/testwrite ]; then
		return="Invalid: $locationName not Writable"
	else
		ln -s $testLocation/testwrite $testLocation/testwrite.link
		if [ ! -f  $testLocation/testwrite.link ]; then
			return="Invalid: $locationName not Linkable"
		else
			return="Valid: $testLocation"
		fi
	fi
	rm -f "$testLocation/testwrite" "$testLocation/testwrite.link"
	echo $return
}

function makeFunction(){

	find "/home/deck/emudeck/backend/configs/org.libretro.RetroArch/config/retroarch/config" -type f -iname "*.cfg" | while read file
		do
			
			folderOverride="$(basename "${file}")"
			foldername="$(dirname "${file}")"
			coreName="$(basename "${foldername}")"
			echo "RetroArch."${coreName// /_}".bezelOn(){"
			IFS=$'\n'
			for line in $(cat "$file")
			do
				local option=$(echo "$line" | awk '{print $1}')
				local value=$(echo "$line" | awk '{print $3}')
				echo "RetroArch.setOverride '$folderOverride' '$coreName'  '$option' '$value'"
			done
			echo '}'
		done
}

function customLocation(){
    echo $(zenity --file-selection --directory --title="Select a destination for the Emulation directory." 2>/dev/null)
}

function refreshSource(){
	source $EMUDECKGIT/functions/all.sh
}

function setAllEmuPaths(){
	for func in $(compgen -A function | grep '.setEmulationFolder')
		 do  $func
	done
}



function installAll(){
	for func in $(compgen -A function | grep '\.install$')
		 do  $func
	done
}


function initAll(){
	for func in $(compgen -A function | grep '\.init$')
		 do  $func
	done
}


