#!/usr/bin/env bash

# This is a script designed to manipulate the RTPR json file from stanford

echo -e "===========================Manipulate the Stanford HIV Json file for RTPR========================================================================================================================\n"
echo -e "This program has been developed by; \n\tStephen Kanyerezi (kanyerezi30@gmail.com) & Ivan Sserwadda (ivangunz23@gmail.com)\nFor any assistance, raise an issue on the github repo or reach out to the developers\n"
echo -e "\n======================================================================================================================================================================================================"

help()
{
        # Display Help
        echo -e "Usage: integrase  <path of directory containg jsons>  <path of output directory for the jsons>"
}

while getopts ":h" option
do
        case $option in
                h) # display help
                        help
                        exit;;
                \?) # Invalid option
                        echo "Error: Invalid option"
                        help
                        exit;;
        esac
done

if [[ $# -ne 2 ]]
then
        echo "Wrong number of arguments"
        help
        exit 1
fi


echo -e "Program is running .......................................................................................................\nWait for a few seconds"

# get the codons 
input=$(echo $1 | sed 's;/$;;') # provide an absolute/relative path for input of json
output=$(echo $2 | sed 's;/$;;') # provide an absolute/relative path for output of resulting json
for i in $(ls ${input}/*json)
do
	id=$(basename $i | cut -f1 -d".")
	echo -e "=====================Working on $i=========================================" 
	firstAA=$(grep firstAA ${i} | cut -f2 -d":" | sed 's/,//; s/ //' | head -1)
	lastAA=$(grep lastAA ${i} | cut -f2 -d":" | sed 's/,//; s/ //' | tail -1)

	echo "{" > ${output}/${id}.json
	echo -e "    \"Condons\": \"$firstAA-$lastAA\"," >> ${output}/${id}.json
	
	# get subtype
	subtype=$(grep -A1 "\"bestMatchingSubtype\"" ${i} | tail -1 | cut -f2 -d":" | sed 's/,//; s/ //' | cut -f1 -d"(" | sed 's/"//; s/^ [ \t]*//; s/[ \t]*$//')
	
	echo -e "    \"SubType\": \"$subtype\"," >> ${output}/${id}.json
	
	
	# get PI major mutations
	major=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Major\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get PI accessory mutations
	accessory=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Accessory\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get PI other mutations
	#pi_other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | awk 'BEGIN {FS="\"mutationType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get nrti mutations
	nrti=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"NRTI\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get nnrti mutations
	nnrti=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"NNRTI\".*" | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	
	# get rt other mutations
	#rt_other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | awk 'BEGIN {FS="\"mutationType\": \"Other\""} {print $3}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	
	## working with other mutations
	other_cnt=$(grep -co "\"mutationType\": \"Other\".*" ${i}) # count the number of occurrences
	if [ ${other_cnt} -eq 2 ]
	then
		# get PI other mutations
		pi_other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | awk 'BEGIN {FS="\"mutationType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')	
		# get rt other mutations
		rt_other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | awk 'BEGIN {FS="\"mutationType\": \"Other\""} {print $3}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
	elif [ ${other_cnt} -eq 1 ]
	then
		# check which class
		class=$(awk '/\"mutationsByTypes\"/,/\"mutationType\": \"Other\"/' ${i} | grep -A3 "\"mutationsByTypes\"" | grep "\"name\": \"PI\"" | cut -f2 -d":" | sed 's/"//g; s/,//; s/^ [ \t]*//')
		if [ ${class} == PI ]
		then
			pi_other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | awk 'BEGIN {FS="\"mutationType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
			rt_other=""
		else
			pi_other=""
			rt_other=$(sed -z 's/\n/#/g' ${i} | grep -o "\"mutationType\": \"Other\".*" | awk 'BEGIN {FS="\"mutationType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "text" | cut -f2 -d":" | sed 's/"//g' | sed -z 's/\n//g; s/,$/\n/; s/^ [ \t]*//; s/[ \t]*$//')
		fi
	else
		pi_other=""
		rt_other=""
	fi
	## Add the mutations to the json
	
	# add PI major mutations
	
	echo -e "    \"PolymorphismResults\": [" >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"PI Major\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$major\"" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	
	
	# add PI accessory mutations
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"PI Accessory\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$accessory\"" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	
	
	# add PI other mutations
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"PI Other\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$pi_other\"" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	
	
	# add NRTI mutations
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"NRTI\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$nrti\"" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	
	# add NNRTI mutations
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"NNRTI\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$nnrti\"" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	
	# add RT other mutations
	
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Classification\": \"RT Other\"," >> ${output}/${id}.json
	echo -e "            \"Result\": \"$rt_other\"" >> ${output}/${id}.json
	echo -e "        }" >> ${output}/${id}.json
	
	# close off the mutation section
	echo -e "    ]," >> ${output}/${id}.json
	
	
	# get the drug name, code, and resistance level
	echo -e "    \"DrugScoreGroups\": [" >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Type\": \"PI\"," >> ${output}/${id}.json
	echo -e "            \"DrugScores\": [" >> ${output}/${id}.json
	
	## get those for PI
	for code in `cat database.txt | grep PI | cut -f1`
	do
		drugname=$(grep -E -B4 " Resistance\"|Susceptible" ${i}  | grep -Ev "Drug|}" | grep -A2 $code | grep "fullName" | cut -f2 -d: | sed 's/"//g' | sed 's/,$//' |  sed 's/^ [ \t]*//; s/[ \t]*$//') # create drugname
		resistancelevel=$(grep -E -B4 " Resistance\"|Susceptible" ${i}  | grep -Ev "Drug|}" | grep -A2 $code | grep "text" | cut -f2 -d: | sed 's/"//g' | sed 's/,$//' |  sed 's/^ [ \t]*//; s/[ \t]*$//') # create resistance level
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
	
	# close off the PI drug section
	echo "            ]" >> ${output}/${id}.json
	echo "        }," >> ${output}/${id}.json
	
	
	
	## get those for nrti
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Type\": \"NRTI\"," >> ${output}/${id}.json
	echo -e "            \"DrugScores\": [" >> ${output}/${id}.json
	
	for code in `cat database.txt | grep -w NRTI | cut -f1`
	do
	        drugname=$(grep -E -B4 " Resistance\"|Susceptible" ${i}  | grep -Ev "Drug|}" | grep -A2 $code | grep "fullName" | cut -f2 -d: | sed 's/"//g' | sed 's/,$//' |  sed 's/^ [ \t]*//; s/[ \t]*$//') # create drugname
	        resistancelevel=$(grep -E -B4 " Resistance\"|Susceptible" ${i}  | grep -Ev "Drug|}" | grep -A2 $code | grep "text" | cut -f2 -d: | sed 's/"//g' | sed 's/,$//' |  sed 's/^ [ \t]*//; s/[ \t]*$//') # create resistance level
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
	
	# close off the nrti drug section
	echo "            ]" >> ${output}/${id}.json
	echo "        }," >> ${output}/${id}.json
	
	
	
	## get those for nnrti
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Type\": \"NNRTI\"," >> ${output}/${id}.json
	echo -e "            \"DrugScores\": [" >> ${output}/${id}.json
	
	for code in `cat database.txt | grep -w NNRTI | cut -f1`
	do
	        drugname=$(grep -E -B4 " Resistance\"|Susceptible" ${i}  | grep -Ev "Drug|}" | grep -A2 $code | grep "fullName" | cut -f2 -d: | sed 's/"//g' | sed 's/,$//' |  sed 's/^ [ \t]*//; s/[ \t]*$//') # create drugname
	        resistancelevel=$(grep -E -B4 " Resistance\"|Susceptible" ${i}  | grep -Ev "Drug|}" | grep -A2 $code | grep "text" | cut -f2 -d: | sed 's/"//g' | sed 's/,$//' |  sed 's/^ [ \t]*//; s/[ \t]*$//') # create resistance level
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
	
	# close off the nrti drug section
	echo "            ]" >> ${output}/${id}.json
	echo "        }" >> ${output}/${id}.json
	
	echo "    ]," >> ${output}/${id}.json # close the drug section
	
	
	# get pi major comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Major\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > major_tmp.txt
	sed -i 's/^/                /' major_tmp.txt # add leading spaces
	sed -i 's/,$//' major_tmp.txt # substitute the last comma with nothing
	
	
	# get pi accessory comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Accessory\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > accessory_tmp.txt
	sed -i 's/^/                /' accessory_tmp.txt # add leading spaces
	sed -i 's/,$//' accessory_tmp.txt # substitute the last comma with nothing
	
	#### get the other comments for both PI and RT
	other_mcnt=$(grep -oc "\"commentType\": \"Other\".*" ${i}) # count the number of occurrences of the other comments
	if [ ${other_mcnt} -eq 2 ]
	then
		sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Other\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | awk 'BEGIN {FS="\"commentType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > pi_other_tmp.txt
		sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Other\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | awk 'BEGIN {FS="\"commentType\": \"Other\""} {print $3}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > rt_other_tmp.txt
	elif [ ${other_mcnt} -eq 1 ]
	then
		# check which class
		class=$(awk '/\"commentType\": \"Other\"/,/\"highlightText\"/' ${i} | grep "\"name\"" | cut -f2 -d":" | awk 'BEGIN { FS = "[0-9]" } {print $1}' | sed 's/"//g; s/,//; s/^ [ \t]*//' | sort -u)	
		if [ $class == PR ]
		then
			sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Other\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | awk 'BEGIN {FS="\"commentType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > pi_other_tmp.txt
			echo "" > rt_other_tmp.txt
		else
			echo "" > pi_other_tmp.txt
			sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"Other\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | awk 'BEGIN {FS="\"commentType\": \"Other\""} {print $2}' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//'  > rt_other_tmp.txt
		fi
	else
		echo "" > pi_other_tmp.txt
		echo "" > rt_other_tmp.txt
	fi
	
	sed -i 's/^/                /' pi_other_tmp.txt # add leading spaces
	sed -i 's/,$//' pi_other_tmp.txt # substitute the last comma with nothing
	
	sed -i 's/^/                /' rt_other_tmp.txt # add leading spaces
	sed -i 's/,$//' rt_other_tmp.txt # substitute the last comma with nothing
	
	## add the PI comments to the json
	
	echo -e "    \"ResultComments\": [" >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	echo -e "            \"Group\": \"Major\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat major_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the pi major comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	echo -e "            \"Group\": \"Accessory\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat accessory_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the pi accessory comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	echo -e "            \"Group\": \"PR Other\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat pi_other_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the pr other comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	# get rt nrti comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"NRTI\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > nrti_tmp.txt
	sed -i 's/^/                /' nrti_tmp.txt # add leading spaces
	sed -i 's/,$//' nrti_tmp.txt # substitute the last comma with nothing
	
	# get rt nnrti comments
	sed -z 's/\n/#/g' ${i} | grep -o "\"commentType\": \"NNRTI\".*" | perl -pe 's/"highlightText": \[#.*?#.*?\]//g' | cut -f1 -d"]" | sed -z 's/#/\n/g' | grep "\"text\":" | grep  -v "\"text\": \"[A-Z]\{1,2\}[0-9]\{1,3\}[A-Z]\{1,2\}\"," | cut -f2 -d":" | sort -u | sed 's/^ [ \t]*//; s/[ \t]*$//' > nnrti_tmp.txt
	sed -i 's/^/                /' nnrti_tmp.txt # add leading spaces
	sed -i 's/,$//' nnrti_tmp.txt # substitute the last comma with nothing
	
	## add the RT comments to the json
	
	echo -e "            \"Group\": \"NRTI\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat nrti_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the rt nrti comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	echo -e "            \"Group\": \"NNRTI\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat nnrti_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the rt nnrti comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }," >> ${output}/${id}.json
	echo -e "        {" >> ${output}/${id}.json
	
	echo -e "            \"Group\": \"RT Other\"," >> ${output}/${id}.json
	echo -e "            \"Comments\": [" >> ${output}/${id}.json
	echo -e "$(cat rt_other_tmp.txt | sed -z 's/\n/#/g; s/#$/\n/; s/#/,\n/g')" >> ${output}/${id}.json # add the pi accessory comments
	echo -e "            ]" >> ${output}/${id}.json
	echo -e "        }" >> ${output}/${id}.json
	
	
	echo -e "    ]" >> ${output}/${id}.json
	echo -e "}" >> ${output}/${id}.json
	
	
	## remove temporary files
	rm *tmp*
	echo -e "=============================Completed $i======================================================"
done

echo -e "\n\n\nResults are in: $output"
