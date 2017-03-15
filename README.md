# jsonish, nginx_jsonish, and nodejs_bunyan parser plugins for Fluentd

## Overview
The jsonish [parser plugin](http://docs.fluentd.org/articles/parser-plugin-overview) for fluentd.  It subclasses the JSONParser to allow for modifications to be made to input test before it is deserialized.  It subclasses the TimeParser to allow time format specifications using Ruby Time class method names instead of strftime format strings -- in particular, the iso8601 method.
:
Two other plugins -- nginx_jsonish and inodejs_bunyan -- are provided, which are simple subclasses of the jsonish parser.  Beyond providing ability to manipulate JSON inputs prior to deserialization, the jsonish parser plugin is a proper extension of the json parser: it can be used wherever the json parser is used with no configuration change required.
The original use case which prompted this work was for parsing nxing access logs in a custom log format attempting to output JSON.  However, this cannot done in a reliable way with with nginx custom log formats, since:

- nginx uses ASCII (ISO-LATIN-1) encoding, using '\xHH' codes whenever it encounters non-ASCII values (or literal '"' characters) which makes for invalid JSON, and
- nginx uses a '-' as a null, so any time a value is not present it ends up creating an invalid key/value pair when the datatype is numeric.

The format is so close to JSON -- all it requires is a couple of gsubs be run on the text before the JSON parser is applied -- that it seemed a saner solution than coming up with a completely different log_format and then have to figure out how to text parse it.

## Installation
```bash
gem install fluent-plugin-jsonish
```

## Configuration

### jsonish

```
<source>
  type [tail|tcp|udp|syslog|http] # any input type which takes a format
  format jsonish
  maps <mappings for text processing prior to the JSON parse>
  null_pattern <the pattern used for nulls in the text>
  null_maps <how the patterns specified by null_pattern should be replaced>
  message_key <key to use for setting the 'message' key in the record>
  add_full_message <whether to the record 'full_message' key to the raw input>
</source>
```

`add_full_message`: whether to set the record "full_message" to the raw input prior to performing any transforms (Boolean: defaults to false)

`message_key`: the hash key to use to set the "message" in the record.
`time_format`: this will accept Time class method names (in particular, "iso8601") in addition to the strftime strings expected by the JsonParser clasee (String: default "iso8601")

`maps`: an array containing "nulls", "slashes", or two-valued arrays containg (regex,replacement_text) pairs.  Defaults to [].

`null_pattern`: the pattern for how nulls are represented in the text.  Defaults to "-" (what nginx uses).

`null_maps`: the an JSON array of two-valued arrays containing a sprintf regex string and substitution text (JSON: default [ [ \"(:\\s+)\"%s\"(\\s*[,}])\", \"\\1null\\2\" ], [ \"(:\\s+)%s(\\s*[,}])\", \"\\1null\\2\" ], [ \"(:\\s+)\\[\\s*%s\\s*\\](\\s*[,}])\", \"\\1[]\\2\" ], [ \"(:\\s+){\\s*%s\\*}(\\s*[,}])\", \"\\1{}\\2\" ] ])

As an example, the nginx_jsonish subclasses the jsonish parser which really only serves to set the needed defaults for nginx access log parsing.  The nginx_jsonish configuration in the next section is essentially equivalent to:

```
<source>
  type tail
  format jsonish
  path <nginx access log file>
  maps ([ "slashes", "nulls" ] automatically prepended to anything set here)
  message_key (set to "request", by default)
  [ standard parser or jsonish arguments ]
</source>
```

The nodejs_bunyan plugin is similar in its behavior in setting needed defaults, although it also performs some needed processing after the JSON deserialization.

### nginx_jsonish
The nginx configuration must be configured to output a "JSONish" format.  As mentioned above, a true JSON format cannot be reliably emitted using an nginx custom log format.  The "time" key, at a minimum, must be set with an ISO-8601 time stamp.  By default, the parser will look for a "request" key and set the "message" to this value.

  Something like the following is probably overkill for most, but it does work:

```
log_format extended  "{ \"time\": \"$time_iso8601\", \"proxy_http_x_forwarded_for\": \"$proxy_add_x_forwarded_for\", \"proxy_x_forwarded_host\": \"$host\", \"proxy_x_forwarded_proto\": \"$scheme\", \"proxy_host\": \"$proxy_host\", \"remote_addr\": \"$remote_addr\", \"remote_port\": \"$remote_port\", \"request\": \"$request\", \"request_method\": \"$request_method\", \"request_uri\": \"$request_uri\", \"request_protocol\": \"$server_protocol\", \"http_accept\": \"$http_accept\", \"http_accept_encoding\": \"$http_accept_encoding\", \"http_accept_language\": \"$http_accept_language\", \"http_connection\": \"$http_connection\", \"sent_http_connection\": \"$sent_http_connection\", \"http_host\": \"$http_host\", \"http_user_agent\": \"$http_user_agent\", \"http_x_forwarded_for\": \"$http_x_forwarded_for\", \"body_bytes_sent\": $body_bytes_sent, \"connection_requests\": $connection_requests, \"proxy_internal_body_length\": $proxy_internal_body_length, \"request_length\": $request_length, \"request_time\": $request_time, \"status\": $status, \"upstream_response_time\": [$upstream_response_time], \"upstream_response_length\": [$upstream_response_length], \"upstream_status\": [$upstream_status], \"gzip_ratio\": $gzip_ratio }";
```

After defining the custom log format, the access log for any virtual host where it's needed must be configured to use it.

```
access_log <log file name> extended;
```

The fluentd parser configuration for this input is straight-forward:

```
<source>
  type tail
  format nginx_jsonish
  path <nginx access log file>
  [ standard parser or jsonish arguments ]
</source>
```

### nodejs_bunyan
This is a parser for Node.js applicatons which use [node-bunyan](https://github.com/trentm/node-bunyan) for logging.  It pretty much takes care of everything, including mapping the "level" from this format to standard [syslog severity levels](https://en.wikipedia.org/wiki/Syslog#Severity_level).

The fluentd parser configuration for this input is straight-forward:

```
<source>
  type tail
  format nodejs_bunyan
  path <application log file name>
  [ standard parser or jsonish arguments ]
</source>
```
