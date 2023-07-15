# Tester for push_swap

This project is created to alow a stand-alone import of my tester instead of only distributing it through my push_swap project.

## Config

You can change the settigns in config.env for optimized testing.
The options are:
```man
PS_LOCATION   : Which needs to point to your push swap folder without the "/" at the end.

CHECKER       : Can be set when you want to use a different tester than the default mac_tester provided by 42.

LOGFILE       : File / location to safe log on failure.

ROUNDS        : Amount of roudns done for benchmarking (option -b) when the -a flag is not set.
 ```

## Usage

run:
```bash
./tester.sh [-ptrib] [-a ] [-c <amount-of-args>]
```

### Options

The following options are available:

```man
-p      : Pipeline (exit 1 on KO)

-t      : Timed (10.000 args)

-r      : Random tests (completely made up, feel free to extend tehm for yourself!).

-i      : Input tests (very limited, also feel free to extend for yourself!).

-b      : Benchmarking (amount of operations).

-a      : Overwrite the amount of rounds in the config file for benchmarking.

-c X    : Check X amount of arguments.
```

When no options are selected you receive the complimentary full test I use on evaluations.

## Exit
1. Pipeline (option -p) turned on and KO received.
2. Invalid option.

## Challenge

A fellow student once told me he could sort 500 numbers by hand, it is peanuts to sort such low numbers!
To make the project more interesting he came up with a challenge.
Sort 10.000 arguments, randomly created. The challenge has only two goals, both equally important:
 - You must keep the total number of operations low.
 - Your program should run as quickly as possible!

With these two objectives in mind I made a special check in this tester (options -bt).
Below are my scores, if you can beat me on both let me know on slack!

![Timed run](images/timed_example.png)
