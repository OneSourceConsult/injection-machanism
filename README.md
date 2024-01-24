# Injection Mechanism
Mechanism to inject sidecar containers into Kubernetes PODs

## Information
This repository contains all the files required to perform the injection of the sidecar container into an already-existent Kubernetes POD by patching the pre-existent deployment with the new container. 
<br>
To use this system, you have to create the docker image using the existent Dockerfile and host it in a public or private container registry. Afterwards, replace the string _<path-to-container-registry>_ in the _helm/templates/job.yaml_ file with the proper container image path. In addition, set the value of INJECTIONS_LIST in the helm/values.yaml with the list of deployment names next to which the sidecar will be deployed. 
<br> 
Observation: Any container may be placed as a sidecar. Choose at your convenience and adapt the content of _scripts/injectionMechanism.sh_ script before creating the container image.
