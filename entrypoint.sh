#!/bin/bash

function error() {
	if [[ -t 1 ]]; then
		printf "\e[1;31m$*\e[0m\n" >&2
	else
		printf "$*\n" >&2
	fi
}

function usage() {
	error "Usage: noisy SLEEP_TIME [LOG_MESSAGE]"
	error '  SLEEP_TIME: Number of seconds to wait between logs. Default is 5 seconds.'
	error '  LOG_MESSAGE: Optional. The message to print every SLEEP_TIME seconds. Use `{{time}}` in the string for current time. Default is a JSON log.'
}

function stamp() {
	date "+$TIME_FORMAT"
}

function fast_sleep() {
    [[ "$1" != 0 ]] && sleep "$1"
}

sleep_time=${1:-5}
log_message=${@:2}
LOG_FILE=${LOG_FILE:-/var/log/noisy.log}
TIME_FORMAT=${TIME_FORMAT:-%Y-%m-%dT%H:%M:%S.%NZ}

# Optimize for lowest latency when not logging to a file
if [[ "$LOG_FILE" != /dev/null ]]; then
    function log() {
        echo "$*"
        echo "$*" >> "$LOG_FILE"
    }
else
    function log() {
        echo "$*"
    }
fi

if [[ -z "$log_message" ]]; then
	log_message='{"time": "{{time}}", "key": "value", "number": 123.456, "bool": true}'
fi

if [[ -z "$sleep_time" || -z "$log_message" ]]; then
	usage
	exit 2
fi

if [[ ! "$sleep_time" =~ ^[0-9]+(\.[0-9]*)?$ ]]; then
	error "Sleep time must be a non-negative number: $sleep_time"
	usage
	exit 2
fi

trap 'exit 0' SIGTERM SIGINT

if [[ "$log_message" == *'{{time}}'* ]]; then
    while :; do
        time=$(stamp)
        log "${log_message//\{\{time\}\}/$time}"
        fast_sleep "$sleep_time"
    done
else
    while :; do
        log "$log_message"
        fast_sleep "$sleep_time"
    done
fi
