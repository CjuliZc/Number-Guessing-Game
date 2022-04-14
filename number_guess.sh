#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"

NEW_USERNAME() {
  read GIVEN_USERNAME

  NEWUSERNAME=$($PSQL "SELECT user_id, username FROM users WHERE username = '$GIVEN_USERNAME'")
  echo "$NEWUSERNAME" | while read USER_ID BAR USERNAME
  do
    # new user
    if [[ ! $USER_ID ]]
    then
      echo "Welcome, $GIVEN_USERNAME! It looks like this is your first time here."
    
      INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$GIVEN_USERNAME')")
    
    # old user
    else
      
      BY_USER=$($PSQL "SELECT * FROM users INNER JOIN games USING(user_id) WHERE username = '$GIVEN_USERNAME'")
      echo "$BY_USER" | while read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME
      do
        GAMES_TOTAL=$($PSQL "SELECT COUNT(games_played) FROM users INNER JOIN games USING(user_id) WHERE username = '$GIVEN_USERNAME'")
        BEST_GAMES=$($PSQL "SELECT MIN(best_game) FROM users INNER JOIN games USING(user_id) WHERE username = '$GIVEN_USERNAME'")
        echo "Welcome back, $GIVEN_USERNAME! You have played $GAMES_TOTAL games, and your best game took $BEST_GAMES guesses."
      done
      
    fi
  done
}

NEW_USERNAME

GUESSING_GAME() {
  
  GUESSES=1
  while true
  do
    N1=$(( ( RANDOM % 100 ) +1 ))
    echo -e "\nGuess the secret number between 1 and 1000:"
    while read N2
    do
      # not an integer
      if [[ ! $N2 =~ ^[0-9]+$ ]]
      then 
        echo "That is not an integer, guess again:"
      # an integer
      else
        if   [[ $N2 -eq $N1 ]]
        then
          break
        else
          if [[ $N2 -gt $N1 ]]
          then 
            echo -n "It's lower than that, guess again:"
          elif [[ $N2 -lt $N1 ]]
          then
            echo -n "It's higher than that, guess again:"
          fi      
        fi
        GUESSES=$(( $GUESSES + 1 ))
      fi  
    done
      # number of guesses
      if [[ $GUESSES == 1 ]]
      then
        echo "You guessed it in $GUESSES tries. The secret number was $N1. Nice job!"
      else
        echo "You guessed it in $GUESSES tries. The secret number was $N1. Nice job!"
      fi

      BY_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$GIVEN_USERNAME'")
      INSERT_GAMES=$($PSQL "INSERT INTO games(user_id, games_played, best_game) VALUES($BY_USER_ID, 1, $GUESSES)")
    exit
  done
}

GUESSING_GAME
    
