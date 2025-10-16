#! /bin/bash

OUTPUT_FILE="alerts.json"
TEMP_FILE=$(mktemp)

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "[]" > "$OUTPUT_FILE"
    echo "Created new JSON file"
fi


curl -X GET https://api.weather.gov/alerts | 
    jq '[.features[]| {
    id: .properties.id, 
    headline: .properties.headline, 
    description: .properties.description,
    event: .properties.event, 
    certainty: .properties.certainty, 
    response: .properties.response, 
    severity: .properties.severity, 
    sent: .properties.sent,
    urgency: .properties.urgency, 
    effective: .properties.effective, 
    onset: .properties.onset, 
    ends: .properties.ends,
    areaDesc: .properties.areaDesc,
    geoCode: .properties.geocode,
    affectedZones: .properties.affectedZones
    }]' >> $TEMP_FILE

jq -s 'add | unique_by(.id)' "$OUTPUT_FILE" "$TEMP_FILE" > "$OUTPUT_FILE.tmp" 
mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

echo "Weather alerts updated and merged into $OUTPUT_FILE"

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@useres.noreply.github.com"
git add "$OUTPUT_FILE"
git commit -m "Daily weather alert update" || echo "No changes"
git push origin master