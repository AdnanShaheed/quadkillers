import java.util.function.Consumer;

public class ComponentInfo {
    float millis; //millis at the time this function is called
    float dt; //deltatime scale factor
    public ComponentInfo(ComponentInfo info) {
        this.millis = millis;
        this.dt = dt;
    }
}

abstract class ComponentBase {
    ComponentBase parent;
    public ArrayList<ComponentBase> children = new ArrayList<ComponentBase>();

    public Consumer<ComponentInfo> startFunc = null;
    public Consumer<ComponentInfo> updateFunc = null;
    public Consumer<ComponentInfo> onDeleteFunc = null;

    public ComponentBase() {}

    //used for quick component creation
    public ComponentBase(
        Consumer<ComponentInfo> startFunc,
        Consumer<ComponentInfo> updateFunc,
        Consumer<ComponentInfo> onDeleteFunc
    ) {
        this.startFunc = startFunc;
        this.updateFunc = updateFunc;
        this.onDeleteFunc = onDeleteFunc;
    }

    //called once when the component starts
    public ComponentBase start(ComponentInfo info) {
        if (startFunc != null) startFunc.accept(info);
        return this;
    }
    //called every tick
    public ComponentBase update(ComponentInfo info) {
        if (updateFunc != null) updateFunc.accept(info);
        return this;
    }
    //when the component is deleted
    public ComponentBase onDelete(ComponentInfo info) {
        if (onDeleteFunc != null) onDeleteFunc.accept(info);
        return this;
    }

    //Call this function to stop/finish the command.
    public void delete() {
        disconnectParent();
        for (ComponentBase child : children) {
            child.delete();
        }
    }

    public ComponentBase addChild(ComponentBase child) {
        this.children.add(child);
        child.parent = this;
        return this;
    }

    // public ComponentBase addChildren(ComponentBase[] newChildren) {
    //     this.children.addAll(newChildren);
    //     for (ComponentBase child : newChildren) {
    //         child.parent = this;
    //     }
    //     return this;
    // }
    public ComponentBase addParent(ComponentBase parent) {
        this.parent = parent;
        parent.children.add(this);
        return this;
    }
    //removes child connection without deleting the child
    public ComponentBase disconnectChild(ComponentBase child) {
        this.children.remove(child);
        child.parent = null;
        return this;
    }
    //removes parent connection without deleting self
    public ComponentBase disconnectParent() {
        this.parent.children.remove(this);
        this.parent = null;
        return this;
    }
    public ComponentBase andThen(ComponentBase nextComponent) {
        return new SequentialCommandGroup( new ComponentBase[]{this, nextComponent} );
    }
    public ComponentBase alongWith(ComponentBase nextComponent) {
        return new ParallelComponentGroup( new ComponentBase[]{this, nextComponent} );
    }
}

//Every component in this group is run at the same time (used most commonly)
class ParallelComponentGroup extends ComponentBase {
    public ParallelComponentGroup() {}
    public ParallelComponentGroup(ComponentBase[] components) {
        children = new ArrayList(components.length);
        for (int i=0; i<components.length; i++) {
            children.add(components[i]);
        }
    }

    public ParallelComponentGroup(ComponentInfo info) {
        this.start(info);
    }
    @Override
    public ComponentBase start(ComponentInfo info) {
        for (ComponentBase c : children) {
            c.start(info);
        }
        return this;
    }
    @Override
    public ComponentBase update(ComponentInfo info) {
        for (ComponentBase c : children) {
            c.update(info);
        }
        return this;
    }
    @Override
    public ComponentBase onDelete(ComponentInfo info) {
        for (ComponentBase c : children) {
            c.onDelete(info);
        }
        return this;
    }
}

//When a command onDeletes, it startializes the next command in the sequence
class SequentialCommandGroup extends ComponentBase {
    //temporary inefficient implementation of queue
    public SequentialCommandGroup() {}
    public SequentialCommandGroup(ComponentBase[] components) {
        children = new ArrayList(components.length);
        for (int i=0; i<components.length; i++) {
            children.add(components[i]);
        }
    }

    ComponentBase currentComponent;
    @Override
    public ComponentBase start(ComponentInfo info) {
        currentComponent = children.get(0);
        return this;
    }
    @Override
    public ComponentBase disconnectChild(ComponentBase child) {
        return this;
    }
}
 
//updates all children at a specified tickrate "independent" of the parent
class TimeLoopController extends ComponentBase {
    private final float DT_MAX = 2;
    private final float DT_MIN = 0;
    private final float BASE_TICK_RATE = 60;

    private float startTime;
    private float lastTime;
    private float mspt; //milliseconds per tick. How many milliseconds pass in one tick. 1000ms * 1second / tickrate
    private int currentTick = 0;
    
    private final float calcDeltaTime(float lastTime, float currentTime) {
        if (lastTime - currentTime < 0) print("Error you switched lastTime and currentTime");
        return constrain(BASE_TICK_RATE*((currentTime*0.001 - lastTime)), DT_MIN, DT_MAX);
    }

    //lerp tick true: If the parent tick rate is not fast enough, this controller simulates fake in-between ticks to fill in the ones that it missed.
    //lerp trick false: This tick rate is limited by the speed of the parent tick rate
    //For example, if this runs at 60tps but parent is at 30tps, it will create two ticks to compensate.
    public boolean lerpTickEnabled = false;

    public TimeLoopController(float mspt) {
        this.mspt = mspt;
    }
    @Override
    public ComponentBase start(ComponentInfo info) {
        startTime = millis;
        return this;
    }
    @Override
    public ComponentBase update(ComponentInfo info) {
        if (lerpTickEnabled) {
            //the amount of ticks that have to be simulated
            int tickAmount = floor((millis - lastTime) / mspt);
            for (int i=1; i<tickAmount; i++) {
                float thisTickMillis = map(i, 0, tickAmount, lastTime, millis);
                //time between ticks
                float deltaTime = map(1, 0, 3, 0, millis - lastTime);
                float thisTickDt = calcDeltaTime(0, deltaTime);
                for (ComponentBase child : children) {
                    child.update(info);
                }
            }
            if (tickAmount > 0) lastTime = millis;
        } else if (millis - lastTime > mspt) {
            //deltatime is 
            float thisTickDt = calcDeltaTime(lastTime, millis);

            for (ComponentBase child : children) {
                child.update(info);
            }
            lastTime = millis;
        }

        return this;
    }
}