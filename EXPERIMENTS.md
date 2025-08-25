# Running Experiments

## Performance Testing

The `dns-lab-aws/experiment_log/` directory contains comprehensive test results for:
- **Batch sizes**: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
- **Algorithms**: ECDSA vs RSA signatures  
- **Metrics**: Response latency, CPU usage, throughput, memory consumption

Each test directory follows naming pattern: `YYYYMMDD-HHMMSS_batch_SIZE_ALGORITHM`

## Reproduce Tests

### Local Testing
```bash
# Basic performance test
cd dnsproxy
./dnsproxy --listen 127.0.0.1:5353 \
           --upstream 8.8.8.8:53 \
           --merkle-batch-size 100 \
           --merkle-signature-algo ECDSA -v

# Generate load in separate terminal
for i in {1..1000}; do
  dig @127.0.0.1 -p 5353 test$i.example.com +short
done
```

### AWS Infrastructure Testing
```bash
# Deploy test environment
cd dns-lab-aws/terraform/ec2
terraform apply

# On NS1 server (authoritative)
./dnsproxy --listen 0.0.0.0:5355 \
           --upstream 127.0.0.1:53 \
           --merkle-batch-size 100 \
           --merkle-signature-algo ECDSA -v

# On resolver server  
./dnsproxy --listen 0.0.0.0:5354 \
           --upstream 10.0.1.11:5355 -v

# Generate test queries
python3 dns_query.py --target 10.0.1.11:5354 --count 10000
```

## Test Data Collection

### Automated Testing Script
```bash
#!/bin/bash
# Example test harness for batch size sweep

for batch_size in 1 10 100 1000; do
  for algo in ECDSA RSA; do
    echo "Testing batch_size=$batch_size algo=$algo"
    
    # Start dnsproxy with specific config
    ./dnsproxy --merkle-batch-size $batch_size \
               --merkle-signature-algo $algo &
    PROXY_PID=$!
    
    # Run performance test
    python3 performance_test.py --duration 60 --qps 100
    
    # Collect metrics
    ps -p $PROXY_PID -o pid,pcpu,pmem,time
    
    # Stop proxy
    kill $PROXY_PID
    sleep 5
  done
done
```

## Key Experimental Findings

### Latency Impact (Response Time Overhead)
| Batch Size | ECDSA | RSA   | Difference |
|------------|-------|-------|------------|
| 1          | +0.8ms| +2.1ms| 2.6x       |
| 10         | +1.2ms| +3.4ms| 2.8x       |  
| 100        | +2.1ms| +5.8ms| 2.8x       |
| 1000       | +8.7ms| +19.2ms| 2.2x      |

### CPU Overhead (Peak Usage)
| Batch Size | Baseline | ECDSA  | RSA    |
|------------|----------|--------|--------|
| 1          | 45%      | 52%    | 63%    |
| 100        | 45%      | 58%    | 78%    |
| 1000       | 45%      | 71%    | 94%    |

### Memory Usage
- **Constant overhead**: ~15MB regardless of batch size
- **Efficient serialization**: 2-byte indices keep memory bounded
- **Buffer management**: Double-buffer prevents memory leaks

## Performance Analysis Tools

### Profiling Commands
```bash
# CPU profiling during test
go tool pprof -http=:8080 http://localhost:6060/debug/pprof/profile

# Memory analysis  
go tool pprof -http=:8080 http://localhost:6060/debug/pprof/heap

# Goroutine analysis
go tool pprof -http=:8080 http://localhost:6060/debug/pprof/goroutine
```

### Log Analysis
```bash
# Extract latency data from experiment logs
grep "response_time" experiment_log/*/20240728-*.output | \
  awk '{print $3}' | sort -n

# CPU peak analysis
for dir in experiment_log/2024*; do
  echo "$dir: $(cat $dir/ns_total_peak_cpu.txt)%"
done
```

## Optimal Configuration Recommendations

### Low Latency (< 5ms overhead)
```bash
./dnsproxy --merkle-batch-size 10 \
           --merkle-signature-algo ECDSA \
           --merkle-caching
```

### Balanced Performance (security/performance)
```bash
./dnsproxy --merkle-batch-size 100 \
           --merkle-signature-algo ECDSA \
           --merkle-time-window 2s \
           --merkle-caching
```

### High Security (maximum batch verification)
```bash
./dnsproxy --merkle-batch-size 1000 \
           --merkle-signature-algo RSA \
           --merkle-time-window 10s
```

## Test Environment Cleanup

```bash
# Stop AWS infrastructure
terraform destroy

# Clean local test data
rm -rf test_results/
pkill dnsproxy
```

## Data Visualization

Experiment results include:
- **Gnuplot scripts** for latency/throughput charts
- **HTML reports** with interactive graphs  
- **PNG outputs** for publication use
- **Raw data files** (.output, .log) for custom analysis

Example visualization:
```bash
cd dns-lab-aws/experiment_log/20240728-142102_batch_100_ecdsa
gnuplot 20240728-1421.gnuplot
# Generates 20240728-1421.latency.png and 20240728-1421.rate.png
```