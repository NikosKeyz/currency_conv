#!/bin/bash

# check number of arguments
function check_number_of_args {

  if [ $1 -lt 2 ]
  then
    echo "error: Wrong number of arguments"
    exit -1
  fi
}

# check first argument
function check_first_arg {

  regex="^[0-9]+$"
  if ! [[ $1 =~ $regex ]] ;
  then
    echo "error: First argument isn't a number"
    exit -2
  fi
}

# check currency variables
function check_currencies {
  arg=$1
  size=${#arg}
  arg_number=$2
  regex="[A-Z]+"

  if [[ $arg =~ $regex ]] # if arg is alphabetic
  then
    if [ $size -eq 3 ] # if length of arg is 3
    then
      currencies=$currencies$arg,
    else
      echo "error: Wrong currency values"
      exit -3
    fi
  else
    echo "error: Wrong currency values"
    exit -4
  fi

}

function assemble_url {

	url1="http://apilayer.net/api/live?access_key="
	key="5428d59edfe5ff28d6ea261ac91b540f"
	url2="&currencies="
	currencies=$1
	url4="&source=USD&format=1"

	url=$url1$key$url2$currencies$url4

	#echo $url
}

# Check if json has success state true
function check_success_state {

  success_state=$( echo $json | tr ' ' '\n' | grep 'success' | cut -d ':' -f 2 | tr "," " ")

  if [ $success_state == "true" ]
  then
    echo "Calculating..."
  else
    echo "error: Json came with success state false "
    exit -5
  fi
}

function show_conversion {

  rate=$( echo $json | tr ' ' '\n' | grep $1 | cut -d ':' -f 2 | tr ',' ' ')

  prefix=$( echo $value " USD " )
  asterisk=$( echo * )
  rate_print=$( echo  $rate "= " )
  result=$( echo " $value * $rate " | bc )

  echo $prefix $'*' $rate '=' $result $1

}
# # # # # # # # # # # # #
######## M A I N ########
# # # # # # # # # # # # #

## Variables ##
value=$1
currencies=""
url=""
json=""

## Logic ##

#### Have to check all arguments
echo Checking arguments...

# check number of arguments, passing the number of them
check_number_of_args $#

# check first argument, passing first argument
check_first_arg $1

# check currency arguments
for ((i = 2; i <= $#; i++)); # every N+1 argument
do
  check_currencies "${!i}" $i # check every argument passing its value and number
done

#### Checks of arguments are done
echo Processing...

# concatenate final url
assemble_url $currencies

# download json
json=$(wget -q -O- $url)

check_success_state

# Show conversion for every currency
for ((i = 2; i <= $#; i++));
do
  show_conversion "${!i}" $i # check every argument passing its value and number
done
