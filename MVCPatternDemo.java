public class MVCPatternDemo {
    public static void main(String[] args) {
        Student model = new Student(1, "Alice");
        StudentView view = new StudentView();
        StudentController controller = new StudentController(model, view);

        controller.updateStudentName("Alice Johnson");
        controller.updateView();
    }
}
class Student {
    private int id;
    private String name;
    public Student(int id, String name) {
        this.id = id;
        this.name = name;
    }
    public int getId() {
        return id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
}
class StudentView {
    public void printStudentDetails(int id, String name) {
        System.out.println("Student: ");
        System.out.println("ID: " + id);
        System.out.println("Name: " + name);
    }
}
class StudentController {
    private final Student model;
    private final StudentView view;
    public StudentController(Student model, StudentView view) {
        this.model = model;
        this.view = view;
    }
    public void updateStudentName(String name) {
        model.setName(name);
    }
    public void updateView() {
        view.printStudentDetails(model.getId(), model.getName());
    }
}
