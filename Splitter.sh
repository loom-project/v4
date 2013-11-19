# ! /bin/bash
read -p "enter source pcap(s) directory (e.g /home/Desktop/source) :" Source
read -p "enter TCP pcap(s) destination directory (e.g /home/Desktop/tcp_destination) :" TCP_destination
read -p "enter UDP pcap(s) destination directory (e.g /home/Desktop/udp_destination):" UDP_destination

echo $TCP_destination > TCP_directory.txt
echo $UDP_destination > UDP_directory.txt
echo Start Processing TCP Connections
mkdir $TCP_destination/TCP_temp/ #to get IP's and ports
for a in $Source/*.pcap #Include all pcap files # <<<<<<<< please insert the source pcap file(s) path here

do

TCP_folders=$((TCP_folders + 1))

tshark -r $a -w $TCP_destination/TCP_temp/temp.pcap -R tcp 
tshark -r $TCP_destination/TCP_temp/temp.pcap -w $TCP_destination/TCP_temp/$TCP_folders.pcap -R !icmp
tshark -r $TCP_destination/TCP_temp/$TCP_folders.pcap -T fields -e tcp.port -e ip.addr | awk '!a[$0]++' > $TCP_destination/TCP_temp/$TCP_folders.txt
python parse.py $TCP_destination/TCP_temp/$TCP_folders.txt > results.txt
cat results.txt | column -t > $TCP_destination/$TCP_folders.txt 
rm $TCP_destination/TCP_temp/temp.pcap

mkdir $TCP_destination/$TCP_folders/


for TCP in `tshark -r $a -T fields -e tcp.stream | sort -n | uniq` 

do

conn=$((conn + 1))


tshark -r $a -w $TCP_destination/$TCP_folders/$conn.pcap -R "tcp.stream==$TCP"
done

conn=0

done

rm -r $TCP_destination/TCP_temp/
rm results.txt
echo Finished Processing TCP Connections


echo Start Processing UDP connecions
conn=0

mkdir $UDP_destination/UDP_temp/

for a in $Source/*.pcap #prepare UDP big chunk file from the source file
do

conn=$((conn + 1))
tshark -r $a -w $UDP_destination/UDP_temp/temp.pcap -R udp 
tshark -r $UDP_destination/UDP_temp/temp.pcap -w $UDP_destination/UDP_temp/$conn.pcap -R !icmp
tshark -r $UDP_destination/UDP_temp/$conn.pcap -T fields -e udp.port -e ip.addr | awk '!a[$0]++' > $UDP_destination/UDP_temp/$conn.txt
python parse.py $UDP_destination/UDP_temp/$conn.txt > results.txt #remove repetition
cat results.txt > $UDP_destination/UDP_temp/$conn.txt
cat results.txt | column -t > $UDP_destination/$conn.txt 
#awk -F'[, | 	]' '{print $3,$4}' $UDP_destination/UDP_temp/$conn.txt | column -t  > $UDP_destination/$conn.txt 
rm results.txt
rm $UDP_destination/UDP_temp/temp.pcap


done

conn=0

for b in $UDP_destination/UDP_temp/*.txt # prepare udp files from udp big chunk  
do
conn=$((conn + 1))
Number_of_Lines=$(wc -l $UDP_destination/UDP_temp/$conn.txt | awk '{ print $1 }')

mkdir $UDP_destination/$conn/

for (( x = 1 ; x <= $Number_of_Lines ; x++ ))
do


port_1=$(awk -F'[, | / | :	]' 'NR=="'$x'"{print $1}' $b)
port_2=$(awk -F'[, | / | :	]' 'NR=="'$x'"{print $2}' $b)
IP_1=$(awk -F'[, | / | :	]' 'NR=="'$x'"{print $3}' $b)
IP_2=$(awk -F'[, | / | :	]' 'NR=="'$x'"{print $4}' $b)


tshark -r $UDP_destination/UDP_temp/$conn.pcap -w $UDP_destination/$conn/$x.pcap -R "(ip.addr eq $IP_1 and ip.addr eq $IP_2) and (udp.port eq $port_1 and udp.port eq $port_2)"

done 

done
rm -r $UDP_destination/UDP_temp/


echo Finished Processing UDP connecions


