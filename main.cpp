#include <SDL2/SDL.h>
#include <cmath>

extern "C" void launch_kernel(int width, int height, int max_iter, unsigned char* image, float zoom, float centerX, float centerY);

int width = 1000;
int height = 1000;
int max_iter = 200;

float zoom = 1.0f;
float zoom_factor = 1.0025f;
float centerX = -1.05f;
float centerY = 0.25f;

int main() {
    SDL_Init(SDL_INIT_EVERYTHING);

    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_Event event;

    SDL_CreateWindowAndRenderer(width, height, 0, &window, &renderer);
    SDL_RenderSetLogicalSize(renderer, width, height);

    unsigned char* image = new unsigned char[width * height * 3];
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STATIC, width, height);

    while(1) {

        if(SDL_PollEvent(&event) && event.type == SDL_QUIT) {
            break;
        }

        if(SDL_PollEvent(&event) && event.type == SDL_KEYDOWN) {
            int key = event.key.keysym.sym;

            if(key == SDLK_ESCAPE) {
                break;
            }
        }
        launch_kernel(width, height, max_iter, image, zoom, centerX, centerY);
        SDL_UpdateTexture(texture, NULL, image, width * 3 * sizeof(unsigned char));

        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);

        zoom *= zoom_factor;
        max_iter += 1;
    }
    delete[] image;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}