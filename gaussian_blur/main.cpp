#include <iostream>
#include <opencv2/opencv.hpp>
#include <string>
#include "kernel.hpp"

const int BLUR_SIZE = 3;
int main(int argc, char **argv) {
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <image_file>" << '\n';
        return 1;
    }
    
    std::string fname(argv[1]);
    cv::Mat img = cv::imread(argv[1], cv::IMREAD_COLOR);
    
    if (img.empty()) {
        std::cout << "Error: Failed to load image '" << fname << "'" << '\n';
        return 1;
    }
    
    std::cout << "Image loaded: " << img.cols << "x" << img.rows 
              << " (" << img.channels() << " channels)" << '\n';
    
    cv::namedWindow("Original", cv::WINDOW_AUTOSIZE);
    cv::imshow("Original", img);
    std::cout << "Showing original image. Press any key to continue..." << '\n';
    cv::waitKey();
    
    if (!img.isContinuous()) {
        std::cout << "Warning: Image is not continuous. Creating a copy..." << '\n';
        img = img.clone();
    }
    
    std::cout << "Applying blur..." << '\n';
    blur((unsigned char*)img.data, img.cols, img.rows, BLUR_SIZE);
    std::cout << "Blur complete!" << '\n';
    
    cv::namedWindow("Blurred", cv::WINDOW_AUTOSIZE);
    cv::imshow("Blurred", img);
    std::cout << "Showing blurred image. Press any key to exit..." << '\n';
    cv::waitKey();
    
    cv::destroyAllWindows();
    return 0;
}
