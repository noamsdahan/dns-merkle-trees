# Quick Setup

## Build

```bash
cd dnsproxy
make build
```

## Run Locally  

```bash
# DNS proxy with Merkle verification (basic)
./dnsproxy --listen 127.0.0.1:5353 --upstream 8.8.8.8:53 -v

# Test query
dig @127.0.0.1 -p 5353 example.com

# With custom batch size and algorithm
./dnsproxy --listen 127.0.0.1:5353 \
           --upstream 8.8.8.8:53 \
           --merkle-batch-size 100 \
           --merkle-signature-algo ECDSA -v
```

## Configuration Options

### Core Settings
- `--listen ADDRESS:PORT` - Listen address (default: 127.0.0.1:53)
- `--upstream ADDRESS:PORT` - Upstream DNS server 
- `-v` - Verbose logging

### Merkle-Specific Options
- `--merkle-batch-size [1-4096]` - Responses per batch (default: 10)
- `--merkle-signature-algo [ECDSA|RSA]` - Signature algorithm (default: ECDSA)
- `--merkle-time-window DURATION` - Batch timeout (default: 5s)
- `--merkle-caching` - Enable signature caching for performance

### Key Files (Optional)
Place in dnsproxy/ directory for custom keys:
```
private.pem       # ECDSA private key
public.pem        # ECDSA public key  
rsa_private.pem   # RSA private key
rsa_public.pem    # RSA public key
```

## AWS Test Environment (Optional)

```bash
cd dns-lab-aws/terraform/ec2

# Initialize and deploy
terraform init
terraform apply

# SSH to servers (use output IPs)
ssh -i dns-ssh-keypair.pem ubuntu@<primary_dns_public_ip>

# On NS1 server
./dnsproxy --listen 0.0.0.0:5355 --upstream 127.0.0.1:53 -v

# On resolver (via jumpbox)
./dnsproxy --listen 0.0.0.0:5354 --upstream 10.0.1.11:5355 -v
```

## Development Commands

```bash
# Run tests
make test

# Full check suite (lint, test, tools)
make go-check

# Clean build artifacts
make clean

# Build release binaries
make release
```

## Troubleshooting

### Common Issues
- **Port already in use**: Change `--listen` port or stop conflicting service
- **Permission denied**: Run with `sudo` if using port < 1024
- **Key load failures**: Check key file paths and permissions
- **Build errors**: Ensure Go 1.19+ and run `make go-tools`

### Performance Tuning
- **Low latency**: Use batch size 1-10, ECDSA algorithm
- **High throughput**: Use batch size 100-500, enable caching
- **Memory constrained**: Use smaller batch sizes, disable caching

### Validation
```bash
# Check if Merkle verification is working
dig @127.0.0.1 -p 5353 +short TXT verification.example.com

# Should show base64-encoded proof data in response
```