#! /bin/bash

init(){
echo "Starting game..."
BOARD=(- - - - - - - - -)
PLAYER=1
SYMBOLS=(- o x)
GAMEALIVE=1
GAMESTATUS=1
BASEDIR=$(dirname "$0")
CPU=0
}

print(){
echo "\"turn [row 0 - 2] [col 0 - 2]\" to play your turn"
echo "\"restart\" to restart the game"
echo "\"save\" to save the game - game will attempt to save game in it's directory"
echo "\"q\" to quit"
echo "\"setcpu [1 2]\" to set cpu player for given index"
printboard
echo "current: Player"$PLAYER\(${SYMBOLS[$PLAYER]}\)
}

printboard() {
echo "BOARD"
echo "============="
for i in {0..8}
do
	if [ $(($i%3)) == 0 ] && [ $i != 0 ]; then
	echo -n  \|
  	echo ""
	fi
	echo -n \| ${BOARD[$i]} ""
done
echo "|"
echo "============="
}

turn(){
  idx=$(( $1 * 3 + $2 ))
  if [ ${BOARD[$idx]} == "-" ]; then 
	BOARD[$idx]=${SYMBOLS[$PLAYER]}
	echo gamestatus1 $GAMESTATUS
	gamewon
	if [ $GAMESTATUS == 1 ]; then 
		PLAYER=$((PLAYER%2+1))
	fi
  else
    echo "Move not allowed, enter command again!"
	read -r move a b
	turn $a $b
  fi
}

placerandom() {
counter=0
for i in {0..8}
do
	if [ ${BOARD[$i]} == "-" ]; then
	counter=$(($counter+1))
	fi
done


idx=$(($RANDOM%$counter))
counter=0
for i in {0..8}
do
	if [ ${BOARD[$i]} == "-" ]; then
		counter=$(($counter+1))
		if [ $counter==idx ]; then 
			BOARD[$i]=${SYMBOLS[$PLAYER]}
			break
		fi
	fi
done

gamewon
if [ $GAMESTATUS == 1 ]; then 
	PLAYER=$((PLAYER%2+1))
fi
}

gamewon(){
  checkline 0 1 2
  checkline 3 4 5
  checkline 6 7 8
  checkline 0 3 6
  checkline 1 4 7
  checkline 2 5 8
  checkline 0 4 8
  checkline 2 4 6
  echo $GAMESTATUS
  if [ $GAMESTATUS == 1 ]; then 
	checkfilled
  fi
}

checkline(){
  if [ ${BOARD[$1]} != "-" ] && [ ${BOARD[$1]} == ${BOARD[$2]} ] && [ ${BOARD[$2]} == ${BOARD[$3]} ]; then
    GAMESTATUS=0
  fi
}

checkfilled(){
counter=0
for i in {0..8}
do
	if [ ${BOARD[$i]} != "-" ]; then
	counter=$(($counter+1))
	fi
done
if [ $counter == 9 ]; then 
	GAMESTATUS=2
fi
}

save(){
	filepath=$BASEDIR/lastSavedGame
	filepath="${filepath:2}"
	touch $filepath
	echo $PLAYER
	echo $PLAYER > $filepath
	printf "%s " "${BOARD[@]}" >> $filepath
	read test
}

init
if [ $1 == "load" ]; then 
	filepath=$BASEDIR/lastSavedGame
	filepath="${filepath:2}"
	{ read -a PLAYER; read -a BOARD; } < $filepath
	read test
fi 


while [ $GAMEALIVE == 1 ]; do
	clear
	print
	if [ $PLAYER == $CPU ]; then
			echo "CPU turn, press enter to continue..." 
			read dontcare
			placerandom
			clear
			print
		fi
	while [ $GAMESTATUS == 1 ]; do 
		read move a b
		if [ -z "$move" ]; then
			echo "wrong command, try again."
		elif [ $move == "turn" ]; then
			turn $a $b
			break
		elif [ $move == "setcpu" ]; then
			CPU=$a
			break
		elif [ $move == "restart" ]; then
			init
			break
		elif [ $move == "q" ]; then
			GAMEALIVE=0
			break
		elif [ $move == "save" ]; then
			GAMESTATUS=3
			GAMEALIVE=3
			save
			break
		else
			echo "wrong command, try again."
		fi
	done
clear
if [ $GAMESTATUS == 0 ]; then
	echo "Game won by player"$PLAYER 
	GAMEALIVE=0
elif [ $GAMESTATUS == 2 ]; then
	echo draw
	GAMEALIVE=0
fi
printboard
done