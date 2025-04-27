#!/bin/bash
# master and work nodes public address
master1=10.10.1.145
master2=10.10.1.155
worker1=10.10.1.121
worker2=10.10.1.122

# K3S Version
k3sVersion="v1.32.3+k3s1"

# User of remote machines
user=ubuntu

# Array of master nodes
masters=($master2)

# Array of worker nodes
workers=($worker1 $worker2)

# Array of all
all=($master1 $master2 $worker1 $worker2)

# Array of all minus master
allnomaster1=($master2 $worker1 $worker2)

# For testing purposes - in case time is wrong due to VM snapshots
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on



# Install k3sup to local machine if not already present
if ! command -v k3sup version &> /dev/null
then
    echo -e " \033[31;5mk3sup not found, installing\033[0m"
    curl -sLS https://get.k3sup.dev | sh
    sudo install k3sup /usr/local/bin/
else
    echo -e " \033[32;5mk3sup already installed\033[0m"
fi

# Install Kubectl if not already present
if ! command -v kubectl version &> /dev/null
then
    echo -e " \033[31;5mKubectl not found, installing\033[0m"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
    echo -e " \033[32;5mKubectl already installed\033[0m"
fi

# Check for SSH config file, create if needed, add/change Strict Host Key Checking (don't use in production!)

if [ ! -f "$config_file" ]; then
  # Create the file and add the line
  echo "StrictHostKeyChecking no" > "$config_file"
  # Set permissions to read and write only for the owner
  chmod 600 "$config_file"
  echo "File created and line added."
else
  # Check if the line exists
  if grep -q "^StrictHostKeyChecking" "$config_file"; then
    # Check if the value is not "no"
    if ! grep -q "^StrictHostKeyChecking no" "$config_file"; then
      # Replace the existing line
      sed -i 's/^StrictHostKeyChecking.*/StrictHostKeyChecking no/' "$config_file"
      echo "Line updated."
    else
      echo "Line already set to 'no'."
    fi
  else
    # Add the line to the end of the file
    echo "StrictHostKeyChecking no" >> "$config_file"
    echo "Line added."
  fi
fi

# Install policycoreutils for each node
for newnode in "${all[@]}"; do
  ssh $user@$newnode sudo su <<EOF
  NEEDRESTART_MODE=a apt update && apt upgrade -y
  apt-get install policycoreutils -y
  exit
EOF
  echo -e " \033[32;5mPolicyCoreUtils installed!\033[0m"
done

# Step 1: Bootstrap First k3s Node
mkdir ~/.kube
k3sup install \
  --ip $master1 \
  --user $user \
  --cluster \
  --k3s-version $k3sVersion \
  --k3s-extra-args "--node-ip=$master1 --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
  --merge \
  --sudo \
  --local-path $HOME/.kube/config \
  --context k3s-ha
echo -e " \033[32;5mFirst Node bootstrapped successfully!\033[0m"

# Step 2: Add new master nodes (servers) & workers
for newnode in "${masters[@]}"; do
  k3sup join \
    --ip $newnode \
    --user $user \
    --sudo \
    --k3s-version $k3sVersion \
    --server \
    --server-ip $master1 \
    --k3s-extra-args "--node-ip=$newnode --node-taint node-role.kubernetes.io/master=true:NoSchedule" \
    --server-user $user
  echo -e " \033[32;5mMaster node joined successfully!\033[0m"
done

# add workers
for newagent in "${workers[@]}"; do
  k3sup join \
    --ip $newagent \
    --user $user \
    --sudo \
    --k3s-version $k3sVersion \
    --server-ip $master1 \
    --k3s-extra-args "--server-ip $master1 --node-ip=$newagent --node-label \"worker=true\""
  echo -e " \033[32;5mAgent node joined successfully!\033[0m"
done

kubectl get nodes
kubectl get svc
kubectl get pods --all-namespaces -o wide

echo -e " \033[32;5mHappy learing! \033[0m"