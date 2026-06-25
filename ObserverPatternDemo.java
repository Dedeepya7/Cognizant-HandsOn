import java.util.ArrayList;
import java.util.List;

public class ObserverPatternDemo {
    public static void main(String[] args) {
        StockMarket stockMarket = new StockMarket();
        StockObserver investorA = new StockObserver("Investor A");
        StockObserver investorB = new StockObserver("Investor B");

        stockMarket.addObserver(investorA);
        stockMarket.addObserver(investorB);

        stockMarket.setPrice(120.0);
        stockMarket.setPrice(130.5);
    }
}

interface Subject {
    void addObserver(Observer observer);
    void removeObserver(Observer observer);
    void notifyObservers();
}

interface Observer {
    void update(double price);
}

class StockMarket implements Subject {
    private final List<Observer> observers = new ArrayList<>();
    private double price;

    public void setPrice(double price) {
        this.price = price;
        notifyObservers();
    }

    @Override
    public void addObserver(Observer observer) {
        observers.add(observer);
    }

    @Override
    public void removeObserver(Observer observer) {
        observers.remove(observer);
    }

    @Override
    public void notifyObservers() {
        for (Observer observer : observers) {
            observer.update(price);
        }
    }
}

class StockObserver implements Observer {
    private final String name;

    public StockObserver(String name) {
        this.name = name;
    }

    @Override
    public void update(double price) {
        System.out.println(name + " received stock price update: " + price);
    }
}
