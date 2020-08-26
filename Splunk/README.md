
SPL: Search Processing Language

Set password in "standalone-*.yml", then run `docker-compose -f standalone-{mode}.yml up` to start up a container for Splunk.

Access Splunk via "127.0.0.1:8000" in browser. Default user name is "admin", while password is the one you specify.

For experiments, its suggested to create Splunk containers via "standalone-uf.yml" then add "demo_data.csv" as the source.


## Concept

### Basic

There are four phases for Splunk data pipeline:
1. Input: any data souces (monitored, fowarded, etc)
    - local input
    - using forwarders
    - network feeds
    - HTTP Event Collector (HEC)
        - send data and application logs to Splunk over HTTP(s)
        - token based authentication
        - forwarder is not needed
2. Parsing: analyze and transform data, annotate metadata
3. Indexing: take the parsed data and write to indexes on disk as file on the indexer (buckets)
4. Searching: used for users to interact with data

Index:
- a repository for Splunk data
- built-in indexes, "main", "_internal"
- Splunk transforms incoming data into events, and stores it in indexes

Event:
- a single row of data
- data is specified by fields (key-value pairs)
- Splunk adds default fields to all events (Timestamp, Host, Source, Sourcetype)

Splunk stores index data in buckets:
- Hot:      $SPLUNK_HOME/var/lib/splunk/defaultdb/db/*
- Warm:     $SPLUNK_HOME/var/lib/splunk/defaultdb/db/*
- Cold:     $SPLUNK_HOME/var/lib/splunk/defaultdb/colddb/*
- Frozen:   specified path
- Thawed:   $SPLUNK_HOME/var/lib/splunk/defaultdb/thaweddb/*

App:
- an app is a collection of Splunk configuration files
- an add-on is a subset of an app
- add-ons specify data collection, but do not have GUIs since they are part of the larger app

Forwarder:
- Universal Forwarder
    - installed at the local machine, can be configured using a deployment server
    - default forwarding port: 9997
- Heavy Forwarder
    - a complete installation of Splunk software, but with a forwarder license applied
    - does much of the "heavy lifting" at the source, which can parse and index data
    - can be configured at the source, and through a deployment server

To explore more data via universal forwarder, get into the universal forwarder container then run `sudo ./{SPLUNK_FORWARDER_HOME}/bin/splunk add monitor {folder}` to add logs wanted for monitor.


Note that forwarding data to a Splunk indexer / search head won't work unless the indexer / search head is configured to receive the data.

__Deloyment Server__ is a configuration management tool, which can be replaced by other tools like Chef, while __Deployer__ is a component that manages Search Head clusters specifically.

### Advanced

Deployment Server:
- Allows you to manage groups of Splunk Enterprise instances from a central location
- Identifies clients and subscribes them to server classes
- A server class defines a group of Splunk deployment apps and adds them to it’s member criteria
- Deplyment apps are located in {SPLUNK_HOME}/etc/deployment-apps/

Configuration:
- Configuration files are located in {SPLUNK_HOME}/etc/system/
- Each app has its own set of configuration files in their local, for example, {SPLUNK_HOME}/etc/apps/{app}/
- Configuration files in the default/ directories come with Splunk and have default settings
- Specific changes/configurations should be made in the local/ directory
- When Splunk starts, configuration files are merged into a single runtime model
- The resulting runtime model is the union of all files if there are no duplicate stanzas
- The setting with the highest precedence is used when there are conflicts, the configuration precedence follows:
    - system/local/
    - app/local/
    - app/default/
    - system/default/

Important configuration files:

| File | Purpose |
| --- | --- |
| Inputs.conf | Defines data inputs |
| Outputs.conf | Defines forwarding behavior |
| Props.conf | Indexing property configurations, custom source type rules, and more |
| Limits.conf | Defines various limits for search commands |


## Search

The search box follows pattern like: `{search term} {command} | ...`. For example, `host=demo_data domain=* usr=* type=fail* OR lock* | table usr domain type _time | sort type -_time`.


Basic search terms:
- wildcard: *
- keywords: failed, error, ...
- phrases: failed, login, ...
- booleans: AND, OR, NOT
- fields: {key}={value}

Basic search commands:
- `chart`/`timechart`
- `stats`
- `rename`
- `eval`
- `dedup`
- `sort`
- `table`


### Time

- `_time` is a Splunk-generated defaul field that represents time
- timestamps are usually added automatically based on the event raw data
- if time and date are not included in the event raw data, Splunk would attempt to "guess" at a timestamp
- Splunk will set the timestamp to the system time as a last resort

Use `eval time=strftime(_time, "{format}")` to convert time into the format wanted. Below is the conversion format:

| Time Variable | Description |
| --- | --- |
| %H | hour (24 hour clock)  |
| %I | hour (12 hour clock) |
| %M | minute |
| %S | second |
| %p | am/pm |
| %A | full day name |
| %d | day of month |
| %e | day of month without leading 0 |
| %B | full month name |
| %b | abbreviated month name |
| %m | month in number |
| %Y | year in four digits |
| %y | year in two digits |



## Reference

- Docker Splunk: https://github.com/splunk/docker-splunk
