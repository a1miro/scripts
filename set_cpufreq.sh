#! /bin/bash

governor="$1"
governors=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
print_usage() {
   echo "Usage: $(basename ${0}) <<governor>>"
   echo "Available governors:"
   echo "${governors[@]}"
}

if [ -z ${governor} ]; then
    print_usage
    exit 1
fi

echo "Choosen governor: ${governor}"

np=$(nproc)
echo "Number of processors: ${np}"

for p in $(seq 0 $((np - 1)))
do 
  echo -ne "Setting scaling governor ${governor}  for processor ${p} \r"
  echo "$governor" > /sys/devices/system/cpu/cpu${p}/cpufreq/scaling_governor
  sleep 0.005
done
echo -ne "Done!                                                       \r"
echo ""
