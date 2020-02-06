#!/bin/sh

prev=
while read line; do
	case "$line" in
	=*=)
		fname="$(printf "%s" "$prev" | tr '/ (),' '__==_').crt"
		while read cline; do
			printf "%s\n" "$cline"
			if [ "$cline" = "-----END CERTIFICATE-----" ]; then
				break;
			fi
		done > "$fname"
		;;
	esac
	prev="$line"
done

