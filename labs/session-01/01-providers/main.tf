# Two providers and no cloud at all: a random name, written to a local file.

resource "random_pet" "server" {
  length    = 2
  separator = "-"
}

resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.txt"
  content  = "server name: ${random_pet.server.id}\n"
}

output "server_name" {
  value = random_pet.server.id
}
