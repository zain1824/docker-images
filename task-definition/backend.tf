terraform {
  backend "s3" {
    bucket = "zain1824-docker-class"
    key    = "path/to/my/ecs"
    region = "us-east-2"
  }
}

