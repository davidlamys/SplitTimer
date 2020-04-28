#!/usr/bin/env bash
#!/bin/bash
rome download --platform iOS # download missing frameworks (or copy from local cache)
carthage bootstrap --platform iOS --cache-builds # build dependencies missing a .version file or that where not found in the cache
rome list --missing --platform iOS | awk '{print $1}' | xargs -I {} rome upload "{}" --platform iOS # upload what is missing