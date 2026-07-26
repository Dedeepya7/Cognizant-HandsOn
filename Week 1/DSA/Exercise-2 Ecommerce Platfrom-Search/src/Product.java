package com.cognizant.javadfse.week1.dsa.search;

/**
 * Product class representing an e-commerce item.
 * Implements Comparable to allow easy sorting by productId for Binary Search.
 */
public class Product implements Comparable<Product> {
    private int productId;
    private String productName;
    private String category;

    public Product(int productId, String productName, String category) {
        this.productId = productId;
        this.productName = productName;
        this.category = category;
    }

    public int getProductId() { return productId; }
    public String getProductName() { return productName; }
    public String getCategory() { return category; }

    // This tells Java how to sort Product objects (Ascending order by ID)
    @Override
    public int compareTo(Product other) {
        return Integer.compare(this.productId, other.productId);
    }

    @Override
    public String toString() {
        return "ID: " + productId + " | Name: " + productName + " | Category: " + category;
    }
}
