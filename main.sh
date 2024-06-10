#!/usr/bin/env bash
set -o errexit -o pipefail -o noclobber

format_msg()
{
	echo "$2" | fmt -w 80 -g 80 | xargs -I'{}' echo "$1:" '{}'
}

usage()
{
	local name="${BASH_SOURCE[*]}"
	echo -e "train counting skill"
	echo -e "USAGE"
	echo -e "- show this message (default)"
	echo -e "\t $name [-h, --help]"
	echo -e "- compile c file and run it"
	echo -e "\t $name file"
	printf '=%.0s' {1..80}
	echo "mb6ockatf, Tue 09 May 2023 02:46:35 PM MSK"
}

is_value_in_list()
{
	local list="$1" value="$2"
	echo "${list[*]}" | tr " " '\n' | grep -F -q -x "$value"
}

color::form_output()
{
	if [[ $1 == "--help" ]] || [[ $1 == "-h" ]] || [[ -z $1 ]]; then
		name="color::form_output"
		echo -e "apply color to any text"
		echo -e "USAGE"
		echo -e "- show this message (default)"
		echo -e "\t $name [-h, --help]"
		echo -e "- get colored message"
		echo -e "\t $name color message"
		printf '=%.0s' {1..80}
		echo "by @mb6ockatf, Mon 08 May 2023 09:05:30 PM MSK"
		return 0
	fi
	local color="$1" message="$2"
	case "$color" in
		black) color="$BLACK" ;;
		blackb) color="$BLACKB" ;;
		white) color="$WHITE" ;;
		whiteb) color="$WHITEB" ;;
		red) color="$RED" ;;
		redb) color="$REDB" ;;
		green) color="$GREEN" ;;
		greenb) color="$GREENB" ;;
		yellow) color="$YELLOW" ;;
		yellowb) color="$YELLOWB" ;;
		blue) color="$BLUE" ;;
		blueb) color="$BLUEB" ;;
		purple) color="$PURPLE" ;;
		purpleb) color="$PURPLEB" ;;
		lightblue) color="$LIGHTBLUE" ;;
		lightblueb) color="$LIGHTBLUEB" ;;
		*) return 2 ;;
	esac
	echo -e "$color$message$END"
}

gen_numbers()
{
	local range="$1"
	[ -z "$range" ] && range=100
	local a=$((RANDOM % range)) b=$((RANDOM % range))
	echo "$a $b"
}

shorten_fraction()
{
	local numerator="$1" denominator="$2" minimal remainder result
	remainder=$((numerator % denominator))
	if [ "$remainder" -eq 0 ]; then
		result=$((numerator / denominator))
		echo $result
		return 0
	fi
	while [ $numerator -gt 1 ] && [ $denominator -gt 1 ]; do
		local temp=$denominator
		denominator=$((numerator % denominator))
		numerator=$temp
	done
	if [ $denominator -gt 1 ]; then
		local gcd=$numerator
		numerator=$((numerator / gcd))
		denominator=$((denominator / gcd))
	fi
	echo "$numerator/$denominator"
}

list_mode()
{
	local right=0 counter=0 mode="$1" range="$2" ans input request
	while true; do
		read a b <<< $(gen_numbers "$2")
		case "$mode" in
			plus)
				ans=$((a + b))
				request="$a + $b = "
				;;
			minus)
				ans=$((a - b))
				request="$a - $b = "
				;;
			multi)
				ans=$((a * b))
				request="$a * $b = "
				;;
			substract)
				ans=$(shorten_fraction $a $b)
				request="$a / $b = "
				;;
		esac
		printf "$request"
		read input
		echo -en "\033[1A\033[2K"
		[[ $input == "!" ]] && break
		printf "$request$input"
		if [[ $input == "$ans" ]]; then
			right=$((right++))
			printf " $TICK\n"
		else
			printf " $CROSS wrong, correct answer is $ans\n"
		fi
		counter=$((counter++))
	done
	echo "$right answers were right out of $counter"
}

border_mode()
{
	local right=0 counter=0 mode="$1" range="$2"
	while true; do
		clear
		read a b <<< $(gen_numbers "$2")
		case "$mode" in
			plus) ;;
			minus) ;;
			multi) ;;
			substract) ans=$((a / b)); request="$" ;;
		esac
		counter=$((counter++))
	done
}

readonly MODES="plus minus multi substract" \
	FRAMES="list border gumlist gumborder" \
	TICK=$(color::form_output green '\xe2\x9c\x93') \
	CROSS=$(color::form_output red '\xe2\x9d\x8e') \
	SEPARATOR=$(printf '=%.0s' {1..100}) END="\033[0m" BLACK="\033[0;30m" \
	BLACKB="\033[1;30m" WHITE="\033[0;37m" WHITEB="\033[1;37m" \
	RED="\033[0;31m" REDB="\033[1;31m" GREEN="\033[0;32m" \
	GREENB="\033[1;32m" YELLOW="\033[0;33m" YELLOWB="\033[1;33m" \
	BLUE="\033[0;34m" BLUEB="\033[1;34m" PURPLE="\033[0;35m" \
	PURPLEB="\033[1;35m" LIGHTBLUE="\033[0;36m" LIGHTBLUEB="\033[1;36m" \
	GETOPT_FAIL_MESSAGE="$(getopt --test) failed in this environment" \
	LONGOPTS=mode:,frame:,range:,help: OPTIONS=m:,f:,r:,h:
echo "$LONGOPRS"
! getopt --test > /dev/null
[[ ${PIPESTATUS[0]} -ne 4 ]] && echo "$GETOPT_FAIL_MESSAGE" && exit 1
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" \
	-- "$@")
[[ ${PIPESTATUS[0]} -ne 0 ]] && exit 2
eval set -- "$PARSED"
while true; do
	case "$1" in
		-h | --help) usage; shift; break ;;
		-m | --mode) mode="$2"; shift 2 ;;
		-f | --frame) frame="$2"; shift 2 ;;
		-r | --range) range="$2"; shift 2 ;;
		--) shift; break ;;
		*) format_message "Programming error"; exit 3 ;;
	esac
done
is_value_in_list "$MODES" "$mode" || mode="plus"
is_value_in_list "$FRAMES" "$frame" || frame="list"
[ -z "$range" ] && range=100
case "$frame" in
	list) list_mode "$mode" "$range" ;;
	border) border_mode "$mode" "$range" ;;
	gumlist) gum_list_mode "$mode" "$range" ;;
	gumborder) gum_border_mode "$mode" "$range" ;;
esac
