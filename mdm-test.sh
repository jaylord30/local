#!/bin/bash

FHIR_URL="http://localhost:8080/fhir"

echo "Creating Patient 1..."

PATIENT1=$(curl -s -X POST "$FHIR_URL/Patient" \
-H "Content-Type: application/fhir+json" \
-d '
{
 "resourceType":"Patient",

 "meta":{
   "profile":[
     "https://fhir.doh.gov.ph/phcore/StructureDefinition/PHCore-Patient"
   ]
 },

 "identifier":[
   {
    "system":"https://philhealth.gov.ph",
    "value":"PH123456789"
   },
   {
    "system":"http://hospital.smarthealth.org/mrn",
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
}
')


ID1=$(echo "$PATIENT1" | jq -r '.id')

echo "Patient 1 ID: $ID1"



echo "Creating Patient 2..."


PATIENT2=$(curl -s -X POST "$FHIR_URL/Patient" \
-H "Content-Type: application/fhir+json" \
-d '
{
 "resourceType":"Patient",

 "meta":{
   "profile":[
    "https://fhir.doh.gov.ph/phcore/StructureDefinition/PHCore-Patient"
   ]
 },

 "identifier":[
   {
    "system":"https://philhealth.gov.ph",
    "value":"PH123456789"
   },
   {
    "system":"http://hospital.smarthealth.org/mrn",
    "value":"MDM999"
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
}
')


ID2=$(echo "$PATIENT2" | jq -r '.id')

echo "Patient 2 ID: $ID2"


echo ""
echo "Waiting for MDM..."
sleep 10


echo ""
echo "Checking MDM links"

curl -s "$FHIR_URL/MdmLink?_count=10" | jq .


echo ""
echo "Checking golden patients"

curl -s "$FHIR_URL/Patient?_mdm=true" | jq .


echo ""
echo "Done"