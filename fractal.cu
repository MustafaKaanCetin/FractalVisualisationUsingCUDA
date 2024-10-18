#include <cuda_runtime.h>

__device__ int map(int value, int start1, int stop1, int start2, int stop2) {
    return start2 + (stop2 - start2) * ((value - start1) / (float)(stop1 - start1));
}

__global__ void fractal_kernel(int width, int height, int max_iter, unsigned char* image, float zoom, float centerX, float centerY) {

    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if(x < width && y < height) {
        float zx, zy, cX, cY;
        zx = zy = 0.0f;
        cX = (x - width / 2.0f) * 4.0f / (width * zoom) + centerX;
        cY = (y - height / 2.0f) * 4.0f / (height * zoom) + centerY;
        float zx2 = 0.0f, zy2 = 0.0f;
        int iter = 0;
        while (zx * zx + zy * zy < 4.0f && iter < max_iter) {
            zy = 2.0f * zx * zy +cY;
            zx = zx2 - zy2 + cX;
            zx2 = zx * zx;
            zy2 = zy * zy;
            iter++;
        }

        int idx = (y * width + x) * 3;
        int bright = map(iter, 0, max_iter, 0, 255);

        if((iter >= max_iter - 5) || (bright < 10)) {
            bright = 0;
        }

        int red = map(bright * bright, 0, 6502, 0, 255);
        int green = bright;
        int blue = map(sqrtf(bright), 0, sqrtf(255), 0, 255);

        image[idx] = red;
        image[idx + 1] = green;
        image[idx + 2] = blue;
    }

}

extern "C" void launch_kernel(int width, int height, int max_iter, unsigned char* image, float zoom, float centerX, float centerY) {
    unsigned char* d_image;
    size_t image_size = width * height * 3 * sizeof(unsigned char);
    cudaMalloc(&d_image, image_size);
    cudaMemcpy(d_image, image, image_size, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((width + threadsPerBlock.x - 1) / threadsPerBlock.x,
                   (height + threadsPerBlock.y - 1) / threadsPerBlock.y);
    fractal_kernel<<<numBlocks, threadsPerBlock>>>(width, height, max_iter, d_image, zoom, centerX, centerY);

    cudaMemcpy(image, d_image, image_size, cudaMemcpyDeviceToHost);
    cudaFree(d_image);
}