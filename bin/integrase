#!/usr/bin/env bash

# This is a script designed to manipulate the Integase json file from stanford
echo -e "===========================Manipulate the Stanford HIV Json file for Integrase========================================================================================================================\n"
echo -e "This program has been developed by; \n\tStephen Kanyerezi (kanyerezi30@gmail.com) & Ivan Sserwadda (ivangunz23@gmail.com)\nFor any assistance, raise an issue on the github repo or reach out to the developers\n"
echo -e "\n======================================================================================================================================================================================================"
echo -e "Program is running .......................................................................................................\nWait for a few seconds"

echo -e "Usage; \n\t\tintegrase <path of directory containg jsons> <path of output directory for the jsons>\n\n"
input=$(echo $1 | sed 's;/$;;') # provide an absolute/relative path for input of json
output=$(echo $2 | sed 's;/$;;') # provide an absolute/relative path for output of resulting json
for i in $(ls ${input}/*json)
do
	# get the codons 
	id=$(basename $i | cut -f1 -d".")
	echo -e "=====================Working on $i========================================="	 
	firstAA=$(grep firstAA ${i} | cut -f2 -d":" | sed 's/,//; s/ //')
	lastAA=$(grep lastAA ${i} | cut -f2 -d":" | sed 's/,//; s/ //')
	
	echo "{" > ${output}/${id}.json
	echo -e "    \"Condons\": \"$firstAA-$lastAA\"," >> ${output}/${id}.json
	
	
	# get subtype
	subtype=$(grep -A1 "\"bestMatchingSubtype\"" ${i} | tail -1 | cut -f2 -d":" | sed 's/,//; s/ //' | cut -f1 -d"(" | sed 's/"//; s/^ [ \t]*//; s/[ \t]*$//')
	
	echo -e "    \"SubType\": \"$subtype\"," >> ${output}/${id}.json
	
	# get other mutations
	
	other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get major mutations
	
	major=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Major\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get accessory mutations
	
	accessory=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Accessory\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	## add the mutations in the json
	
	echo -e "    \"PolymorphismResults\": [" >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"Other\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$other\"" >> ${output}/${id}.json # add the other mutations
	echo -e "        }," >> ${output}/${id}.json
	
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"Major\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$major\"" >> ${output}/${id}.json # add the major mutations
	echo -e "        }," >> ${output}/${id}.json
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"Accessory\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$accessory\"" >> ${output}/${id}.json # add the other mutations
	echo -e "        }" >> ${output}/${id}.json
	echo -e "    ]," >> ${output}/${id}.json
	
	
	# get the drug name, code, and resistance level
	
	sed -z 's/\n/#/g' ${i} | grep -o "\levels\".*"  | cut -f1 -d"]" | sed -z 's/#/\n/g' > drug_level_tmp.txt # creat file having the details
	
	echo -e "    \"DrugScoreGroups\": [" >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Type\": \"INSTI\"," >> ${output}/${id}.json
	echo -e "            \"DrugScores\": [" >> ${output}/${id}.json
	
	for code in `cat drug_level_tmp.txt | grep "\"displayAbbr\"" | cut -f2 -d":" | sed 's/"//g; s/,//g; s/^ [ \t]*//; s/[ \t]*$//'`
	do
		drugname=$(grep -A4 $code drug_level_tmp.txt  |  grep "\"fullName\"" | cut -f2 -d":" | sed 's/"//g; s/^ [ \t]*//; s/[ \t]*$//; s/,//g') # create drugname
		resistancelevel=$(grep -A4 $code drug_level_tmp.txt  |  grep "\"text\"" | cut -f2 -d":" | sed 's/"//g; s/^ [ \t]*//; s/[ \t]*$//; s/,//g') # create resistance leve
		drugnamecode=$(echo "$drugname ($code)") # create drug name code
		echo "                {" >> ${output}/${id}.json # open the individual drug section
		echo -e "                    \"DrugName\": \"$drugname\"," >> ${output}/${id}.json # add the drug name
		echo -e "                    \"DrugCode\": \"$code\"," >> ${output}/${id}.json # add the drug code
		echo -e "                    \"ResistanceLevelText\": \"$resistancelevel\"," >> ${output}/${id}.json # add the resistance level
		echo -e "                    \"DrugNameCode\": \"$drugnamecode\"" >> ${output}/${id}.json # add the drug name code
		echo "                }," >> ${output}/${id}.json # close the individual drug section
	done
	
	# edit the json to remove the last comma
	sed -i -z 's/\n/#/g' ${output}/${id}.json
	sed -i 's/\(,#\)$/#/' ${output}/${id}.json
	sed -i -z 's/#/\n/g' ${output}/${id}.json
	
	# close off the drug section
	echo "            ]" >> ${output}/${id}.json
	echo "        }" >> ${output}/${id}.json
	echo "    ]," >> ${output}/${id}.json
	
	
	# get major comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Major\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":"  | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > major_tmp.txt
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Dosage\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":"  | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' >> major_tmp.txt
	sed -i 's/^/                /' major_tmp.txt # add leading spaces
	sed -i 's/,$//' major_tmp.txt # substitute the last comma with nothing
	
	# get accessory comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Accessory\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":"  | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > accessory_tmp.txt
	sed -i 's/^/                /' accessory_tmp.txt # add leading spaces
	sed -i 's/,$//' accessory_tmp.txt # substitute the last comma with nothing
	
	# get other comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Other\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":"  | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > other_tmp.txt
	sed -i 's/^/                /' other_tmp.txt # add leading spaces
	sed -i 's/,$//' other_tmp.txt # substitute the last comma with nothing
	
	## add the comments to the json
	
	echo -e "    \"ResultComments\": [" >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Group\": \"Major\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat major_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the major comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	echo -e "            \"Group\": \"Accessory\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat accessory_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the accessory comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	echo -e "            \"Group\": \"Other\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat other_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the major comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }" >> ${output}/${id}.json
	echo -e "    ]" >> ${output}/${id}.json
	echo -e "}" >> ${output}/${id}.json
	
	
	## remove temporary files
	rm *tmp*
	echo -e "=============================Completed $i======================================================"
done

echo -e "\n\n\nResults are in: $output"
