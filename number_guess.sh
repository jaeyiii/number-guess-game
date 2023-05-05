#!/bin/bash
USER() {
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
}
USER
while [[ -z $USERNAME ]]
do
  USER
done

USER_INFO=$($PSQL "SELECT number_games_played, best_guess FROM scoreboard WHERE username = '$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=0
else
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
BEST_GAME_NOW=0
RANDOM_VALUE=$(( 1 + RANDOM % 1000 ))
echo "Guess the secret number between 1 and 1000:"


GAMES() {
  read GUESS
  if [ $GUESS -lt 0 ]
  then
    BEST_GAME_NOW=$(( $BEST_GAME_NOW + 1 ))
    echo "It's higher than that, guess again:"
    GAMES

  elif [[ ! $GUESS =~ ^[0-9]*$ || -z $GUESS ]]
  then
    echo "That is not an integer, guess again:"
    GAMES

  elif [ $GUESS -eq $RANDOM_VALUE ]
  then
    BEST_GAME_NOW=$(( $BEST_GAME_NOW + 1 ))
    echo "You guessed it in $BEST_GAME_NOW tries. The secret number was $RANDOM_VALUE. Nice job!"

  elif [ $GUESS -lt $RANDOM_VALUE ]
  then
    BEST_GAME_NOW=$(( $BEST_GAME_NOW + 1 ))
    echo "It's higher than that, guess again:"
    GAMES

  elif [ $GUESS -gt $RANDOM_VALUE ]
  then
    BEST_GAME_NOW=$(( $BEST_GAME_NOW + 1 ))
    echo "It's lower than that, guess again:"
    GAMES
  fi
}
GAMES

if [ $GAMES_PLAYED -eq 1 ]
then
  INSERT_INFO=$($PSQL "INSERT INTO scoreboard(username, number_games_played, best_guess) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME_NOW)")
elif [ $BEST_GAME_NOW -le $BEST_GAME ]
then
  UPDATE_INFO=$($PSQL "UPDATE scoreboard SET number_games_played = $GAMES_PLAYED, best_guess = $BEST_GAME_NOW WHERE username = '$USERNAME'")
else
  UPDATE_INFO=$($PSQL "UPDATE scoreboard SET number_games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
fi
