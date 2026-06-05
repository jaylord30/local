#!/bin/bash

FHIR_URL="http://localhost:8080/fhir"

echo "Creating Patient 1..."

PATIENT1=$(curl -s -X POST "$FHIR_URL/Patient" \
  -H "Content-Type: application/fhir+json" \
  -d '{
    "resourceType":"Patient",
    "identifier":[
      {
        "system":"http://hospital.org/mrn",
        "value":"MDM001"
      }
    ],
    "name":[
      {
        "family":"Smith",
        "given":["John"]
      }
    ],
    "gender":"male",
    "birthDate":"1990-01-01"
  }')

ID1=$(echo "$PATIENT1" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "Patient 1 ID: $ID1"

echo "Creating Patient 2..."

PATIENT2=$(curl -s -X POST "$FHIR_URL/Patient" \
  -H "Content-Type: application/fhir+json" \
  -d '{
    "resourceType":"Patient",
    "identifier":[
      {
        "system":"http://hospital.org/mrn",
        "value":"MDM001"
      }
    ],
    "name":[
      {
        "family":"Smith",
        "given":["John"]
      }
    ],
    "gender":"male",
    "birthDate":"1990-01-01"
  }')

ID2=$(echo "$PATIENT2" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "Patient 2 ID: $ID2"

echo ""
echo "Waiting for MDM processing..."
sleep 5

echo ""
echo "Checking MDM Links..."

curl -s "$FHIR_URL/MdmLink" | jq .

echo ""
echo "Checking Golden Resources..."

curl -s "$FHIR_URL/Patient?_mdm=true" | jq .

echo ""
echo "Checking Source Patient 1..."

curl -s "$FHIR_URL/Patient/$ID1" | jq .

echo ""
echo "Done."
