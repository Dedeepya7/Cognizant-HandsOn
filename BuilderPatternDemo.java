public class BuilderPatternDemo {
    public static void main(String[] args) {
        Computer computer = new Computer.Builder("Intel i9", "32GB")
                .withStorage("2TB SSD")
                .withGraphicsCard("NVIDIA RTX 4080")
                .withOperatingSystem("Windows 11")
                .build();

        System.out.println(computer);
    }
}

class Computer {
    private final String cpu;
    private final String ram;
    private final String storage;
    private final String graphicsCard;
    private final String operatingSystem;

    private Computer(Builder builder) {
        this.cpu = builder.cpu;
        this.ram = builder.ram;
        this.storage = builder.storage;
        this.graphicsCard = builder.graphicsCard;
        this.operatingSystem = builder.operatingSystem;
    }

    @Override
    public String toString() {
        return "Computer{" + "cpu='" + cpu + '\'' +", ram='" + ram + '\'' + ", storage='" + storage + '\'' +
                ", graphicsCard='" + graphicsCard + '\'' + ", operatingSystem='" + operatingSystem + '\'' +
 '}';
    }

    static class Builder {
        private final String cpu;
        private final String ram;
        private String storage = "256GB SSD";
        private String graphicsCard = "Integrated";
        private String operatingSystem = "No OS";

        public Builder(String cpu, String ram) {
            this.cpu = cpu;
            this.ram = ram;
        }

        public Builder withStorage(String storage) {
            this.storage = storage;
            return this;
        }

        public Builder withGraphicsCard(String graphicsCard) {
            this.graphicsCard = graphicsCard;
            return this;
        }

        public Builder withOperatingSystem(String operatingSystem) {
            this.operatingSystem = operatingSystem;
            return this;
        }

        public Computer build() {
            return new Computer(this);
        }
    }
}
