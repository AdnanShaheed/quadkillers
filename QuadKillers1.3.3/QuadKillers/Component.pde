class CommandBase {
    public boolean isActive = false;
    //called once when the command starts
    public void init() {
        isActive = true;
    };
    //called every frame
    public void update() {}
    //When this function is called, the command is terminated
    public void terminate() {
        isActive = false;
    }
}

//Every command in this group is run at the same time (used most commonly)
class ParallelCommandGroup extends CommandBase {
    ArrayList<CommandBase> commands;
    public ParallelCommandGroup() {
        commands = new ArrayList<CommandBase>();
    }
    public ParallelCommandGroup(int initialCapacity) {
        commands = new ArrayList<CommandBase>(initialCapacity);
    }
    @Override
    public void init() {
        for (CommandBase c : commands) {
            c.init();
        }
    }
    @Override
    public void update() {
        for (CommandBase c : commands) {
            c.update();
        }
    }
    @Override
    public void terminate() {
        for (CommandBase c : commands) {
            c.terminate();
        }
    }
}

//When a command terminates, it initializes the next command in the sequence
class SequentialCommandGroup extends CommandBase {

}

class CommandLoop extends CommandBase {

}