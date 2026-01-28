#!/bin/bash

set -e


## Install prerequisites

echo "======================================"
echo "Installing Prerequisites for macOS"
echo "======================================"
echo ""

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed."
    echo "Please install Homebrew from https://brew.sh/"
    exit 1
fi

echo "Updating Homebrew..."
brew update

# Install Lima VM (v1.2.1 - incompatible with v2)
echo ""
echo "Installing Lima VM..."
if brew list lima &> /dev/null; then
    echo "Lima is already installed. Checking version..."
    LIMA_VERSION=$(lima --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    echo "Current version: $LIMA_VERSION"
else
    brew install lima
fi

# Install Helm (v3.19 - incompatible with v4)
echo ""
echo "Installing Helm..."
if brew list helm &> /dev/null; then
    echo "Helm is already installed. Checking version..."
    HELM_VERSION=$(helm version --short | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
    echo "Current version: $HELM_VERSION"
    if [[ "$HELM_VERSION" == v4* ]]; then
        echo "WARNING: Helm v4 detected. This is incompatible. Please downgrade to v3.19."
    fi
else
    brew install helm
fi

# Install OpenShift CLI (kubectl included)
echo ""
echo "Installing OpenShift CLI..."
if brew list openshift-cli &> /dev/null; then
    echo "OpenShift CLI is already installed."
else
    brew install openshift-cli
fi

# Install jq (JSON processor)
echo ""
echo "Installing jq..."
if brew list jq &> /dev/null; then
    echo "jq is already installed."
else
    brew install jq
fi

# Install yq (YAML processor)
echo ""
echo "Installing yq..."
if brew list yq &> /dev/null; then
    echo "yq is already installed."
else
    brew install yq
fi

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
limactl start --name=studio deployment-scripts/lima/studio.yaml

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

