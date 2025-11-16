# Ansible Automation Guide

Terraform generates an inventory file that Ansible uses to configure the EC2 instances.

## Running the Playbook

From the repository root:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml
```

## What Ansible Installs

| Tool      | Port  | Description                |
|-----------|-------|----------------------------|
| Jenkins   | 8080  | CI/CD server               |
| Nexus     | 8081  | Artifact repository        |
| SonarQube | 9000  | Code quality and security  |
| Docker    | N/A   | Container runtime engine   |
| Git, unzip| N/A   | Utility tools              |

## Notes

- Jenkins is typically installed as a system service.
- Nexus and SonarQube are usually run via Docker containers.
