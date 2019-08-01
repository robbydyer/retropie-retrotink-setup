#!/bin/bash

set -e

if ps faux | grep emulationstation | grep -v grep; then
	killall emulationstation
fi

for system in arcade pcengine snes; do
	echo
	echo
	echo "-------------------------------------------------------------"
	echo "-------------------------------------------------------------"
	echo "Scrape ${system}"
	echo "-------------------------------------------------------------"
	echo "-------------------------------------------------------------"
	opts=
	if [ "${system}" = "arcade" ]; then
		opts="-mame"
	fi
	set -x
	sudo -u pi "/opt/retropie/supplementary/scraper/scraper" ${opts} \
		-image_dir /home/pi/.emulationstation/downloaded_images/${system} \
		-image_path ~/.emulationstation/downloaded_images/${system} \
		-video_dir /home/pi/.emulationstation/downloaded_images/${system} \
		-video_path ~/.emulationstation/downloaded_images/${system} \
		-marquee_dir /home/pi/.emulationstation/downloaded_images/${system} \
		-marquee_path ~/.emulationstation/downloaded_images/${system} \
		-output_file /home/pi/.emulationstation/gamelists/${system}/gamelist.xml \
		-rom_dir /home/pi/RetroPie/roms/${system} \
		-workers 4 \
		-skip_check \
		-download_videos \
		-download_marquees \
		-max_width 400 \
		-max_height 400 \
		-console_src=ss,ovgdb,gdb, \
		-use_nointro_name=false \
		-mame_src=ss,gdb,adb
	set +x
done

nohup emulationstation &
exit

echo "Scrape Arcade"
echo "-------------------------------------------------------------"
echo "-------------------------------------------------------------"
set -x
sudo -u pi "/opt/retropie/supplementary/scraper/scraper" \
	-image_dir /home/pi/.emulationstation/downloaded_images/arcade \
	-image_path ~/.emulationstation/downloaded_images/arcade \
	-video_dir /home/pi/.emulationstation/downloaded_images/arcade \
	-video_path ~/.emulationstation/downloaded_images/arcade \
	-marquee_dir /home/pi/.emulationstation/downloaded_images/arcade \
	-marquee_path ~/.emulationstation/downloaded_images/arcade \
	-output_file /home/pi/.emulationstation/gamelists/arcade/gamelist.xml \
	-rom_dir /home/pi/RetroPie/roms/arcade \
	-workers 4 \
	-skip_check \
	-mame \
	-download_videos \
	-download_marquees \
	-max_width 400 \
	-max_height 400 \
	-console_src=ss,ovgdb,gdb, \
	-use_nointro_name=false \
	-mame_src=mamedb,gdb,ss,adb
set +x

echo
echo
echo "Scrape PCEngine"
echo "-------------------------------------------------------------"
echo "-------------------------------------------------------------"
set -x
sudo -u pi "/opt/retropie/supplementary/scraper/scraper" \
	-image_dir /home/pi/.emulationstation/downloaded_images/pcengine \
	-image_path ~/.emulationstation/downloaded_images/pcengine \
	-video_dir /home/pi/.emulationstation/downloaded_images/pcengine \
	-video_path ~/.emulationstation/downloaded_images/pcengine \
	-marquee_dir /home/pi/.emulationstation/downloaded_images/pcengine \
	-marquee_path ~/.emulationstation/downloaded_images/pcengine \
	-output_file /home/pi/.emulationstation/gamelists/pcengine/gamelist.xml \
	-rom_dir /home/pi/RetroPie/roms/pcengine \
	-workers 4 \
	-skip_check \
	-download_videos \
	-download_marquees \
	-max_width 400 \
	-max_height 400 \
	-console_src=ss,ovgdb,gdb, \
	-use_nointro_name=false \
	-mame_src=mamedb,gdb,ss,adb
set +x

echo
echo
echo "Scrape SNES"
echo "-------------------------------------------------------------"
echo "-------------------------------------------------------------"
set -x
sudo -u pi "/opt/retropie/supplementary/scraper/scraper" \
	-image_dir /home/pi/.emulationstation/downloaded_images/snes \
	-image_path ~/.emulationstation/downloaded_images/snes \
	-video_dir /home/pi/.emulationstation/downloaded_images/snes \
	-video_path ~/.emulationstation/downloaded_images/snes \
	-marquee_dir /home/pi/.emulationstation/downloaded_images/snes \
	-marquee_path ~/.emulationstation/downloaded_images/snes \
	-output_file /home/pi/.emulationstation/gamelists/snes/gamelist.xml \
	-rom_dir /home/pi/RetroPie/roms/snes \
	-workers 4 \
	-skip_check \
	-download_videos \
	-download_marquees \
	-max_width 400 \
	-max_height 400 \
	-console_src=ss,ovgdb,gdb, \
	-use_nointro_name=false \
	-mame_src=mamedb,gdb,ss,adb
set +x

emulationstation &
