import java.util.Arrays;
public class EcommerceSearchExample {
    public static void main(String[] args) {
        // 1. Setup mock database of products
        Product[] inventory = {
            new Product(105, "Gaming Laptop", "Electronics"),
            new Product(101, "Wireless Mouse", "Accessories"),
            new Product(109, "Mechanical Keyboard", "Accessories"),
            new Product(103, "Monitor Stand", "Furniture"),
            new Product(107, "Noise Cancelling Headphones", "Audio")
        };

        int searchTarget = 107;

        System.out.println("--- E-Commerce Search Platform ---");

        // 2. Linear Search Execution (Array does not need to be sorted)
        System.out.println("\n[1] Executing Linear Search...");
        Product linearResult = SearchAlgorithms.linearSearch(inventory, searchTarget);
        System.out.println(linearResult != null ? "Found: " + linearResult : "Product not found.");

        // 3. Binary Search Execution (Array MUST be sorted first)
        System.out.println("\n[2] Sorting Inventory for Binary Search...");
        Arrays.sort(inventory); // Sorts based on the compareTo method we wrote in Product.java
        
        System.out.println("[3] Executing Binary Search...");
        Product binaryResult = SearchAlgorithms.binarySearch(inventory, searchTarget);
        System.out.println(binaryResult != null ? "Found: " + binaryResult : "Product not found.");
    }
}
