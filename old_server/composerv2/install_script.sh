sudo apt-get update
sudo apt-get install docker-compose

#sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
#sudo apt-get update
#sudo apt-get install -y kubectl

#curl -L https://github.com/kubernetes-incubator/kompose/releases/download/v0.7.0/kompose-linux-amd64 -o kompose
#chmod +x kompose
#sudo mv ./kompose /usr/local/bin/kompose

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
#sudo sysctl -p /etc/sysctl.conf


cd $(dirname $0)
docker-compose build --no-cache
sleep 5

printf "updating resolv\n"
printf "domain OFA.itb
search OFA.itb
nameserver 10.10.6.1\n" | sudo tee /etc/resolv.conf

sleep 20

docker-compose up

