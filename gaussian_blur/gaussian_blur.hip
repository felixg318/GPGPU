#include <cstring>
#include "example_utils.hpp"
#include <hip/hip_runtime.h>
#include <iostream>

__global__ void blur_kernel(unsigned char* Pin, unsigned char* Pout, int width, int height, int blur_size) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (col < width && row < height) {
        // Process each color channel (BGR)
        for (int channel = 0; channel < 3; ++channel) {
            int pixVal = 0;
            int pixels = 0;
            
            for (int blurRow = -blur_size; blurRow <= blur_size; ++blurRow) {
                for (int blurCol = -blur_size; blurCol <= blur_size; ++blurCol) {
                    int curRow = row + blurRow;
                    int curCol = col + blurCol;
                    
                    if (curRow >= 0 && curRow < height && curCol >= 0 && curCol < width) {
                        int idx = (curRow * width + curCol) * 3 + channel;
                        pixVal += Pin[idx];
                        ++pixels;
                    }
                }
            }
            
            int outIdx = (row * width + col) * 3 + channel;
            Pout[outIdx] = (unsigned char)(pixVal / pixels);
        }
    }
}

void blur(unsigned char *img_h, int width, int height, int blur_size) {
    unsigned char *img_d, *result_d;
    int bytes = width * height * 3 * sizeof(unsigned char);  // 3 channels for BGR
    
    hipDeviceProp_t props;
    HIP_CHECK(hipGetDeviceProperties(&props, 0));
    
    dim3 blockSize(16, 16);  // 256 threads per block
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, 
                  (height + blockSize.y - 1) / blockSize.y);
    
    std::cout << "Grid: " << gridSize.x << "x" << gridSize.y 
              << ", Block: " << blockSize.x << "x" << blockSize.y << '\n';
    
    HIP_CHECK(hipMalloc(&img_d, bytes));
    HIP_CHECK(hipMalloc(&result_d, bytes));
    
    HIP_CHECK(hipMemcpy(img_d, img_h, bytes, hipMemcpyHostToDevice));
    
    blur_kernel<<<gridSize, blockSize>>>(img_d, result_d, width, height, blur_size);
    HIP_CHECK(hipGetLastError());
    
    HIP_CHECK(hipDeviceSynchronize());
    
    HIP_CHECK(hipMemcpy(img_h, result_d, bytes, hipMemcpyDeviceToHost));
    
    HIP_CHECK(hipFree(img_d));
    HIP_CHECK(hipFree(result_d));
}
