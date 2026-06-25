public class DependencyInjectionDemo {
    public static void main(String[] args) {
        CustomerRepository repository = new InMemoryCustomerRepository();
        CustomerService service = new CustomerService(repository);

        service.addCustomer(new Customer(1, "John Doe"));
        service.printCustomer(1);
    }
}

class Customer {
    private final int id;
    private final String name;

    public Customer(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}

interface CustomerRepository {
    void save(Customer customer);
    Customer findById(int id);
}

class InMemoryCustomerRepository implements CustomerRepository {
    private final java.util.Map<Integer, Customer> data = new java.util.HashMap<>();

    @Override
    public void save(Customer customer) {
        data.put(customer.getId(), customer);
    }

    @Override
    public Customer findById(int id) {
        return data.get(id);
    }
}

class CustomerService {
    private final CustomerRepository repository;

    public CustomerService(CustomerRepository repository) {
        this.repository = repository;
    }

    public void addCustomer(Customer customer) {
        repository.save(customer);
        System.out.println("Customer added: " + customer.getName());
    }

    public void printCustomer(int id) {
        Customer customer = repository.findById(id);
        if (customer != null) {
            System.out.println("Found customer: " + customer.getName());
        } else {
            System.out.println("Customer not found with id: " + id);
        }
    }
}
