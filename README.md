# AMLD-Africa-2026

#### Description on what this repository containes

# 💻⚙️ Getting Started with GEOStudio(local deployment)

*If you want detailed description 📚 of the local deployment process [see here 📚](https://github.com/terrastackai/geospatial-studio/).*

Whilst not providing full performance and functionality, the studio can be deployed locally for testing and development purposes.  The instructions below will deploy the main components of the Geospatial Studio in a Kubernetes cluster on the local machine (i.e. your laptop).  This is provisioned through a Lima Virtual Machine.  

The automated shell script install the prerequisites, deploy the local dependencies (Minio, Keycloak and Postgresql), before generating the deployment configuration for the studio and then deploying the main studio services + pipelines.

To deploy locally:
```sh
git clone git@github.com:Beldine-Moturi/AMLD-Africa-2026.git
cd Deploy_locally
./deploy_mac.sh
# OR if you have a linux machine:
./deploy_linux.sh
```

*Deployment can take ~10 minutes (or longer) depending available download speed for container images.*

You can monitor the progress and debug using [`k9s`](https://k9scli.io) or similar tools.

# Getting started with GEOStudio(First steps)
Check out and download [this notebook](./Deploy_locally/GeospatialStudio-First-Steps.ipynb) for guidance on how to get started with your first inference run!


# GEOStudio tools and Assets shared during the presentation


### GEOStudio: <img src="images/image.png" alt="alt text" width="24" height="24">
Github: https://github.com/terrastackai/geospatial-studio

Documentation: https://terrastackai.github.io/geospatial-studio/

### Prithvi Models Family: <img src="images/image-2.png" alt="alt text" width="24" height="24"> 
https://huggingface.co/ibm-nasa-geospatial

### TerraMind model: <img src="images/image-2.png" alt="alt text" width="24" height="24">
https://huggingface.co/ibm-esa-geospatial 

### Terrakit: <img src="images/image-3.png" alt="alt text" width="24" height="24">
Github: https://github.com/terrastackai/terrakit

Documentation: https://terrastackai.github.io/terrakit/

### Terratorch <img src="images/image-1.png" alt="alt text" width="24" height="24">
Github: https://github.com/terrastackai/terratorch

Documentation: https://terrastackai.github.io/terratorch/stable/



