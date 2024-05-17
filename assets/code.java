
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Random;
import javax.imageio.ImageIO;

public class ImageProcessing {

  private static final Random RANDOM = new Random();

  public static void main(String[] args) throws IOException {
    // Read the input image
    BufferedImage inputImage = ImageIO.read(new File("assets/input.jpg"));

    // Apply salt and pepper noise to the image
    applySaltAndPepperNoise(inputImage, 0.05, 0.05);

    // Apply a median filter to the image
    applyMedianFilter(inputImage, 3);

    // Apply Prewitt Operation
    applyPrewittOperation(inputImage);

    // Write the output image to a file
    ImageIO.write(inputImage, "jpg", new File("assets/output.jpg"));
  }

  private static void applySaltAndPepperNoise(BufferedImage image, double whiteProbability, double blackProbability) {
    for (int x = 0; x < image.getWidth(); x++) {
      for (int y = 0; y < image.getHeight(); y++) {
        double randomNumber = RANDOM.nextDouble();
        if (randomNumber < whiteProbability) {
          // Set the pixel to white
          image.setRGB(x, y, Color.WHITE.getRGB());
        } else if (randomNumber < whiteProbability + blackProbability) {
          // Set the pixel to black
          image.setRGB(x, y, Color.BLACK.getRGB());
        }
      }
    }
  }

  private static void applyMedianFilter(BufferedImage image, int kernelSize) {
    int[][][] pixels = new int[image.getWidth() + kernelSize * 2][image.getHeight() + kernelSize * 2][3];
    for (int x = 0; x < image.getWidth(); x++) {
      for (int y = 0; y < image.getHeight(); y++) {
        for (int rgbChannel = 0; rgbChannel < 3; rgbChannel++) {
          pixels[x + kernelSize][y + kernelSize][rgbChannel] = image.getRGB(x, y) >> (8 * rgbChannel) & 0xff;
        }
      }
    }

    for (int x = 0; x < image.getWidth(); x++) {
      for (int y = 0; y < image.getHeight(); y++) {
        for (int rgbChannel = 0; rgbChannel < 3; rgbChannel++) {
          int[] sortedValues = new int[kernelSize * kernelSize];
          int index = 0;
          for (int i = -kernelSize / 2; i <= kernelSize / 2; i++) {
            for (int j = -kernelSize / 2; j <= kernelSize / 2; j++) {
              sortedValues[index++] = pixels[x + kernelSize + i][y + kernelSize + j][rgbChannel];
            }
          }
          Arrays.sort(sortedValues);
          image.setRGB(x, y, new Color(sortedValues[kernelSize * kernelSize / 2], sortedValues[kernelSize * kernelSize / 2], sortedValues[kernelSize * kernelSize / 2]).getRGB());
        }
      }
    }
  }

  private static void applyPrewittOperation(BufferedImage image) {
    int[][][] kernelX = { { -1, 0, 1 }, { -1, 0, 1 }, { -1, 0, 1 } };
    int[][][] kernelY = { { -1, -1, -1 }, { 0, 0, 0 }, { 1, 1, 1 } };

    int[][][] gradientX = new int[image.getWidth()][image.getHeight()][3];
    int[][][] gradientY = new int[image.getWidth()][image.getHeight()][3];

    for (int x = 0; x < image.getWidth(); x++) {
      for (int y = 0; y < image.getHeight(); y++) {
        for (int rgbChannel = 0; rgbChannel < 3; rgbChannel++) {
          gradientX[x][y][rgbChannel] = convolve(image, kernelX, x, y, rgbChannel);
          gradientY[x][y][rgbChannel] = convolve(image, kernelY, x, y, rgbChannel);
        }
      }
    }

    for (int x = 0; x < image.getWidth(); x++) {
      for (int y = 0; y < image.getHeight(); y++) {
        for (int rgbChannel = 0; rgbChannel < 3; rgbChannel++) {
          // Calculate the magnitude of the gradient
          int magnitude = (int) Math.sqrt(gradientX[x][y][rgbChannel] * gradientX[x][y][rgbChannel] + gradientY[x][y][rgbChannel] * gradientY[x][y][rgbChannel]);
          // Normalize the magnitude to the range [0, 255]
          magnitude = Math.min(magnitude, 255);
          // Set the pixel to the magnitude value
          image.setRGB(x, y, new Color(magnitude, magnitude, magnitude).getRGB());
        }
      }
    }
  }

  private static int convolve(BufferedImage image, int[][][] kernel, int x, int y, int rgbChannel) {
    int sum = 0;
    for (int i = -kernel.length / 2; i <= kernel.length / 2; i++) {
      for (int j = -kernel[0].length / 2; j <= kernel[0].length / 2; j++) {
        int pixelX = x + i;
        int pixelY = y + j;
        if (pixelX >= 0 && pixelX < image.getWidth() && pixelY >= 0 && pixelY < image.getHeight()) {
          sum += image.getRGB(pixelX, pixelY) >> (8 * rgbChannel) & 0xff * kernel[i + kernel.length / 2][j + kernel[0].length / 2][rgbChannel];
        }
      }
    }
    return sum;
  }
}
