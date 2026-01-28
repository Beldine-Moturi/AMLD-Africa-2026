# Using the Geospatial Exploration and Orchestration Studio (GEOStudio) for disaster mapping | AMLD Africa 2026 workshop

This Repository contains:

1. Simplified instructions for deploying the GEOStudio locally in a MacOS and linux environment.

2. A guide on how to make your first steps after deploying the studio i.e testing with an inference run.

3. Complete flooding and wildfire example use-cases demonstrating the full workflow: from dataset onboarding, through fine-tuning to inferencing through the GEOStudio.

4. Links to the GEOStudio Documentation and Github repos which contains more examples, detailed instructions about local and cluster depployment and more!

5. Links to all the tools and assets mentioned or shared during the workshop presentation.



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



