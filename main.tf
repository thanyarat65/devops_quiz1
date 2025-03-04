terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

resource "null_resource" "build_docker_image" {
  provisioner "local-exec" {
    command     = "docker build -t node -f Dockerfile ."
    working_dir = path.module
  }
}

resource "docker_image" "my_app" {
  name       = "node"
  depends_on = [null_resource.build_docker_image] # รอให้ build เสร็จก่อน
}

resource "docker_container" "my_container" {
  name  = "my-express-app"
  image = docker_image.my_app.name
  ports {
    internal = 3000
    external = 3000
  }
}
