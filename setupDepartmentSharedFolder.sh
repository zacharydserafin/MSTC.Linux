#!/bin/bash

# Check for command line arguement
ROOT_FOLDER="$1"

if [ -z "$ROOT_FOLDER" ]; then
  echo
  echo "Creates a department shared folder at the specified location."
  echo
  echo "  Usage: $0 <root folder>"
  echo

  exit 1
fi

# Make sure the script is running as root user
USER=`whoami`
if [ "$USER" != "root" ]; then
  echo
  echo "$0 must be run as root."
  echo

  exit 1
fi

DEPARTMENTS=(
"Sales"
"HumanResources"
"TechnicalOperations"
"Helpdesk"
"Research")

# Check if ROOT_FOLDER exists. If not, script will create it
if [ ! -d "$ROOT_FOLDER" ]; then
  echo "Creating root folder at $ROOT_FOLDER..."
  mkdir -p "$ROOT_FOLDER"
fi


for DEPARTMENT in ${DEPARTMENTS[*]}; do
  # this will repeat for each department
  echo "Provisioning $DEPARTMENT"

  # Check if department group exists. If not, script will create it
  if [ ! $(getent group "$DEPARTMENT") ]; then
    echo "Creating group $DEPARTMENT..."
    groupadd "$DEPARTMENT"
  fi

  # Check if department has a subfolder. If not, script will create it
  DEPARTMENT_FOLDER="$ROOT_FOLDER/$DEPARTMENT"
  if [ ! -d "$DEPARTMENT_FOLDER" ]; then
    echo "Creating subfolder $DEPARTMENT_FOLDER..."
    mkdir -p "$DEPARTMENT_FOLDER"
  fi

  # Set the onwership and permissions for each department folder
  echo " - Applying $USER:$DEPARTMENT ownership on $DEPARTMENT_FOLDER"
  chown "$USER":"$DEPARTMENT" "$DEPARTMENT_FOLDER"

  echo " - Applying permissions on $DEPARTMENT_FOLDER... $USER=rwx, $DEPARTMENT=rwx, o="
  chmod 770 "$DEPARTMENT_FOLDER"

  echo " - Granting permissions (rx) to Helpdesk on $DEPARTMENT_FOLDER"
  setfacl --modify=g:Helpdesk:rx "$DEPARTMENT_FOLDER"

done
