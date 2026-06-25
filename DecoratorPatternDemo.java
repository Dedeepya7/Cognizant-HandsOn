public class DecoratorPatternDemo {
    public static void main(String[] args) {
        Notification notification = new EmailNotification(new BasicNotification());
        notification = new SMSNotification(notification);

        notification.send("Your order has been shipped.");
    }
}

interface Notification {
    void send(String message);
}

class BasicNotification implements Notification {
    @Override
    public void send(String message) {
        System.out.println("Notification: " + message);
    }
}

abstract class NotificationDecorator implements Notification {
    protected Notification wrappedNotification;

    public NotificationDecorator(Notification notification) {
        this.wrappedNotification = notification;
    }
}

class EmailNotification extends NotificationDecorator {
    public EmailNotification(Notification notification) {
        super(notification);
    }

    @Override
    public void send(String message) {
        wrappedNotification.send(message);
        sendEmail(message);
    }

    private void sendEmail(String message) {
        System.out.println("Sending email notification: " + message);
    }
}

class SMSNotification extends NotificationDecorator {
    public SMSNotification(Notification notification) {
        super(notification);
    }

    @Override
    public void send(String message) {
        wrappedNotification.send(message);
        sendSMS(message);
    }

    private void sendSMS(String message) {
        System.out.println("Sending SMS notification: " + message);
    }
}
