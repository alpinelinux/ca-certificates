#!/bin/sh

mkcert() {
	local name="$1"
	local line
	rm -f "$name"
	while read line; do
		printf "%s\n" "$line" >> "$name"
		if [ "$line" = "-----END CERTIFICATE-----" ]; then
			break;
		fi
	done
}

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

