#!/bin/bash
# Changement local
echo "###############################"
echo "Installation des prerequis Docker"
sudo yum install yum-utils device-mapper-persistent-data lvm2 -y 

echo "###############################"
echo "Configuration du repository Docker"
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 

echo "###############################"
echo "Test si OS==Rocky"
if [ -f /etc/os-release ] && grep -q 'Rocky Linux' /etc/os-release; then
    sudo dnf remove -y podman containers-common.x86_64
else
    echo "Ce système d'exploitation n'est pas Rocky Linux."
fi


echo "###############################"
echo "Installation Docker runtime"
sudo yum install docker-ce -y

echo "###############################"
echo "Personalisation cgroupdriver=systemd"
sudo mkdir /etc/docker
# Set up the Docker daemon
sudo cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
  
}
EOF

echo "###############################"
echo "Start & Enable Docker"
sudo systemctl start docker
sudo systemctl enable docker

echo "###############################"
echo"Installation Repo + yum install K8s"
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
