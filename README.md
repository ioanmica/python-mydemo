# Create VMs with Packer in Google Cloud - Cloud Run

Here is the reference project.
https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/packer

Here is how to configure github secrets and Secret manager in order to be accessed by CloudBuild.
https://cloud.google.com/build/docs/access-github-from-build

## Create a Packer Builder as a docker image 

* Use existing Dockerfile
* Run docker build providing the right args:
  * packer version, SHA and GC project

``` bash
PACKER_VERSION=1.7.8
PACKER_VERSION_SHA256SUM=8a94b84542d21b8785847f4cccc8a6da4c7be5e16d4b1a2d0a5f7ec5532faec0
PROJECT_ID=micamedic

docker build \
--build-arg PACKER_VERSION=$PACKER_VERSION \
--build-arg PACKER_VERSION_SHA256SUM=$PACKER_VERSION_SHA256SUM \
-t gcr.io/$PROJECT_ID/packer-builder:$PACKER_VERSION .
```

* push the image to gcr.io

```bash
docker push gcr.io/$PROJECT_ID/packer-builder:$PACKER_VERSION
```


## Permissions required

The secret is configured as specified here:
https://cloud.google.com/build/docs/access-github-from-build

* generate ssh keys
* put private key in Secret Manager
* add the public key into Github Settings -> Deploy Keys

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --role="roles/compute.instanceAdmin.v1" \
  --member="serviceAccount:packer@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --role="roles/iam.serviceAccountUser" \
  --member="serviceAccount:packer@${PROJECT_ID}.iam.gserviceaccount.com"

# Allow CloudBuild to impersonate Packer service account
gcloud iam service-accounts add-iam-policy-binding \
  packer@${PROJECT_ID}.iam.gserviceaccount.com \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# permissions required to access secret manager secret
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --role="roles/secretmanager.secretAccessor" \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
```


## Invoke the packer builder in Cloud Run


```bash
# submit cloudbuild.yaml build request and specify './' current folder as source code. 
gcloud builds submit --config=cloudbuild.yaml .
```

When you run gcloud builds submit for the first time in a Cloud project, Cloud Build creates a Cloud Storage bucket named [YOUR_PROJECT_NAME]_cloudbuild in that project. Cloud Build uses this bucket to store any source code that you might use for your builds. Cloud Build does not automatically delete contents in this bucket. To delete objects you're no longer using for builds, you can either set up lifecycle configuration on the bucket or manually delete the objects.

If you **do not have source code to pass in to your build**, use the --no-source flag where build-config is the path to the build config file:

```bash
# submit a build without a source code
gcloud builds submit --config=cloudbuild.yaml --no-source
```

## Trigger the build from Github account

We have to configure a trigger in Cloud Build Triggers. This will start the building process.
https://cloud.google.com/build/docs/automating-builds/build-repos-from-github


### Integration of CloudBuild to Github project

* install CloudBuild app into Github account (https://cloud.google.com/build/docs/automating-builds/build-repos-from-github#installing_gcb_app)
This is done by creating a connection from CloudBuild -> Triggers -> Connect Repository
Connect to your specific github repo, not all repos.

A CloudBuild App will be installed in your github account project, under Settings -> Integrations 

### Create the CloudBuild Trigger
https://cloud.google.com/build/docs/automating-builds/build-repos-from-github#creating_github_triggers



