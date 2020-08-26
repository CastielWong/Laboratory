
SPL: Search Processing Language

Set password in "standalone-*.yml", then run `docker-compose -f standalone-{mode}.yml up` to start up a container for Splunk.

Access Splunk via "127.0.0.1:8000" in browser. User name is "admin", while password is the one you specify.




## Concept

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

Note that forwarding data to a Splunk indexer / search head won't work unless the indexer / search head is configured to receive the data.


## Search

The search box follows pattern like: `{search term} {command} | ...`。 For example, `sourcetype=WinEventLog:Security EventCode=4625 user=* | stats count(EventCode) by user _time | table _time user count(EventCode) | sort -_time`

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


## Reference

- Docker Splunk: https://github.com/splunk/docker-splunk
