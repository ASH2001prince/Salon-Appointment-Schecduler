#!/bin/bash

PSQL="psql -h localhost -U postgres -d salon -p 5432 --no-align --tuples-only -c"

echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"
echo -e "Welcome to my Salon, How can I help you?\n"

MAIN_MENU() {


    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    echo "$AVAILABLE_SERVICES" | while IFS='|' read -r SERVICE_ID NAME
        do 
            echo "$SERVICE_ID) $NAME"
        done


            read SERVICE_ID_SELECTED

            case $SERVICE_ID_SELECTED in 
                1) SERVICE_NAME="cut"; GET_DETAILS $SERVICE_NAME ;;
                2) SERVICE_NAME="color"; GET_DETAILS $SERVICE_NAME ;;
                3) SERVICE_NAME="perm"; GET_DETAILS $SERVICE_NAME ;;
                4) SERVICE_NAME="style"; GET_DETAILS $SERVICE_NAME ;; 
                5) SERVICE_NAME="trim"; GET_DETAILS $SERVICE_NAME ;; 
                *) echo -e "\nI could not find that service. What would you like today?"
                 MAIN_MENU ;;
            esac
    
}
 GET_DETAILS(){

    SERVICE_NAME=$1

#    get the customer's phone number

    echo -e "What's your phone number: "
    read CUSTOMER_PHONE

    TESTING_THE_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # if the phone number does not exsist

    if [[ -z $TESTING_THE_PHONE ]] 
     then 
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_PHONE_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

        else 
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

        echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"  
        
        read SERVICE_TIME

        # Get the customer_id for the current customer

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # Insert the appointment into the appointments table 

        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

        
        # If the appointment is successfully added, output the message
            if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
                then 
                  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
            fi

 }

MAIN_MENU