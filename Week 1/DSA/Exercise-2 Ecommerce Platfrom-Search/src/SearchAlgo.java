
public class SearchAlgorithms {

    /**
     * Linear Search: Checks every element one by one.
     * Works on both sorted and unsorted arrays.
     */
    public static Product linearSearch(Product[] products, int targetId) {
        for (Product p : products) {
            if (p.getProductId() == targetId) {
                return p; // Found it
            }
        }
        return null; // Not found
    }

    /**
     * Binary Search: Divides the search interval in half.
     * MUST be applied to a sorted array.
     */
    public static Product binarySearch(Product[] products, int targetId) {
        int left = 0;
        int right = products.length - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2; // Prevents integer overflow
            
            if (products[mid].getProductId() == targetId) {
                return products[mid]; // Target found
            }
            
            if (products[mid].getProductId() < targetId) {
                left = mid + 1; // Target must be in the right half
            } else {
                right = mid - 1; // Target must be in the left half
            }
        }
        return null; // Not found
    }
}
