variable "project_shortname" { type = "string" }
variable "github_repo_ref" {
    type = "string"
    description = "The git repo reference to clone onto the airflow server"
    default = null
}
