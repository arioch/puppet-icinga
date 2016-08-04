#!/bin/bash

set -o pipefail

PROGRAM_NAME="$1"

[[ -z "$PROGRAM_NAME" ]] && { echo "The parameter with program name is missing"; exit 3; }
which jq &>/dev/null || { echo 'Jq is not installed'; exit 3; }

INTERVAL=${2:-15 minutes ago}
CURRENT_EPOCH=$(date +%s%N | cut -b1-13)  # ES uses epoch format in miliseconds
CURRENT_EPOCH_15MIN_LESS=$(date +%s%N -d "$INTERVAL" | cut -b1-13)
TWO_LATEST_INDEXES=$(curl -s 'localhost:9200/_stats/indexes' | jq -r '.indices | keys | .[]' | grep logstash | sort | tail -n2 | tr '\n' ',')

[[ "$?" != 0 ]] && { echo "The request for the list of indexes failed"; exit 3; }

NUMBER_OF_EVENTS=$(curl -s "localhost:9200/${TWO_LATEST_INDEXES}/syslog/_search?pretty" -d "{
  \"size\": 0,
  \"aggs\": {},
  \"query\": {
    \"filtered\": {
      \"query\": {
        \"query_string\": {
          \"analyze_wildcard\": true,
          \"query\": \"*\"
        }
      },
      \"filter\": {
        \"bool\": {
          \"must\": [
            {
              \"query\": {
                \"match\": {
                  \"program\": {
                    \"query\": \"${PROGRAM_NAME}\",
                    \"type\": \"phrase\"
                  }
                }
              }
            },
            {
              \"query\": {
                \"exists\": {
                  \"field\": \"json_data.data.routing_key\"
                }
              }
            },
            {
              \"range\": {
                \"@timestamp\": {
                  \"gte\": ${CURRENT_EPOCH_15MIN_LESS},
                  \"lte\": ${CURRENT_EPOCH},
                  \"format\": \"epoch_millis\"
                }
              }
            }
          ],
          \"must_not\": []
        }
      }
    }
  }
}" |
jq -r '.hits.total')

[[ "$?" != 0 ]] && { echo "The request for the actually processed data failed"; exit 3; }

if [[ "$NUMBER_OF_EVENTS" -gt 5 ]]
then
  echo "OK - ${NUMBER_OF_EVENTS} events were processed during range: '${INTERVAL}'" && exit 0
elif [[ "$NUMBER_OF_EVENTS" -gt 0 ]]
then
  echo "WARNING - only ${NUMBER_OF_EVENTS} event(s) was/were processed during range: '${INTERVAL}'" && exit 1
else
  echo "ERROR - No event was processed during range: '${INTERVAL}'" && exit 2
fi
