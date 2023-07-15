#!/bin/bash

# Load config
. config.env

# Compile push_swap
make -C $PS_LOCATION/ > /dev/null

# Setting the program location.
PUSH_SWAP="$PS_LOCATION/push_swap"

# Checking required files.

if ! test -f $PUSH_SWAP; then
	echo $PUSH_SWAP does not exist!
	exit
elif ! test -f $CHECKER; then
	echo $CHECKER does not exist!
	exit
fi

### Functions ###
orange() {
    local orange_color='\033[38;5;214m'  # ANSI escape code for orange color
    local reset_color='\033[0m'           # ANSI escape code to reset color

	echo
    echo -e "${orange_color}$1${reset_color}"
}

# Function to print OK in green
print_ok() {
  echo $1 -e "[\033[32mOK\033[0m] "
}

# Function to print KO in red and failed numbers
print_ko() {
	echo $2 -e "[\033[31mKO\033[0m] "
	echo "Failed numbers: \"$1\"" >> "$LOGFILE"
	if $PIPELINE; then
		exit 1
	fi
}

err_test() {
	RES=$($PUSH_SWAP $1 2>&1)
	if [ "$RES" != "Error" ]; then
		print_ko "$1"
	fi
	print_ok $2
}

evaluate() {
	if [ "$1" != "OK" ]; then
		print_ko "$2" $3
	fi
	print_ok $3
}

# base test give "<number array>" as input add -n for no newline
base_test() {
	RES=$($PUSH_SWAP $1 | $CHECKER $1)
	if [ "$RES" != "OK" ]; then
		print_ko "$1"
	else
		print_ok $2
	fi
}

# Test loop for 10 times
do_tests() {

	for ((i=1; i<=$1; i++)); do

		ARG="$(ruby -e "puts (1..$2).to_a.shuffle.join(' ')")"
		RES=$($PUSH_SWAP $ARG | $CHECKER $ARG)
		if [ "$RES" != "OK" ]; then
			print_ko "$ARG"
		elif [ i != $1 ]; then
			print_ok -n
		fi
	done
	print_ok $3
}

info() {
	echo "INFO: $1"
}

operations_benchmark() {
	if ! $BENCHMARK; then
		return
	fi
	if [ $# -eq 1 ]; then
		LOOPS=1
	else
		LOOPS=$2
	fi
	MAX=0
	for ((k=1; k<=$LOOPS; k++)); do
		ARG="$(ruby -e "puts (1..$1).to_a.shuffle.join(' ')")"
		RES=$($PUSH_SWAP $ARG | wc -l)
		if [ $RES -gt $MAX ]; then
			MAX=$RES
		fi
	done
	echo "Max operations for $1 at $LOOPS tries: $MAX"
}

low_numbers() {
	for ((j=1; j<=6; j++)); do
		test_and_benchmark $j
	done
}

test_and_benchmark() {
	orange "Tests for $1 numbers"
	do_tests 5 $1
	operations_benchmark $1 $ROUNDS
}

random() {
	orange "Random tests"
	do_tests 1 42 -n
	do_tests 1 139 -n
	do_tests 1 64 -n
	do_tests 1 33 -n
	do_tests 1 92 -n
	do_tests 1 99 -n
	do_tests 1 512 -n
	do_tests 1 477
}

input() {
	# do the false input tests
	orange "False input tests"
	err_test "1 2 3 4 4" -n
	err_test "1a 3 9" -n
	err_test "a b c" -n
	err_test "-1 12 one 42" -n
	err_test "+0 -0"

	# perfectly fine input
	orange "Perfectly fine input"
	base_test "-1 22 3"
	# base_test "wrong"
}

timed() {
	# hand sorting impossible? try 10.000 args
	ARG="$(ruby -e "puts (1..10000).to_a.shuffle.join(' ')")"
	orange "Now we will test your program with 10000 arguments"
	# precision
	RES=$($PUSH_SWAP $ARG | $CHECKER $ARG)
	evaluate "$RES" "-10000 args"
	# operations
	operations_benchmark 10000

	# time
	echo -n "time: "
	time $PUSH_SWAP $ARG > /dev/null
}

## Full
full_test() {
	low_numbers
	test_and_benchmark 100
	test_and_benchmark 500
	random
	input
	timed
}

### Read options ###
check_array=()
PIPELINE=false
BENCHMARK=false
TIMED=false
RANDOM_CHECK=false
INPUT=false
CHECK=false
LOW=false
EXIT=false

while getopts "ptriba:c:" option; do
  case $option in
    p)
      PIPELINE=true ;; # Kill process when a fault is found.
    b)
	  BENCHMARK=true
	  ;;
	a)
	  echo $OPTARG
	  ROUNDS=$OPTARG ;;
    t)
	  TIMED=true ;;
    r)
	  RANDOM_CHECK=true ;;
    i)
	  INPUT=true ;;
    c)
	  check_array+=($OPTARG)
	  CHECK=true ;;
	l)
	  LOW=true ;;
    \?)
      EXIT=true ;;
  esac
done

if $EXIT; then
	echo Invalid option.
	exit 2
fi

echo Starting tests..

if ! $LOW && ! $INPUT && ! $RANDOM_CHECK && ! $TIMED && ! $CHECK; then
	full_test
else
	if $LOW; then
		low_numbers
	fi
	if $RANDOM_CHECK; then
		random
	fi
	if $INPUT; then
		input
	fi
	if $TIMED; then
		timed
	fi

	for element in "${check_array[@]}"; do
		test_and_benchmark $element
	done
fi
