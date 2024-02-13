terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.8.0"
    }
  }
}


provider "gitlab" {
 token = "${var.access_token}"
 base_url = "https://gitlab.rebrainme.com"
}


data "gitlab_group" "gitlab_id" {
  full_path = "devops_users_repos/3031"
}


resource "gitlab_project" "repo_task1" {
  name         = "task1"
  description  = "task1"
  namespace_id = data.gitlab_group.gitlab_id.id
}


data "gitlab_project" "repo_task1" {
  id = 39373
}


resource "gitlab_deploy_key" "deploy_key" {
  project = data.gitlab_project.repo_task1.id
  title   = "deploy_key"
  key     = "${var.deploy_key}"
}
