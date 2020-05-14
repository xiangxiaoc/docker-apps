# docker-compose Script Client

[中文版 README](README_zh.md)

## Overview

Here are some of the tested container service choreography project. Basically is to follow the Docker advocated by the "code once, run anywhere". For `docker-compose` familiar veteran can direct access to YAML files.Relevant points for attention, if any, will be added in their corresponding directories.

Several of the choreography projects are dedicated to understanding and learning about docker-related mechanisms.For example 'logging-driver', you can see that you can configure the container with multiple log drivers for log management as needed.

## docker-compose.sh Script

This project provides a Shell script, through the way of interaction, realizes the common operation.Use it to deploy and manage may reduce a little bit of operating time, but the docker and docker - compose with the help of a larger series of commands are not familiar with classmates(in fact I have been in use, because lazy to knock command).

## Compose File Format

The default version of the orchestration file is basically 2.x, which is convenient to set the memory allocation directly. If the installed docker and docker-compose versions are too low, please refer to the official documentation to see the comparison table and make appropriate adjustments according to your own version.

https://docs.docker.com/compose/compose-file/compose-versioning/#compatibility-matrix
