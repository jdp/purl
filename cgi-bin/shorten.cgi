#!/usr/bin/env bash
set -eu

alphabet="ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789"

case "$REQUEST_METHOD" in
GET)
    url=$(redis-cli get ${PATH_INFO:1})
    if [[ -z "$url" ]]; then
        echo "Status: 404 Not Found"
        echo "Content-Type: text/plain"
        echo && echo "Not Found: $PATH_INFO"
    else
        echo "Status: 301 Moved Permanently"
        echo "Location: $url"
    fi
    ;;
POST)
    if [[ "$CONTENT_LENGTH" -gt 0 ]]; then
        read -n "$CONTENT_LENGTH" url <&0
        shortcode=$(redis-cli get "$url")
        if [[ -z "$shortcode" ]]; then
            id=$(redis-cli incr urls)
            for d in $(echo "obase=${#alphabet}; ibase=10; $id" | bc); do
                shortcode="${alphabet:$((0+$d)):1}$shortcode"
            done
            redis-cli mset "$shortcode" "$url" "$url" "$shortcode" >/dev/null
        fi
        echo "Status: 201 Created"
        echo "Location: /$url"
        echo && echo "$shortcode"
    else
        echo "Status: 400 Bad Request"
        echo "Content-Type: text/plain"
        echo && echo "Must provide a URL and Content-Length header"
    fi
    ;;
*)
    echo "Status: 405 Method Not Allowed"
    echo "Content-Type: text/plain"
    echo && echo "Method $REQUEST_METHOD not allowed"
    ;;
esac
