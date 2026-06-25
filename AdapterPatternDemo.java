public class AdapterPatternDemo {
    public static void main(String[] args) {
        PaymentProcessor payPalPayment = new PayPalAdapter(new PayPalGateway());
        PaymentProcessor stripePayment = new StripeAdapter(new StripeGateway());

        payPalPayment.pay(150.00);
        stripePayment.pay(230.50);
    }
}

interface PaymentProcessor {
    void pay(double amount);
}

class PayPalGateway {
    public void sendPayment(double amount) {
        System.out.println("Processing payment through PayPal: $" + amount);
    }
}

class StripeGateway {
    public void makePayment(double amount) {
        System.out.println("Processing payment through Stripe: $" + amount);
    }
}

class PayPalAdapter implements PaymentProcessor {
    private final PayPalGateway payPalGateway;

    public PayPalAdapter(PayPalGateway payPalGateway) {
        this.payPalGateway = payPalGateway;
    }

    @Override
    public void pay(double amount) {
        payPalGateway.sendPayment(amount);
    }
}

class StripeAdapter implements PaymentProcessor {
    private final StripeGateway stripeGateway;

    public StripeAdapter(StripeGateway stripeGateway) {
        this.stripeGateway = stripeGateway;
    }

    @Override
    public void pay(double amount) {
        stripeGateway.makePayment(amount);
    }
}

