# Solution Components Summary

This section summarizes the various AWS services and tools involved in the Multi-Account AWS EC2 Disk Utilization Monitoring solution.

## 1. AWS Organizations

* **Purpose:** Centralized account management, consolidated billing, and service control policies (SCPs).
* **Role in Solution:** Provides the foundational structure for managing multiple AWS accounts, enabling a unified governance model.

## 2. AWS Identity and Access Management (IAM)

* **Purpose:** Securely controls access to AWS resources.
* **Role in Solution:**
    * `AnsibleControllerRole` (Management Account): Allows the Ansible Control Host to assume roles in workload accounts.
    * `AnsibleExecutionRole` (Workload Accounts): Granted to EC2 instances, allowing SSM Agent to perform actions and write logs/data to central services.
    * Cross-account trust policies: Enable `AnsibleControllerRole` to assume `AnsibleExecutionRole`, ensuring secure, temporary access.

## 3. AWS Systems Manager (SSM)

* **Purpose:** Operational insights and control of EC2 instances.
* **Role in Solution:**
    * **SSM Agent:** Installed on EC2 instances, allowing remote command execution without requiring SSH.
    * **Run Command:** Used by Ansible to execute the **generic disk utilization script** on target instances. The `AWS-RunShellScript` document intelligently handles execution for both Linux (Bash) and Windows (PowerShell) based on the script's content.
    * **SSM Automation (Optional but recommended for scalability):** Can encapsulate the disk collection logic for standardized execution across a large fleet.

## 4. Ansible Control Host

* **Purpose:** Orchestrates the execution of playbooks and interacts with AWS APIs.
* **Role in Solution:** A dedicated server (e.g., EC2 instance) where Ansible is installed and configured. It executes the Ansible playbook, leveraging `aws_ssm` and dynamic inventory to target EC2 instances across accounts.

## 5. Ansible

* **Purpose:** Configuration management and automation tool.
* **Role in Solution:**
    * **Dynamic Inventory:** Discovers EC2 instances across multiple accounts based on tags, regions, etc.
    * **`amazon.aws.aws_ssm` module:** Executes the generic script on EC2 instances via the SSM service.
    * **Playbooks:** Defines the automated steps for collecting disk utilization metrics and sending them to a central location.

## 6. Amazon Simple Storage Service (S3)

* **Purpose:** Object storage for any type of data.
* **Role in Solution:** A central, highly durable, and scalable repository for storing raw disk utilization data collected from all instances. This serves as the source for further processing.

## 7. AWS Lambda (Optional for Processing)

* **Purpose:** Serverless compute service for event-driven processing.
* **Role in Solution:** Can be triggered by new objects in the S3 bucket to process, transform, or enrich the raw disk utilization data before it's sent to CloudWatch or other analytics services.

## 8. AWS CloudWatch Logs

* **Purpose:** Centralized logging service.
* **Role in Solution:** Aggregates SSM command output (containing disk utilization data) from all instances across all accounts into a single, centralized log group for unified monitoring and analysis.

## 9. AWS CloudWatch Metrics

* **Purpose:** Collects monitoring and operational data.
* **Role in Solution:** Custom metrics are created from filtered CloudWatch Logs (or direct pushes from Lambda), providing numerical data points for disk utilization, which can be graphed and alarmed upon.

## 10. AWS CloudWatch Dashboards

* **Purpose:** Customizable dashboards for monitoring resources.
* **Role in Solution:** Provides a consolidated, single-pane-of-glass visualization of disk utilization across all EC2 instances from all accounts, offering an "easily digestible format" for operational teams and stakeholders.

## 11. Amazon Simple Notification Service (SNS)

* **Purpose:** Pub/Sub messaging service for notifications.
* **Role in Solution:** Used by CloudWatch Alarms to send real-time notifications to relevant teams (e.g., via email, SMS, PagerDuty, Slack integration) when disk utilization thresholds are breached.
