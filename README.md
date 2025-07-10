# Multi-Account AWS EC2 Disk Utilization Monitoring with Ansible

This repository contains the design and implementation details for a comprehensive solution to monitor EC2 disk utilization across multiple AWS accounts, leveraging Ansible and native AWS services.

## Table of Contents

1.  [Project Overview](#1.project-overview)
2.  [Architecture](#architecture)
3.  [Ansible Implementation](#ansible-implementation)
4.  [Solution Components](#solution-components)
5.  [Interactive Web Application](#interactive-web-application)
6.  [Scalability & Security](#scalability--security)

## 1. Project Overview

This project addresses the challenge of monitoring EC2 disk utilization in a large enterprise with a multi-account AWS environment, prioritizing the use of existing Ansible infrastructure. The goal is to provide a centralized, easily digestible view of disk space across all instances to proactively identify and mitigate potential issues.

## 2. Architecture

The solution employs a hub-and-spoke architecture, with a central management account orchestrating monitoring activities across various workload accounts. Cross-account IAM roles ensure secure and least-privilege access.

* **High-Level Diagram:** See the conceptual architectural diagram in `architecture/diagram.png`.
* **Diagram Description:** For a detailed breakdown of the diagram, refer to `architecture/diagram_description.md`.

## 3. Ansible Implementation

Ansible is used as the primary tool for metric collection. It leverages AWS Systems Manager (SSM) to execute commands on EC2 instances without requiring SSH access.

* **Ansible Playbook:** The core logic for collecting disk metrics is defined in `ansible/playbooks/collect_disk_metrics.yml`.
* **Dynamic Inventory:** The `ansible/inventory/aws_ec2.yml` file configures Ansible's dynamic inventory to discover EC2 instances across specified AWS accounts and regions.

## 4. Solution Components

A summary of all the AWS services and tools involved in this solution, along with their roles, can be found in `documentation/components_summary.md`.

## 5. Interactive Web Application

An interactive, single-page web application is provided to demonstrate how the collected data can be visualized and explored. This application is designed to make the solution's output easily consumable.

* **Launch the Web App:** Open `web_app/index.html` in your web browser.

## 6. Scalability & Security

The design incorporates AWS Organizations for multi-account management, automated IAM role deployment for new accounts, and dynamic inventory for seamless scaling. Security is baked in with IAM least privilege, network security (SSM over SSH), and data encryption.
