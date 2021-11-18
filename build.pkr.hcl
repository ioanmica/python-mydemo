variables {
  project_id = "micamedic"
  zone = "us-central1-a"
  builder_sa = ""  
}

source "googlecompute" "processor" {
  project_id                  = var.project_id
  zone                        = var.zone
  source_image_family         = "ubuntu-2004-lts"
  image_name                  = "processor-{{timestamp}}"
  image_description           = "Created with Packer from Cloudbuild"
  ssh_username                = "root"
  tags                        = ["packer"]
  impersonate_service_account = var.builder_sa
}

build {
  sources = ["sources.googlecompute.processor"]

  # debug purpose
  provisioner "shell-local" {
    inline = [
      # this is in /workspace, here we have the git repo folder 
      # and the entire build project files
      "ls -al", 
      "pwd",      
      "ls -al /"
    ]
  }
  # copy project cloned in Cloud Build machine to new VM
  provisioner "file" {
    # source is in /workspace
    source = "/workspace"
    destination = "/tmp"    
  }

  # move project to /micamedic
  provisioner "shell" {
    inline = [      
      "mkdir /micamedic",
      "mv /tmp /micamedic/"
    ]
  }
  provisioner "shell" {
    # here we are in /root
    script = "vm-install.sh"    
  }
}
