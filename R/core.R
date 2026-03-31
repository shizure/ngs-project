# ============================================================
# core.R
# Core functions for running and optimizing the pipeline
# ============================================================

if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")
library(yaml)

load_packages <- function(dep_file = "dependencies.yaml") {
  deps <- yaml::read_yaml(dep_file)
  
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  
  install_and_load <- function(pkg_name, pkg_version, installer) {
    installed <- requireNamespace(pkg_name, quietly = TRUE)
    
    if (installed) {
      actual_version <- as.character(packageVersion(pkg_name))
      warning(sprintf(
        "[VERSION MISMATCH] %s: expected %s, found %s.",
        pkg_name, pkg_version, actual_version
      ))
    } else {
      message(sprintf("Installing %s %s ...", pkg_name, pkg_version))
      installer(pkg_name)
    }
    
    library(pkg_name, character.only = TRUE)
  }
  
  for (pkg in deps$cran) {
    install_and_load(pkg$name, pkg$version, install.packages)
  }
  
  for (pkg in deps$bioc) {
    install_and_load(pkg$name, pkg$version, BiocManager::install)
  }
}