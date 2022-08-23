#!/bin/bash
#Eyal Haber 203786298

player_1_score=50
player_2_score=50
ball_location=0 # (-3,-2,-1,0,1,2,3)

game_on=true # will be false when the game finished
players_interact=false # will be true when players start guessing numbers

function display_players_score(){
  echo " Player 1: $player_1_score         Player 2: $player_2_score "
}

function upper_frame(){
    echo " --------------------------------- "
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
}

function lower_frame(){
  echo " |       |       #       |       | "
  echo " |       |       #       |       | "
  echo " --------------------------------- "
}

function players_pick_numbers(){
  valid=0
  while [[ $valid = 0 ]]; do
        echo "PLAYER 1 PICK A NUMBER: "
        read -s player_1_guess # hide the input
        if [[ ! $player_1_guess =~ ^[0-9]+$ ]] || ! [[ $player_1_guess -ge 0  && $player_1_guess -le $player_1_score ]]
        then
          echo "NOT A VALID MOVE !"
        else
          player_1_score=$(($player_1_score-$player_1_guess))
          valid=1
        fi
  done

  valid=0
  while [[ $valid = 0 ]]; do
        echo "PLAYER 2 PICK A NUMBER: "
        read -s player_2_guess # hide the input
        if [[ ! $player_2_guess =~ ^[0-9]+$ ]] || ! [[ $player_2_guess -ge 0  && $player_2_guess -le $player_2_score ]]
        then
          echo "NOT A VALID MOVE !"
        else
          player_2_score=$(($player_2_score-$player_2_guess))
          valid=1
        fi
  done

  if [[ $player_1_guess -lt $player_2_guess ]]
  then
    if [[ $ball_location -gt 0 ]] # the ball is in p2's side
    then
      ball_location=-1 # move the ball to p1's side
    else # the ball is already in p1's side
      ball_location=$(($ball_location-1))
    fi
  elif [[ $player_1_guess -gt $player_2_guess ]]
  then
    if [[ $ball_location -lt 0 ]] # the ball is in p1's side
    then
      ball_location=1 # move the ball to p2's side
    else # the ball is already in p2's side
      ball_location=$(($ball_location+1))
    fi
  fi
  players_interact=true
}

function last_guessed_numbers(){
  if [[ "$players_interact" = true ]]
  then
    echo -e "       Player 1 played: ${player_1_guess}\n       Player 2 played: ${player_2_guess}\n\n"
  fi
}

function locate_ball(){
  case $ball_location in

    "-3")
      echo "O|       |       #       |       | "
      ;;

    "-2")
      echo " |   O   |       #       |       | "
      ;;

    "-1")
      echo " |       |   O   #       |       | "
      ;;

    "0")
      echo " |       |       O       |       | "
      ;;

    "1")
      echo " |       |       #   O   |       | "
      ;;

    "2")
      echo " |       |       #       |   O   | "
      ;;

    "3")
      echo " |       |       #       |       |O"
      ;;

    *)
      echo " |       |       O       |       | "
      ;;
  esac
}

function game_status(){
  if [[ $ball_location -eq 3 ]] || [[ $player_2_score -eq 0 && $player_1_score -ne 0 ]]
  then
    echo "PLAYER 1 WINS !"
    game_on=false
    exit 0
  elif [[ $ball_location -eq -3 ]] || [[ $player_1_score -eq 0 && $player_2_score -ne 0 ]]
  then
    echo "PLAYER 2 WINS !"
    game_on=false
    exit 0
  elif [[ $player_1_score -eq 0 && $player_2_score -eq 0 ]] # both players reached 0 the same turn
  then
    if [[ $ball_location -eq 0 ]] # the ball is in the middle
    then
      echo "IT'S A DRAW !"
      game_on=false
      exit 0
    elif [[ $ball_location -lt 0 ]] # the ball is in p1's side
    then
      echo "PLAYER 2 WINS !"
      game_on=false
      exit 0
    else # the ball is in p2's side
      echo "PLAYER 1 WINS !"
      game_on=false
      exit 0
    fi
  fi
}

# play the game:
while [[ $game_on == true ]]; do

  display_players_score
  upper_frame
  locate_ball
  lower_frame
  last_guessed_numbers
  game_status
  players_pick_numbers

done









