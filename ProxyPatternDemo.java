public class ProxyPatternDemo {
    public static void main(String[] args) {
        Image image = new ImageProxy("photo.jpg");
        image.display();
        image.display();
    }
}

interface Image {
    void display();
}

class RealImage implements Image {
    private final String fileName;

    public RealImage(String fileName) {
        this.fileName = fileName;
        loadFromRemoteServer();
    }

    @Override
    public void display() {
        System.out.println("Displaying image: " + fileName);
    }

    private void loadFromRemoteServer() {
        System.out.println("Loading image from remote server: " + fileName);
    }
}

class ImageProxy implements Image {
    private final String fileName;
    private RealImage realImage;

    public ImageProxy(String fileName) {
        this.fileName = fileName;
    }

    @Override
    public void display() {
        if (realImage == null) {
            realImage = new RealImage(fileName);
        } else {
            System.out.println("Using cached image: " + fileName);
        }
        realImage.display();
    }
}
