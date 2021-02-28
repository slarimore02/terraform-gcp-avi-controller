resource "google_service_account_iam_binding" "avi_network_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.network[0].id

  members = []
}
resource "google_service_account_iam_binding" "avi_se_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.serviceengine[0].id

  members = []
}
resource "google_service_account_iam_binding" "avi_autoscaling_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.autoscaling_se[0].id

  members = []
}
resource "google_service_account_iam_binding" "avi_ilb_byoip_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.ilb_byoip[0].id

  members = []
}
resource "google_service_account_iam_binding" "avi_storage_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.storage[0].id

  members = []
}
resource "google_service_account_iam_binding" "avi_server_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.server[0].id

  members = []
}
resource "google_service_account_iam_binding" "avi_cluster_vip_role_binding" {
  count              = var.create_iam ? 1 : 0
  service_account_id = data.google_service_account.avi.name
  role               = google_project_iam_custom_role.cluster_vip[0].id

  members = []
}
resource "google_project_iam_custom_role" "network" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_Network_Role"
  project     = var.network_project != "" ? var.network_project : var.project
  stage       = "ALPHA"
  title       = "AVI Network Project Role"
  description = "Access to resources required for operations in Network Project"
  permissions = [
    "compute.networks.get",
    "compute.networks.list",
    "compute.networks.updatePolicy",
    "compute.regions.get",
    "compute.routes.create",
    "compute.routes.delete",
    "compute.routes.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.subnetworks.use"
  ]
}
resource "google_project_iam_custom_role" "serviceengine" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_ServiceEngine_Role"
  project     = var.service_engine_project != "" ? var.service_engine_project : var.project
  stage       = "ALPHA"
  title       = "AVI Service Engine Project Role"
  description = "Access to resources required for operations on Service Engines and Virtual Services"
  permissions = [
    "compute.addresses.create",
    "compute.addresses.delete",
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.addresses.use",
    "compute.disks.create",
    "compute.forwardingRules.get",
    "compute.forwardingRules.create",
    "compute.forwardingRules.delete",
    "compute.forwardingRules.list",
    "compute.globalOperations.get",
    "compute.images.create",
    "compute.images.delete",
    "compute.images.get",
    "compute.images.list",
    "compute.images.setLabels",
    "compute.images.useReadOnly",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.setLabels",
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instances.use",
    "compute.machineTypes.get",
    "compute.regionOperations.get",
    "compute.regions.get",
    "compute.regions.list",
    "compute.targetPools.addInstance",
    "compute.targetPools.create",
    "compute.targetPools.delete",
    "compute.targetPools.get",
    "compute.targetPools.list",
    "compute.targetPools.removeInstance",
    "compute.targetPools.use",
    "compute.zoneOperations.get",
    "compute.zones.list"
  ]
}
resource "google_project_iam_custom_role" "autoscaling_se" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_Autoscaling_SE_Project_Role"
  project     = var.service_engine_project != "" ? var.service_engine_project : var.project
  stage       = "ALPHA"
  title       = "AVI Server Autoscaling Role"
  description = "Access to resources required for GCP Server Autoscaling in Service Engine Project"
  permissions = [
    "pubsub.subscriptions.consume",
    "pubsub.subscriptions.create",
    "pubsub.subscriptions.delete",
    "pubsub.subscriptions.get",
    "pubsub.subscriptions.list",
    "pubsub.topics.attachSubscription",
    "pubsub.topics.create",
    "pubsub.topics.delete",
    "pubsub.topics.get",
    "pubsub.topics.getIamPolicy",
    "pubsub.topics.list",
    "pubsub.topics.setIamPolicy"
  ]
}
resource "google_project_iam_custom_role" "ilb_byoip" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_ILB_BYOIP_Project_Role"
  project     = var.service_engine_project != "" ? var.service_engine_project : var.project
  stage       = "ALPHA"
  title       = "AVI ILB and BYOIP Service Engine Project Role"
  description = "Access to resources required for ILB operations in Service Engine Project"
  permissions = [
    "compute.addresses.create",
    "compute.addresses.createInternal",
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.addresses.get",
    "compute.addresses.list",
    "compute.addresses.setLabels",
    "compute.addresses.use",
    "compute.addresses.useInternal",
    "compute.healthChecks.create",
    "compute.healthChecks.delete",
    "compute.healthChecks.get",
    "compute.healthChecks.list",
    "compute.healthChecks.update",
    "compute.healthChecks.use",
    "compute.healthChecks.useReadOnly",
    "compute.instanceGroups.create",
    "compute.instanceGroups.delete",
    "compute.instanceGroups.get",
    "compute.instanceGroups.list",
    "compute.instanceGroups.update",
    "compute.instanceGroups.use",
    "compute.regionBackendServices.create",
    "compute.regionBackendServices.delete",
    "compute.regionBackendServices.get",
    "compute.regionBackendServices.list",
    "compute.regionBackendServices.setSecurityPolicy",
    "compute.regionBackendServices.update",
    "compute.regionBackendServices.use"
  ]
}
resource "google_project_iam_custom_role" "storage" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_Storage_Project_Role"
  project     = var.storage_project != "" ? var.storage_project : var.project
  stage       = "ALPHA"
  title       = "AVI Storage Project Role"
  description = "Access to resources required for operations on GCS Buckets and Objects"
  permissions = [
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.list"
  ]
}
resource "google_project_iam_custom_role" "server" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_Server_Project_Role"
  project     = var.server_project != "" ? var.server_project : var.project
  stage       = "ALPHA"
  title       = "AVI Server Project Role"
  description = "Access to resources required for collecting servers information"
  permissions = [
    "compute.instanceGroupManagers.list",
    "compute.instanceGroups.get",
    "compute.instanceGroups.list",
    "compute.instances.get",
    "compute.instances.list",
    "compute.projects.get",
    "logging.sinks.create",
    "logging.sinks.delete",
    "logging.sinks.get",
    "logging.sinks.list",
    "logging.sinks.update"
  ]
}
resource "google_project_iam_custom_role" "cluster_vip" {
  count       = var.create_iam ? 1 : 0
  role_id     = "${var.name_prefix}_Avi_Cluster_VIP_Role"
  stage       = "ALPHA"
  title       = "AVI Cluster VIP Role"
  description = "Access to resources required for configuring cluster VIP"
  permissions = [
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.updateNetworkInterface"
  ]
}