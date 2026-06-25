public class SingletonPatternDemo {
    public static void main(String[] args) {
        LoggerSingleton logger1 = LoggerSingleton.getInstance();
        LoggerSingleton logger2 = LoggerSingleton.getInstance();

        logger1.log("Starting singleton demo...");
        logger2.log("Both references point to the same logger instance.");

        System.out.println("logger1 == logger2: " + (logger1 == logger2));
    }
}

class LoggerSingleton {
    private static LoggerSingleton instance;
    private LoggerSingleton() {
        // Private constructor prevents external instantiation
    }

    public static synchronized LoggerSingleton getInstance() {
        if (instance == null) {
            instance = new LoggerSingleton();
        }
        return instance;
    }

    public void log(String message) {
        System.out.println("[Logger] " + message);
    }
}
