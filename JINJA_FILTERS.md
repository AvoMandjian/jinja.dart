# Jinja Filters Reference

This document provides a comprehensive list of Jinja filters available, including their descriptions and usage examples.

| Filter | Description | Example |
| :--- | :--- | :--- |
| `abs` | Return the absolute value of the argument. | `{{ -5\|abs }}` → `5` |
| `all` | Return `True` if none of the elements of the (async) iterable are false. | `{{ [True, True, False]\|all }}` → `False` |
| `any` | Returns `True` if any item in an iterable is true, otherwise `False`. If empty, returns `False`. | `{{ [0, 1, 0]\|any }}` → `True` |
| `as_timezone` | Convert a datetime object to a different timezone. | `{{ "2025-09-24 12:00"\|as_datetime\|as_timezone("US/Eastern") }}` |
| `attr` | Get an attribute of an object. | `{{ user\|attr("name") }}` → `Aharon` |
| `base64` | Encode a string in base64. | `{{ "hello"\|base64 }}` → `aGVsbG8=` |
| `basename` | Get the last name of a windows style file path. | `{{ "/home/user/file.txt"\|basename }}` → `file.txt` |
| `batch` | Batches items. Returns a list of lists with the given number of items. | `{% for group in [1,2,3,4,5]\|batch(2) %}...` |
| `capitalize` | Capitalize a value. The first character will be uppercase, all others lowercase. | `{{ "hello world"\|capitalize }}` → `Hello world` |
| `center` | Centers the value in a field of a given width. | `{{ "hi"\|center(6, "-") }}` → `--hi--` |
| `combine` | Merges hashes (dictionaries). | `{{ {"a":1, "b":2}\|combine({"b":3, "c":4}) }}` → `{'a': 1, 'b': 3, 'c': 4}` |
| `convert_from_epoch` | Convert an epoch timestamp to a datetime object. | `{{ 0\|convert_from_epoch }}` → `1970-01-01 00:00:00` |
| `count` | Return the number of items in a container. | `{{ "banana"\|count("a") }}` → `3` |
| `csv` | Dump a list of rows to CSV format. | `{{ ["red","blue","green"]\|csv }}` → `red,blue,green` |
| `d` | Alias for `default`. If value is undefined, returns default value. | `{{ variable\|d("fallback") }}` → `fallback` |
| `datedelta` | Add or subtract a number of years, months, weeks, or days from a datetime. | `{{ "2025-09-24"\|as_datetime\|datedelta(days=7) }}` |
| `decode_base64` | Decode a base64-encoded string and return it as a UTF-8 string. | `{{ "aGVsbG8="\|decode_base64 }}` → `hello` |
| `default` | If value is undefined, returns default value. | `{{ none_value\|default("N/A") }}` → `N/A` |
| `dict` | Transforms lists into dictionaries. | `{{ dict(a=1, b=2) }}` → `{'a': 1, 'b': 2}` |
| `dictsort` | Sort a dict and yield (key, value) pairs. | `{% for k,v in {"b":2,"a":1}\|dictsort %}...` |
| `dirname` | Get the directory from a path. | `{{ "/home/user/file.txt"\|dirname }}` → `/home/user` |
| `e` | Alias for `escape`. Replace characters with HTML-safe sequences. | `{{ "Hello!"\|e }}` → `&lt;div&gt;Hello!&lt;/div&gt;` |
| `enumerate` | Iterate with index and element. | `{% for i, v in ["cat","dog"]\|enumerate %}...` |
| `escape` | Replace characters with HTML-safe sequences. | `{{ "5 > 3"\|escape }}` → `5 &amp;gt; 3` |
| `filesizeformat` | Format the value like a 'human-readable' file size. | `{{ 1234567\|filesizeformat }}` → `1.2 MB` |
| `first` | Return the first item of a sequence. | `{{ [10,20,30]\|first }}` → `10` |
| `flatten` | Flatten a list of lists. | `{{ [[1,2],[3,4]]\|flatten }}` → `[1, 2, 3, 4]` |
| `float` | Convert the value into a floating point number. | `{{ "3.14"\|float }}` → `3.14` |
| `forceescape` | Enforce HTML escaping. | `{{ "italic"\|forceescape }}` → `&lt;i&gt;italic&lt;/i&gt;` |
| `format` | Apply values to a printf-style format string. | `{{ "Hello, {}"\|format("Aharon") }}` → `Hello, Aharon` |
| `format_datetime` | Return a string representation of a datetime in a particular format. | `{{ "2025-09-24 15:30"\|as_datetime\|format_datetime("%Y/%m/%d %H:%M") }}` |
| `from_json_string` | Deserialize from a JSON-serialized string. | `{{ '{"a":1,"b":2}'\|from_json_string }}` → `{'a': 1, 'b': 2}` |
| `from_yaml_string` | Deserialize from a YAML-serialized string. | `{{ "a: 1\nb: 2"\|from_yaml_string }}` → `{'a': 1, 'b': 2}` |
| `groupby` | Group a sequence of objects by an attribute. | `{% for group, items in list\|groupby("type") %}...` |
| `hmac` | Return the bytes digest of the HMAC. | `{{ "message"\|hmac("secret") }}` → `6e7a...` |
| `hex` | Returns hex representations of bytes objects and UTF-8 strings. | `{{ 255\|hex }}` → `0xff` |
| `indent` | Return a copy of the string with each line indented. | `{{ "line1\nline2"\|indent(4) }}` |
| `int` | Convert the value into an integer. | `{{ "42"\|int }}` → `42` |
| `is_json` | Determines whether or not a string can be converted to a JSON object. | `{{ '{"x":1}'\|is_json }}` → `True` |
| `is_type` | Checks the type of the object. | `{{ 123\|is_type("int") }}` → `True` |
| `items` | Return an iterator over the (key, value) items of a mapping. | `{% for k,v in {"a":1,"b":2}\|items %}...` |
| `join` | Concatenate strings in a sequence. | `{{ ["a","b","c"]\|join(",") }}` → `a,b,c` |
| `json` | Parse a JSON-serialized string. | `{{ {"a":1,"b":2}\|json }}` → `{"a": 1, "b": 2}` |
| `json_dump` | Serialize value to JSON. | `{{ [1,2,3]\|json_dump }}` → `[1, 2, 3]` |
| `json_escape` | Add escape sequences to problematic characters in the string. | `{{ '"Hello"'\|json_escape }}` → `\"Hello\"` |
| `json_parse` | Deserialize from a JSON-serialized string. | `{{ '{"x":10,"y":20}'\|json_parse }}` → `{'x': 10, 'y': 20}` |
| `json_stringify` | Serialize value to JSON. | `{{ {"fruit":"apple"}\|json_stringify }}` → `{"fruit": "apple"}` |
| `jsonpath_query` | Extracts data from an object value using a JSONPath query. | `{{ {"person":{"name":"Aharon"}}\|jsonpath_query("$.person.name") }}` |
| `last` | Return the last item of a sequence. | `{{ [5,6,7]\|last }}` → `7` |
| `length` | Return the number of items in a container. | `{{ "banana"\|length }}` → `6` |
| `list` | Create a list from an iterable. | `{{ "abc"\|list }}` → `['a', 'b', 'c']` |
| `load_datetime` | Parse a datetime string with a known format. | `{{ "2025-09-24 14:30"\|load_datetime }}` |
| `lower` | Convert a value to lowercase. | `{{ "HELLO WORLD"\|lower }}` → `hello world` |
| `map` | Applies a filter on a sequence of objects or looks up an attribute. | `{{ list\|map(attribute="name")\|list }}` |
| `max` | Return the largest item from an iterable. | `{{ [3, 9, 2]\|max }}` → `9` |
| `min` | Return the smallest item from an iterable. | `{{ [3, 9, 2]\|min }}` → `2` |
| `parse_csv` | Parse a CSV string into a list of dicts. | `{{ "name,age\nAna,30"\|parse_csv }}` |
| `parse_datetime` | Parse a datetime string without knowing its format specification. | `{{ "2025-09-24 15:45"\|parse_datetime }}` |
| `pprint` | Pretty print a variable. | `{{ {"a":[1,2]}\|pprint }}` |
| `random` | Return a random item from the sequence. | `{{ ["red","blue","green"]\|random }}` |
| `reduce` | Reduce an iterable by cumulative application of a function. | `{{ [1,2,3]\|reduce('add', 0) }}` → `6` |
| `regex_findall` | Find occurrences of regex matches in a string. | `{{ "a1 b22"\|regex_findall("\d+") }}` → `['1', '22']` |
| `regex_match` | Determine if a string matches a particular pattern. | `{{ "abc123"\|regex_match("^abc\d+") }}` → `True` |
| `regex_replace` | Replace text in a string with regex. | `{{ "foo-123-bar"\|regex_replace("\d+", "#") }}` → `foo-#-bar` |
| `regex_search` | Search in a string with a regular expression. | `{{ "id=42"\|regex_search("\d+") }}` → `True` |
| `regex_substring` | Find substrings match a pattern and return substring at index. | `{{ "user: Aharon"\|regex_substring("user:\s*(\w+)", 1) }}` |
| `reject` | Filter sequence by rejecting objects where test succeeds. | `{{ [1,2,3,4]\|reject('odd')\|list }}` → `[2, 4]` |
| `rejectattr` | Filter sequence by rejecting objects where attribute test succeeds. | `{{ list\|rejectattr("active")\|list }}` |
| `replace` | Replace occurrences of a substring with a new one. | `{{ "hello world"\|replace("world","Aharon") }}` |
| `reverse` | Reverse the object. | `{{ [1,2,3]\|reverse\|list }}` → `[3, 2, 1]` |
| `round` | Round the number to a given precision. | `{{ 3.14159\|round(2) }}` → `3.14` |
| `safe` | Mark the value as safe (no escaping). | `{{ "bold"\|safe }}` → `&lt;b&gt;bold&lt;/b&gt;` |
| `select` | Filter sequence by selecting objects where test succeeds. | `{{ [1,2,3,4]\|select('even')\|list }}` → `[2, 4]` |
| `selectattr` | Filter sequence by selecting objects where attribute test succeeds. | `{{ list\|selectattr("active")\|list }}` |
| `set` | Create a set from an iterable. | `{% set msg = "hello" %}` |
| `slice` | Slice an iterator and return a list of lists. | `{% for col in [1,2,3,4,5]\|slice(2) %}...` |
| `sort` | Sort an iterable. | `{{ [3,1,2]\|sort }}` → `[1, 2, 3]` |
| `string` | Convert an object to a string. | `{{ 123\|string }}` → `123` |
| `striptags` | Strip SGML/XML tags. | `{{ "&lt;p&gt;Hello&lt;/p&gt;"\|striptags }}` → `Hello` |
| `sum` | Returns the sum of a sequence of numbers. | `{{ [1,2,3]\|sum }}` → `6` |
| `time_delta` | Add a duration of time to a datetime. | |
| `title` | Return a titlecased version of the value. | `{{ "hello world"\|title }}` → `Hello World` |
| `to_ascii` | Transliterate a Unicode object into an ASCII string. | `{{ "café"\|to_ascii }}` → `cafe` |
| `to_human_time_from_seconds` | Returns a fuzzy version of time from seconds. | `{{ 3661\|to_human_time_from_seconds }}` → `1:01:01` |
| `to_json_string` | Serialize value to JSON. | `{{ {"a":1}\|to_json_string }}` → `{"a": 1}` |
| `to_yaml_string` | Serialize to YAML. | `{{ {"a":1}\|to_yaml_string }}` → `a: 1` |
| `tojson` | Serialize object to JSON string (HTML safe). | `{{ [1,2,3]\|tojson }}` → `[1, 2, 3]` |
| `trim` | Strip leading and trailing whitespace. | `{{ " hello "\|trim }}` → `hello` |
| `truncate` | Return a truncated copy of the string. | `{{ "Long sentence"\|truncate(10) }}` |
| `tuple` | Create a tuple from an iterable. | `{{ (1,2,3)\|tuple }}` → `(1, 2, 3)` |
| `unidecode` | Transliterate Unicode to ASCII. | `{{ "北京"\|unidecode }}` → `Bei Jing` |
| `unique` | Returns a list of unique items. | `{{ [1,2,2,3,1]\|unique\|list }}` → `[1, 2, 3]` |
| `upper` | Convert a value to uppercase. | `{{ "hello"\|upper }}` → `HELLO` |
| `urldecode` | Decode URL component. | `{{ "name%3DLisa"\|urldecode }}` → `name=Lisa` |
| `urlencode` | Quote data for use in a URL path or query. | `{{ "name=Lisa"\|urlencode }}` → `name%3DLisa` |
| `urlize` | Convert URLs in text into clickable links. | `{{ "Visit http://example.com"\|urlize }}` |
| `use_none` | Convert None value to magic string. | `{{ undefined\|use_none }}` → `None` |
| `version_bump_major` | Increment major version. | `{{ "1.2.3"\|version_bump_major }}` → `2.0.0` |
| `version_bump_minor` | Increment minor version. | `{{ "1.2.3"\|version_bump_minor }}` → `1.3.0` |
| `version_bump_patch` | Increment patch version. | `{{ "1.2.3"\|version_bump_patch }}` → `1.2.4` |
| `version_compare` | Compare two version numbers. | `{{ "1.2.3"\|version_compare("2.0.0") }}` → `-1` |
| `version_equal` | Check if version equals pattern. | `{{ "1.2.3"\|version_equal("1.2.3") }}` → `True` |
| `version_less_than` | Check if version is less than pattern. | `{{ "1.2.3"\|version_less_than("1.3.0") }}` → `True` |
| `version_match` | Check if version matches range pattern. | `{{ "1.2.3"\|version_match("1.2.*") }}` → `True` |
| `version_more_than` | Check if version is greater than pattern. | `{{ "2.0.0"\|version_more_than("1.9.9") }}` → `True` |
| `version_strip_patch` | Remove patch version component. | `{{ "1.2.3"\|version_strip_patch }}` → `1.2` |
| `wordcount` | Count the words in the string. | `{{ "one two three"\|wordcount }}` → `3` |
| `wordwrap` | Wrap a string to the given width. | `{{ "Hello world"\|wordwrap(5) }}` |
| `wrap_text` | Wrap text to a specified width with newlines. | `{{ "abcdefghi"\|wrap_text(3) }}` |
| `xmlattr` | Create an SGML/XML attribute string from a dict. | `{{ {"id":"main"}\|xmlattr }}` → `id="main"` |
| `yaml_dump` | Serialize to YAML. | `{{ {"a":1}\|yaml_dump }}` → `a: 1` |
| `yaml_parse` | Deserialize from a YAML-serialized string. | `{{ "a: 1"\|yaml_parse }}` → `{'a': 1}` |
| `zip` | Return a list of tuples from multiple lists. | `{% for pair in [1,2]\|zip(['a','b']) %}...` |
