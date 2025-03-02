import java.util.function.Consumer

public class ComponentInfo {
  float millis; //millis at the time this function is called
  float dt; //deltatime scale factor
  public ComponentInfo(float millis, float dt) {
    this.millis = millis;
    this.dt = dt;
  }
}

public class ComponentBase {
  ComponentBase parent;
  public ArrayList<ComponentBase> children = new ArrayList<ComponentBase>();

  public Consumer<ComponentInfo> startFunc = null;
  public Consumer<ComponentInfo> updateFunc = null;
  public Consumer<ComponentInfo> onDeleteFunc = null;

  public boolean isDeleted = false;

  public ComponentBase() {
  }
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
  public void start(ComponentInfo info) {
    if (startFunc != null) startFunc.accept(info);
  }
  //called every tick
  public void update(ComponentInfo info) {
    if (updateFunc != null) updateFunc.accept(info);
  }
  //when the component is deleted
  public void onDelete(ComponentInfo info) {
    if (onDeleteFunc != null) onDeleteFunc.accept(info);
  }

  //Call this function to stop/finish the command.
  public void delete(ComponentInfo info) {
    isDeleted = true;
    disconnectParent();
    for (ComponentBase child : children) {
      child.delete(info);
    }
  }
  public void addChild(ComponentBase child) {
    this.children.add(child);
    child.parent = this;
  }
  public void addParent(ComponentBase parent) {
    this.parent = parent;
    parent.children.add(this);
  }
  //removes child connection without deleting the child
  public void disconnectChild(ComponentBase child) {
    this.children.remove(child);
    child.parent = null;
  }
  //removes parent connection without deleting self
  public void disconnectParent() {
    this.parent.children.remove(this);
    this.parent = null;
  }
  public SequentialComponent andThen(ComponentBase nextComponent) {
    return new SequentialComponent( new ComponentBase[]{this, nextComponent} );
  }
  public ParallelComponent alongWith(ComponentBase nextComponent) {
    return new ParallelComponent( new ComponentBase[]{this, nextComponent} );
  }
}

//Every component in this group is run at the same time (used most commonly)
public class ParallelComponent extends ComponentBase {
  public ParallelComponent() {
  }
  public ParallelComponent(ComponentBase[] components) {
    children = new ArrayList(components.length);
    for (int i=0; i<components.length; i++) {
      children.add(components[i]);
    }
  }

  public ParallelComponent(ComponentInfo info) {
    this.start(info);
  }
  @Override
  public void start(ComponentInfo info) {
    for (ComponentBase c : children) {
      c.start(info);
    }
  }
  @Override
  public void update(ComponentInfo info) {
    for (ComponentBase c : children) {
      c.update(info);
    }
  }
}

//When a command onDeletes, it startializes the next command in the sequence
public class SequentialComponent extends ComponentBase {
  //when true, the sequential command group will try to start the next component on the next update tick
  private boolean shouldStartNext = false;
  private ComponentBase currentComponent = null;

  //temporary inefficient implementation of queue
  public SequentialComponent() {
  }
  public SequentialComponent(ComponentBase[] components) {
    children = new ArrayList(components.length);
    for (int i=0; i<components.length; i++) {
      children.add(components[i]);
    }
  }
  private void startNext(ComponentInfo info) {
    currentComponent = children.get(0);
    currentComponent.start(info);
  }
  @Override
  public void start(ComponentInfo info) {
    startNext(info);
  }
  @Override
  public void update(ComponentInfo info) {
    if (shouldStartNext) {
      startNext(info);
      shouldStartNext = false;
    } else {
      currentComponent.update(info);
    }
  }
  //whenever a command terminates naturally, it will call the disconnectChild function. This causes the sequential command group to go to the next command.
  @Override
  public void disconnectChild(ComponentBase child) {
    int index = children.indexOf(child);
    if (index == 0) {
      shouldStartNext = true;
    } else {
      children.remove(index);
    }
  }
}

//constants for deltatime calculations
final float DT_MAX = 2;
final float DT_MIN = 0;
final float BASE_TICK_RATE = 60;
//float mspt: How many milliseconds have passed in the same tick
float calcDeltaTime(float mspt) {
  if (mspt < 0) println("calcDeltaTime error: the mspt paramater passed into this function should not be a negative number");
  return constrain(BASE_TICK_RATE*(mspt*0.001), DT_MIN, DT_MAX);
}

//updates all children at a specified tickrate "independent" of the parent
class TimeLoopController extends ComponentBase {
  private float startTime;
  private float lastTime;
  private float mspt; //milliseconds per tick. How many milliseconds pass in one tick. 1000ms * 1second / tickrate
  private int currentTick = 0;
  
  //lerp tick true: If the parent tick rate is not fast enough, this controller simulates fake in-between ticks to fill in the ones that it missed.
  //lerp trick false: This tick rate is limited by the speed of the parent tick rate
  //For example, if this runs at 60tps but parent is at 30tps, it will create two ticks to compensate.
  public boolean lerpTickEnabled = true;

  public TimeLoopController(float tickRate) {
    this.mspt = 1000/tickRate;
  }
  @Override
  public void start(ComponentInfo info) {
    startTime = info.millis;
  }
  @Override
  public void update(ComponentInfo info) {
    if (lerpTickEnabled) {
      //the amount of ticks that have to be simulated
      int tickAmount = floor((info.millis - lastTime) / mspt);
      for (int i=1; i<=tickAmount; i++) {
        //i=0 would give the millis for lastTime, which we do not need to generate a tick for
        //i=tickAmount generates the tick at the info.millis time
        float thisTickMillis = map(i, 0, tickAmount, lastTime, info.millis);
        //time between ticks
        float thisTickDt = calcDeltaTime((info.millis - lastTime)/tickAmount);
        for (ComponentBase child : children) {
          child.update(new ComponentInfo(thisTickMillis, thisTickDt));
        }
      }
      if (tickAmount > 0) lastTime = info.millis;
    } else if (info.millis - lastTime > mspt) {
      float thisTickDt = calcDeltaTime(info.millis - lastTime);

      for (ComponentBase child : children) {
        child.update(new ComponentInfo(info.millis, thisTickDt));
      }
      lastTime = info.millis;
    }
  }
}