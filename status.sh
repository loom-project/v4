# ! /bin/bash
TCP_destination=$(awk 'FNR == 1 {print}' TCP_directory.txt) 
UDP_destination=$(awk 'FNR == 1 {print}' UDP_directory.txt)
TCP_folders=$(find $TCP_destination -maxdepth 1 -type d -print | wc -l)
UDP_folders=$(find $UDP_destination -maxdepth 1 -type d -print | wc -l) 

echo start_TCP_process

for (( x = 1 ; x < $TCP_folders ; x++ ))
  do 
    for a in $TCP_destination/$x/*.pcap 
      do
        z=$((z + 1))
        difference=$(echo $(tshark -r $TCP_destination/$x/$z.pcap  -T fields -e frame.time_epoch | tail -n 1) - $(tshark -r $TCP_destination/$x/$z.pcap  -T fields -e frame.time_epoch | head -n 1) | bc)
        Source_Port=$(awk -F"[, ]" 'FNR == "'$z'" {print $1}' $TCP_destination/$x.txt)
Destination_Port=$(awk -F"[, ]" 'FNR == "'$z'" {print $2}' $TCP_destination/$x.txt)
#        echo $(tshark -r $TCP_destination/$x/$z.pcap -c 1 -t ad | awk -F" " '{print $2,$3}'),$difference,$(awk -v OFS=',' 'FNR == "'$z'" {print $1,$2}' $TCP_destination/$x.txt),$Source_Port, $Destination_Port>> $TCP_destination/status_$x.txt
         sqlite3 tcp/$x/
     done 
     z=0
#rm $TCP_destination/$x.txt
done
#rm TCP_directory.txt
z=0

echo finished_TCP_process

echo start_UDP_process

for (( x = 1 ; x < $UDP_folders ; x++ ))
  do 
    for a in $UDP_destination/$x/*.pcap 
      do
        z=$((z + 1))
        difference=$(echo $(tshark -r $UDP_destination/$x/$z.pcap  -T fields -e frame.time_epoch | tail -n 1) - $(tshark -r $UDP_destination/$x/$z.pcap  -T fields -e frame.time_epoch | head -n 1) | bc)
        Source_Port=$(awk -F"[, ]" 'FNR == "'$z'" {print $1}' $UDP_destination/$x.txt)
        Destination_Port=$(awk -F"[, ]" 'FNR == "'$z'" {print $2}' $UDP_destination/$x.txt)
        echo $(tshark -r $UDP_destination/$x/$z.pcap -c 1 -t ad | awk -F" " '{print $2,$3}'),$difference,$(awk -v OFS=',' 'FNR == "'$z'" {print $1,$2}' $UDP_destination/$x.txt),$Source_Port, $Destination_Port>> $UDP_destination/status_$x.txt
    done 
    z=0
#rm $UDP_destination/$x.txt
done
#rm UDP_directory.txt
echo finished_UDP_process
