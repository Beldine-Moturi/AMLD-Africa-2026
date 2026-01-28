#!/bin/bash

set -e

echo "======================================"
echo "Installing Prerequisites for Linux"
echo "======================================"
echo ""

if [[ $EUID -ne 0 ]]; then
   echo "This script should be run with sudo privileges for some operations."
   echo "Some commands will use sudo explicitly."
fi

echo "Updating package lists..."
sudo apt-get update

# Install QEMU system
echo ""
echo "Installing QEMU system..."
sudo apt-get install -y qemu-system

# Install Lima VM (v1.2.1 - incompatible with v2)
echo ""
echo "Installing Lima VM..."
VERSION="v1.2.1"
echo "Installing Lima version: $VERSION"
curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | sudo tar Cxzvm /usr/local
curl -fsSL "https://github.com/lima-vm/lima/releases/download/${VERSION}/lima-additional-guestagents-${VERSION:1}-$(uname -s)-$(uname -m).tar.gz" | sudo tar Cxzvm /usr/local

# Install Helm (v3.19 - incompatible with v4)
echo ""
echo "Installing Helm..."
sudo apt-get install -y curl gpg apt-transport-https
curl -fsSL https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# Install OpenShift CLI (includes kubectl)
echo ""
echo "Installing OpenShift CLI..."
OC_VERSION="latest"
PLATFORM="linux"
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    OC_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    OC_ARCH="arm64"
else
    OC_ARCH="$ARCH"
fi

echo "Downloading OpenShift CLI for $PLATFORM-$OC_ARCH..."
OC_URL="https://mirror.openshift.com/pub/openshift-v4/$OC_ARCH/clients/ocp/stable/openshift-client-$PLATFORM.tar.gz"
curl -fsSL "$OC_URL" -o /tmp/openshift-client.tar.gz
sudo tar -xzf /tmp/openshift-client.tar.gz -C /usr/local/bin oc kubectl
sudo chmod +x /usr/local/bin/oc /usr/local/bin/kubectl
rm /tmp/openshift-client.tar.gz

# Install jq (JSON processor)
echo ""
echo "Installing jq..."
sudo apt-get install -y jq

# Install yq (YAML processor)
echo ""
echo "Installing yq..."
YQ_VERSION="v4.44.1"
PLATFORM="linux"
ARCH=$(uname -m)

# Map architecture for yq
if [ "$ARCH" = "x86_64" ]; then
    YQ_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    YQ_ARCH="arm64"
else
    YQ_ARCH="$ARCH"
fi

YQ_BINARY="yq_${PLATFORM}_${YQ_ARCH}"
echo "Downloading yq $YQ_VERSION for $PLATFORM-$YQ_ARCH..."
sudo wget -q "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""



## Deploy
git clone git@github.com:terrastackai/geospatial-studio.git
cd geospatial-studio/

python3 -m venv venv/
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "Starting Lima VM..."
limactl start --name=studio deployment-scripts/lima/studio-linux.yaml

echo ""
echo "Waiting for Lima VM to be ready..."
sleep 5

echo ""
echo "Setting KUBECONFIG..."
export KUBECONFIG=$HOME/.lima/studio/copied-from-guest/kubeconfig.yaml

if [ ! -f "$KUBECONFIG" ]; then
    echo "Warning: KUBECONFIG file not found at $KUBECONFIG"
    echo "Lima VM may still be initializing. Please wait and try running:"
    echo "  export KUBECONFIG=$HOME/.lima/studio/copied-from-guest/kubeconfig.yaml"
    echo "  ./deploy_studio_local.sh"
    exit 1
fi

echo "KUBECONFIG set to: $KUBECONFIG"

echo ""
echo "Deploying studio locally..."
./deploy_studio_local.sh

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""
echo "To use kubectl/helm in new terminal sessions, run:"
echo "  export KUBECONFIG=$HOME/.lima/studio/copied-from-guest/kubeconfig.yaml"
echo ""


# Update your etc hosts with the local urls

# Add our internal cluster urls to etc hosts for seamless connectivity since some of the services may call these internal urls on host machine

sudo echo -e "\n#lima\n127.0.0.1 keycloak.default.svc.cluster.local postgresql.default.svc.cluster.local minio.default.svc.cluster.local geofm-ui.default.svc.cluster.local geofm-gateway.default.svc.cluster.local" >> /etc/hosts


# port forward
kubectl port-forward -n default svc/keycloak 8080:8080 >> studio-pf.log 2>&1 &
kubectl port-forward -n default svc/postgresql 54320:5432 >> studio-pf.log 2>&1 &
kubectl port-forward -n default svc/geofm-geoserver 3000:3000 >> studio-pf.log 2>&1 &
kubectl port-forward -n default deployment/geofm-ui 4180:4180 >> studio-pf.log 2>&1 &
kubectl port-forward -n default deployment/geofm-gateway 4181:4180 >> studio-pf.log 2>&1 &
kubectl port-forward -n default deployment/geofm-mlflow 5000:5000 >> studio-pf.log 2>&1 &
kubectl port-forward -n default svc/minio 9001:9001 >> studio-pf.log 2>&1 &
kubectl port-forward -n default svc/minio 9000:9000 >> studio-pf.log 2>&1 &
