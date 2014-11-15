#!/usr/bin/env bats

@test "shortening a url should have status 201" {
    url="http://test.com"
    response=$(echo "$url" | REQUEST_METHOD="POST" CONTENT_LENGTH="${#url}" ./cgi-bin/shorten.cgi)
    grep -q "Status: 201" <(echo "$response")
}

@test "shortening a url should have a Location header" {
    url="http://test.com"
    response=$(echo "$url" | REQUEST_METHOD="POST" CONTENT_LENGTH="${#url}" ./cgi-bin/shorten.cgi)
    grep -q "Location:" <(echo "$response")
}

@test "fetching a valid short url should redirect to the original url" {
    url="http://test.com"
    response=$(echo "$url" | REQUEST_METHOD="POST" CONTENT_LENGTH="${#url}" ./cgi-bin/shorten.cgi)
    shortcode=$(echo "$response" | tail -r -n 1)
    response=$(REQUEST_METHOD="GET" PATH_INFO="/$shortcode" ./cgi-bin/shorten.cgi)
    grep -q "Location: $url" <(echo "$response")
}

@test "fetching an invalid short url should have status 404" {
    response=$(REQUEST_METHOD="GET" PATH_INFO="/foo" ./cgi-bin/shorten.cgi)
    grep -q "Status: 404" <(echo "$response")
}

@test "shortening an duplicate URL should return the same short code" {
    url="http://duplicate.com"
    response=$(echo "$url" | REQUEST_METHOD="POST" CONTENT_LENGTH="${#url}" ./cgi-bin/shorten.cgi)
    shortcode1=$(echo "$response" | tail -r -n 1)
    response=$(echo "$url" | REQUEST_METHOD="POST" CONTENT_LENGTH="${#url}" ./cgi-bin/shorten.cgi)
    shortcode2=$(echo "$response" | tail -r -n 1)
    [[ "$shortcode1" = "$shortcode2" ]]
}
