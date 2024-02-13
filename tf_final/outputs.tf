output "password" {
  value = [for s in random_password.password[*].result : nonsensitive(s)]
}
