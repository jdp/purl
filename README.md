# Purl

Purl is a URL shortener, written in bash and backed by [Redis][redis].

## Usage

Purl is a CGI script. The easiest way to run it is with Python's built-in CGI
server:

```
$ python -m CGIHTTPServer
```

### Shortening Links

Post any link to Purl to have it shortened.

```
$ curl localhost:8000/cgi-bin/shorten.cgi -d "http://justinpoliey.com"
3LD
```

### Visiting Shortened Links

Append the shortcode to the URL to Purl and you will be redirected to the
original URL.

```
$ curl localhost:8000/cgi-bin/shorten.cgi/3LD -v 2>&1 | grep Location
< Location: http://justinpoliey.com
```

## Tests

Purl is tested with [BATS][bats].

```
$ bats shorten.bats
```

---

© 2014 Justin Poliey. Licensed under the [ISC license][isc-license].

[bats]: https://github.com/sstephenson/bats
[isc-license]: http://opensource.org/licenses/ISC
[redis]: http://redis.io
