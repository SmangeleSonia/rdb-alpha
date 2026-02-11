#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\nWelcome to the Salon!"

# Function to display services
display_services() {
  echo -e "\nHere are our services:"
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id;" | while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done
}

# Display services first
display_services

# Ask for service selection
read SERVICE_ID_SELECTED

# Loop until valid service is chosen
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
while [[ -z $SERVICE_NAME ]]
do
  echo -e "\nI could not find that service. Please select again."
  display_services
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
done

# Ask for phone
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

# If customer doesn't exist, get name and insert
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
fi

# Ask for appointment time
echo -e "\nEnter your appointment time:"
read SERVICE_TIME

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# Insert appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
