#!/usr/bin/env bats

function shorten() {
    local url="$1"
    echo "$url" | REQUEST_METHOD="POST" CONTENT_LENGTH="${#url}" ./cgi-bin/shorten.cgi
}

function unshorten() {
    local shortcode="$1"
    REQUEST_METHOD="GET" PATH_INFO="/$shortcode" ./cgi-bin/shorten.cgi
}

@test "shortening a url should have status 201" {
    response=$(shorten "http://test.com")
    grep -q "Status: 201" <(echo "$response")
}

@test "shortening a url should have a Location header" {
    response=$(shorten "http://test.com")
    grep -q "Location:" <(echo "$response")
}

@test "fetching a valid short url should redirect to the original url" {
    url="http://test.com"
    response=$(shorten "$url")
    shortcode=$(echo "$response" | tail -r -n 1)
    response=$(unshorten "$shortcode")
    grep -q "Location: $url" <(echo "$response")
}

@test "fetching an invalid short url should have status 404" {
    response=$(unshorten foo)
    grep -q "Status: 404" <(echo "$response")
}

@test "shortening an duplicate URL should return the same short code" {
    url="http://duplicate.com"
    response=$(shorten "$url")
    shortcode1=$(echo "$response" | tail -r -n 1)
    response=$(shorten "$url")
    shortcode2=$(echo "$response" | tail -r -n 1)
    [[ "$shortcode1" = "$shortcode2" ]]
}
