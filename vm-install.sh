#! /bin/bash

#sudo apt-get update -y
#sudo apt install python3-pip -y
sudo apt-get install unzip -y

# copy models to saved_model
gsutil cp gs://artifacts.micamedic.appspot.com/saved_model_10_8.zip .
unzip ./saved_model_10_8.zip -d /micamedic/saved_model

# cloning had to be already done from CloudBuild before that

ls -al /micamedic
ls -al /micamedic/project
ls -al /micamedic/saved_model
# ls -al /micamedic/python-mydemo
