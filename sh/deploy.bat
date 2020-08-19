ssh kaikyu@kai.kaikyu.monster "bash -c 'pkill -f ./kyaru-dev && rm -rf /home/kaikyu/kyaru && mkdir /home/kaikyu/kyaru'"
scp -r database lib pubspec.yaml main.dart sh/prodstart.sh sh/devstart.sh sh/promote.sh kaikyu@kai.kaikyu.monster:/home/kaikyu/kyaru
ssh kaikyu@kai.kaikyu.monster "bash -c 'cd /home/kaikyu/kyaru && pwd && sh devstart.sh'"