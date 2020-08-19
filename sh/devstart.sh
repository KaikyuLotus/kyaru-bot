export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/lib/dart/bin

pub get
dart2native main.dart -o kyaru-dev

pkill -f ./kyaru-dev
nohup ./kyaru-dev > log.txt &