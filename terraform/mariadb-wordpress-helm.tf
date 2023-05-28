resource "helm_release" "mariadb-wordpress" {
  name       = "chart-for-l-addition"
  chart      = "../mariadb-wordpress-helm/"

  values = [
    "${file("../mariadb-wordpress-helm/values.yaml")}"
  ]
}

