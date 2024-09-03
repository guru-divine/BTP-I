import cupy as cp
import numpy as np
import time

# Initialize the GPU
cp.cuda.Device(0).use()

# Define matrix size
N = 10000

# Generate random matrices
A = cp.random.rand(N, N).astype(cp.float32)
B = cp.random.rand(N, N).astype(cp.float32)

# Perform matrix multiplication on GPU
start_time = time.time()
C_gpu = cp.dot(A, B)
cp.cuda.Stream.null.synchronize()  # Wait for the computation to finish
gpu_time = time.time() - start_time

print(f"GPU computation time: {gpu_time:.4f} seconds")

# Optional: Perform the same computation on the CPU for comparison
A_cpu = cp.asnumpy(A)
B_cpu = cp.asnumpy(B)

start_time = time.time()
C_cpu = np.dot(A_cpu, B_cpu)
cpu_time = time.time() - start_time

print(f"CPU computation time: {cpu_time:.4f} seconds")