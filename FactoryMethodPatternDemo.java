public class FactoryMethodPatternDemo {
    public static void main(String[] args) {
        Document wordDoc = DocumentFactory.createDocument("WORD");
        Document pdfDoc = DocumentFactory.createDocument("PDF");
        Document excelDoc = DocumentFactory.createDocument("EXCEL");

        wordDoc.open();
        pdfDoc.open();
        excelDoc.open();
    }
}

interface Document {
    void open();
}

class WordDocument implements Document {
    @Override
    public void open() {
        System.out.println("Opening Word document...");
    }
}

class PdfDocument implements Document {
    @Override
    public void open() {
        System.out.println("Opening PDF document...");
    }
}

class ExcelDocument implements Document {
    @Override
    public void open() {
        System.out.println("Opening Excel document...");
    }
}

class DocumentFactory {
    public static Document createDocument(String type) {
        switch (type.toUpperCase()) {
            case "WORD":
                return new WordDocument();
            case "PDF":
                return new PdfDocument();
            case "EXCEL":
                return new ExcelDocument();
            default:
                throw new IllegalArgumentException("Unknown document type: " + type);
        }
    }
}
