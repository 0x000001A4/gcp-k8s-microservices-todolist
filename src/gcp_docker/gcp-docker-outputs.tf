output "docker_images" {
    value = {for name, image in docker_image.todoapp:
        name => image
    }
    sensitive = false
}