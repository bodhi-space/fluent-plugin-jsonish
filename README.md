# JSONish parser plugin for Fluentd

##Overview
This is a [parser plugin](http://docs.fluentd.org/articles/parser-plugin-overview) for fluentd.



It was created the purpose of modifying text log entries which are very
close to being valid JSON, but aren't quite there (or are none to be
wrong, occassionally -- but in a readily fixable way).  The original
problem was dealing with nginx access logs using a custom log_format in
an attempt to output JSON.  However, this cannot be reliably done since:

- nginx uses ASCII (ISO-LATIN-1) encoding, using '\xHH' codes whenever
it encounters non-ASCII values (or literal '"' characters) which makes
for invalid UTF-8 strings, and
- nginx uses a '-' as a null, so any time a value is not present it
ends up creating an invalid key/value pair when the datatype is numeric.

The format is so close to JSON -- all it requires is a couple of gsubs
be run on the text before the JSON parser is applied -- that it seemed
a saner solution than coming up with a completely different log_format
and then have to figure out how to text parse it.

With no transforms specified, this parser will work just fine as a
JSON parser, with the added bonus that the TimeParser has been
madified to allow parsing of standard time formats using built-in
Time class methods in addition the the current strptime calls --
in particular, the iso8601 method.  The time_format 'iso8601' is
the default for this parser.

##Installation
```bash
gem install fluent-plugin-jsonish
```

##Configuration
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

`maps`: an array containing `nulls`, `slashes`, or two-valued arrays containg (regex,replacement_text) pairs.  Defaults to [].

`null_pattern`: the pattern for how nulls are represented in the text.  Defaults to `-` (what nginx uses).

`null_maps`: the an array of two-valued arrays containing a sprintf regex string and substitution text.



