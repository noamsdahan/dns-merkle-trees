# Security Guidelines for DNS Merkle Tree Research

## 🚨 Critical Security Requirements

### SSH Keys and Private Credentials - NEVER COMMIT
- SSH private keys (`*.pem`, `*.key`, `id_rsa`, etc.)
- AWS credentials or configuration files
- Any file containing passwords, tokens, or secrets

### Secure Development Workflow
1. Generate SSH keys outside repository: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/dns_research_key`
2. Import public key to AWS: `aws ec2 import-key-pair --key-name your-key-name --public-key-material file://~/.ssh/dns_research_key.pub`
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize with your values
4. Never commit actual credential files - only example templates

### Example Files Provided
- `terraform.tfvars.example` - Template for Terraform variables
- Configuration templates in user_data scripts
- All actual credential files are gitignored but examples are included

### Emergency Response
If credentials are accidentally committed:
1. Immediately revoke/rotate the compromised credentials
2. Contact project maintainers - do not attempt Git history rewriting alone
3. All team members must refresh their repositories

**Remember: Security is everyone's responsibility. When in doubt, ask before committing.**