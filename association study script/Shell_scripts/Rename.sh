#!/bin/bash

# This shell script has been written by ak2272 in order to implement a nicer nomenclature to the raw and processed CT- data on the rds disk space.

echo "Please provide the name of the directory you want all the subdirectories to be renamed."
read direc
path=~/rds/rds-durbin-group-8b3VcZwY7rY/projects/cichlid/CT-data/$direc
cd $path
echo "This is current directory: $PWD"

# Takes directory entries specified and renames them using the pattern provided.

for directory in *
do
    if [ -d "$directory" ]
    then
    # Extracting the ID
    Name_bit=${directory%% *}
    first2=${Name_bit:0:2}
    first3=${Name_bit:0:3}
    Ban1="F2"
    Ban2="Aul"
      if [ "$first2" != "$Ban1" ] && [ "$first3" != "$Ban2" ]; then
          #Extracting the date
          Date_bit=$(echo $directory| cut -d'[' -f 2)
          Date_bit=${Date_bit% *}
          #echo "The date is $Date_bit"

          # Extract the year
          year=$(echo ${Date_bit%%-*})
          year=${year:2:2}
          #echo "The year is $year"

          # Extract the day
          day=${Date_bit##*-}
          #echo "Day is $day"

          # Extracting the month
          month=${Date_bit#*-}
          month=${month%-*}
          #echo "The month is $month"

          # Reconstructing the new name
          Name=$(echo "${Name_bit}_$year$month$day")
          echo "$Name"
      else
          echo "The directory $directory can not be renamed"
      fi
      #statements
      # Renaming
     # mv "${directory}" "${Name}" || echo 'Could not rename '"$directory"''
    fi
done
