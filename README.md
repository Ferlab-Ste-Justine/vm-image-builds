# About

This repo provides builds for our vm images with packer and ansible to get all external dependencies pre-installed in our images.

The created images are not meant to provide finalized functionality by themselves. They are just meant to eliminate the need for external dependencies on vm creation.

For the entire functionality, we'll keep using terraform modules with cloud-init for the last round of runtime configuration.

# Project Status

WIP