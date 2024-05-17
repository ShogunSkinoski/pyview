
import numpy as np
import cv2

class ImageProcessing:
    def __init__(self, path):
        self.image = cv2.imread(path)

    def apply_salt_and_pepper_noise(self, white_probability=0.05, black_probability=0.05):
        """Apply salt and pepper noise to the image.

        Args:
            white_probability: 0.05.
            black_probability: 0.05.
        """
        out = np.copy(self.image)

        # Generate a random array of 0s and 1s
        noise = np.random.choice([0, 1], size=self.image.shape, p=[white_probability, 1-white_probability])

        # Add noise to the image
        out[noise == 1] = 255
        out[noise == 0] = 0

        return out

    def apply_median_blur(self, kernel_size=3):
        """Apply a median filter to the image.

        Args:
            kernel_size: 3.
        """
        return cv2.medianBlur(self.image, kernel_size)

    def apply_prewitt_operation(self):
        """Apply Prewitt Operation with given path of image as 'assets' Use the OOP and Clean code principles write a ImageProcessing classand save the result image in the same path with the name of output.jpg."""

        # Convert the image to grayscale
        gray = cv2.cvtColor(self.image, cv2.COLOR_BGR2GRAY)

        # Apply the Prewitt operator to the image
        prewitt_x = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
        prewitt_y = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)

        # Calculate the magnitude of the gradient
        magnitude = np.sqrt(prewitt_x**2 + prewitt_y**2)

        # Normalize the magnitude
        magnitude = magnitude / np.max(magnitude)

        # Save the output image
        cv2.imwrite('output.jpg', magnitude)

if __name__ == "__main__":
    image = ImageProcessing('path/to/image.jpg')

    # Apply salt and pepper noise to the image
    noisy_image = image.apply_salt_and_pepper_noise()

    # Apply a median filter to the image
    filtered_image = image.apply_median_blur()

    # Apply Prewitt Operation to the image
    image.apply_prewitt_operation()

    # Display the original, noisy, and filtered images
    cv2.imshow('Original Image', image.image)
    cv2.imshow('Noisy Image', noisy_image)
    cv2.imshow('Filtered Image', filtered_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
