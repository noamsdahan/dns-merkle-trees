# DNS Merkle Tree Verification System

A unified DNS security research project implementing Merkle tree-based cryptographic verification of DNS responses to ensure response integrity and authenticity.

## 🏗️ Repository Structure

This project consists of two main submodules:

```
dns-merkle-tree-research/
├── dnsproxy/              # Enhanced DNS proxy with Merkle tree verification
├── dns-lab-aws/           # AWS infrastructure for performance testing  
├── README.md              # This file
├── SETUP.md               # Build and setup instructions
├── EXPERIMENTS.md         # Performance testing procedures
└── SECURITY.md            # Security guidelines
```

## 📦 Submodules

### [dnsproxy/](./dnsproxy)
Enhanced Go-based DNS proxy server with **Merkle tree batching and verification system**:
- Batches DNS responses for efficient cryptographic verification 
- Embeds Merkle proofs and ECDSA/RSA signatures in DNS TXT records
- Provides end-to-end response integrity verification with minimal performance overhead
- **Repository**: https://github.com/noamsdahan/dnsproxy

### [dns-lab-aws/](./dns-lab-aws) 
Terraform infrastructure for comprehensive DNS testing and performance evaluation:
- KNOT DNS authoritative servers with online DNSSEC signing
- BIND recursive resolver with Merkle verification overlay
- Automated performance testing across 24+ configurations
- Cost-optimized deployment options (~$0.13/hour for testing)

## 🚀 Quick Start

### Clone with Submodules
```bash
git clone --recursive <your-repo-url>
cd unified-dns-research

# If already cloned, initialize submodules:
git submodule update --init --recursive
```

### Build and Test Locally
```bash
# Build the enhanced DNS proxy
cd dnsproxy
make build

# Run with Merkle verification enabled
./dnsproxy --listen 127.0.0.1:5353 --upstream 8.8.8.8:53 --merkle-ans --batch-size 4 -v

# Test in another terminal
dig @127.0.0.1 -p 5353 example.com
```

### Deploy AWS Test Infrastructure
```bash
# Deploy cost-effective test environment
cd dns-lab-aws/terraform/ec2
terraform init
terraform apply -var-file="functional-test.tfvars"
```

## 📊 Research Results

### Performance Highlights
- **Peak Performance**: 15,536 QPS (RSA, batch size 1024)
- **CPU Efficiency**: 48% reduction in overhead (229% → 119%)
- **Algorithm Comparison**: ECDSA 39% faster at small batch sizes
- **Optimal Batch Range**: 256-1024 responses for production deployment

### Key Findings
| Configuration | QPS | CPU Overhead | Performance Gain |
|---------------|-----|--------------|------------------|
| ECDSA Batch 1 | 13,038 | 229% | Baseline |
| ECDSA Batch 1024 | 14,100 | 119% | +8.1% |
| RSA Batch 1 | 9,378 | 267% | Baseline |
| RSA Batch 1024 | 15,536 | 134% | +65.7% |

## 🔬 Research Contributions

### Technical Innovation
- **Merkle Tree Batching**: Reduces signature operations from O(n) to O(log n)
- **DNS Integration**: Embeds cryptographic proofs in standard TXT records  
- **Dual Algorithm Support**: ECDSA P-256 and RSA-2048 with performance optimization
- **Attack Resilience**: Protection against signature flooding through batching

### Performance Analysis
- **Comprehensive Testing**: 24 configurations across batch sizes 1-2048
- **Infrastructure Validation**: AWS-based realistic DNS environment testing
- **Resource Optimization**: Detailed CPU and memory usage analysis
- **Production Guidelines**: Evidence-based deployment recommendations

## 📚 Documentation

### Technical Documentation  
- [`SETUP.md`](./SETUP.md) - Build instructions and configuration
- [`EXPERIMENTS.md`](./EXPERIMENTS.md) - Performance testing procedures
- [`SECURITY.md`](./SECURITY.md) - Security guidelines and best practices

### Infrastructure Guides
- [`dns-lab-aws/README.md`](./dns-lab-aws/README.md) - Comprehensive infrastructure setup
- [`dns-lab-aws/terraform/`](./dns-lab-aws/terraform/) - Complete Terraform configurations

## 🎯 Use Cases

### Academic Research
- **Performance Baseline** for DNS Merkle tree implementations
- **Methodology Template** for systematic DNS security evaluation
- **Experimental Validation** with rigorous testing procedures

### Production Deployment
- **DNSSEC Enhancement** with reduced computational overhead
- **Attack Mitigation** against signature flooding and enumeration
- **Scalability Improvement** for high-traffic DNS infrastructure

### Educational Purpose
- **Complete Implementation** of cryptographic DNS verification
- **Infrastructure as Code** examples for cloud-based DNS testing
- **Research Methodology** demonstration for performance evaluation

## 🔒 Security Considerations

- All sensitive files (SSH keys, AWS credentials) are properly gitignored
- Cryptographic keys are generated locally and never committed
- Infrastructure configurations use secure defaults
- Regular security audits ensure no credential exposure

## 🤝 Contributing

This research project welcomes contributions in:
- Performance optimization and algorithm improvements
- Additional cryptographic signature schemes
- Infrastructure enhancements and cost optimizations
- Documentation improvements and clarity

## 📄 License

This project extends the original dnsproxy under the Apache License 2.0. See individual submodule LICENSE files for details.

## 📖 Citation

When citing this research, please reference both the algorithmic contribution and the comprehensive experimental validation:

```bibtex
@article{merkle_dns_2024,
    title={Barking Up the Right Tree: Using Merkle Tree DNSSEC Signatures for Resiliency},
    author={Afek, Yehuda and Bremler-Barr, Anat and Ronen, Eyal and Dahan, Noam Forman},
    year={2024},
    institution={Tel-Aviv University}
}
```

---

This unified repository represents a complete DNS security research environment combining theoretical cryptographic implementations with practical cloud infrastructure for testing and validation.