import java.util.ArrayList;
import java.util.List;

public class CommandPatternDemo {
    public static void main(String[] args) {
        Light light = new Light();
        Command switchOn = new TurnOnCommand(light);
        Command switchOff = new TurnOffCommand(light);

        RemoteControl remote = new RemoteControl();
        remote.addCommand(switchOn);
        remote.addCommand(switchOff);
        remote.executeCommands();
    }
}

interface Command {
    void execute();
}

class Light {
    public void on() {
        System.out.println("Light is ON");
    }

    public void off() {
        System.out.println("Light is OFF");
    }
}

class TurnOnCommand implements Command {
    private final Light light;

    public TurnOnCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.on();
    }
}

class TurnOffCommand implements Command {
    private final Light light;

    public TurnOffCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.off();
    }
}

class RemoteControl {
    private final List<Command> commandList = new ArrayList<>();

    public void addCommand(Command command) {
        commandList.add(command);
    }

    public void executeCommands() {
        for (Command command : commandList) {
            command.execute();
        }
    }
}
