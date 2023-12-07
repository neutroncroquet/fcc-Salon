#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "What service would you like today?\n"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo $1
  fi
  echo "$($PSQL "select * from services;")" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    MAIN_MENU "Please enter a valid number."
  else
    SERVICE_ID_CHECK_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_ID_CHECK_RESULT ]]
    then
      MAIN_MENU "Please enter a valid number."
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_LOOKUP=$($PSQL "SELECT name, customer_id from customers where phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_LOOKUP ]]
      then
        echo -e "We don't have an account for that phone number.\nPlease enter your name."
        read CUSTOMER_NAME
        CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      else
        IFS="|" read CUSTOMER_NAME CUSTOMER_ID <<< $CUSTOMER_LOOKUP
      fi
      echo -e "\nWhat time for your appointment?"
      read SERVICE_TIME
      APPOINTMENT_SET_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME');")
      echo "I have put you down for a $SERVICE_ID_CHECK_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
      
  fi
}
MAIN_MENU
