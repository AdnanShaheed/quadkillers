//When you extend ComponentBase, you should override the extended methods, not the original (e.g. override init instead of init)
abstract class ComponentBase {
    public ArrayList<ComponentBase> parents = new ArrayList<ComponentBase>();
    public ArrayList<ComponentBase> children = new ArrayList<ComponentBase>();

    //called once when the command starts
    public void init(float millis, float dt) {}
    
    //called every frame
    public void update(float millis, float dt) {}

    //When this function is called, the command is terminated
    public void terminate(float millis, float dt) {
        //copy this code in ALL implementations
        for (ComponentBase parent : parents) {
            parent.children.remove(this);
        }
        for (ComponentBase child : children) {
            child.terminate();
        }
    }

    public ComponentBase addChild(ComponentBase child) {
        children.add(child);
        return this;
    }
    public ComponentBase attachToParent(ComponentBase parent) {
        parent.addChild(this);
        return this;
    }
    //removes child connection without terminating the child
    public ComponentBase disconnectChild(ComponentBase child) {
        child.parents.remove(this);
        children.remove(child);
        return this;
    }
    //removes parent connection without terminating self
    public ComponentBase disconnectParent(ComponentBase parent) {
        parent.disconnectChild(this);
        return this;
    }
}

//Every component in this group is run at the same time (used most commonly)
class ParallelComponentGroup extends ComponentBase {
    public ParallelComponentGroup() {
        this.init();
    }
    @Override
    public void init() {
        for (ComponentBase c : children) {
            c.init();
        }
    }
    @Override
    public void update() {
        for (ComponentBase c : children) {
            c.update();
        }
    }
    @Override
    public void terminate() {
        for (ComponentBase c : children) {
            c.terminate();
        }
    }
}

//When a command terminates, it initializes the next command in the sequence
class SequentialCommandGroup extends ComponentBase {
    //temporary inefficient implementation of queue

    ComponentBase currentComponent;
    @Override
    public void init() {
        currentComponent = children.get(0);

    }
}

//updates all children at a specified framerate "independent" of the parent
class TimeLoopController extends ComponentBase {
    private float startTime = 0;
    private float refreshRate;

    public TimeLoopController(float refreshRate) {
        new Component(millis(), )
        this.init();
        this.refreshRate = refreshRate;
    }
    @Override
    public void init() {
        startTime = .millis;
    }
    @Override
    public void update() {

    }
}