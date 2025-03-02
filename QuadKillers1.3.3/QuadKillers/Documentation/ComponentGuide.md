If you are using VSCode, press ctrl+shift+v to view this file



# Guide to Component System Infrastructure
This system is not an idiot-proof design. To avoid overcomplicating the design, only surface level inheritance is used. This means it's up to the programmers to make sure that functionality is consistent over all components.

### General Tips
- Only ever extend ComponentBase. If you feel like you have to extend another class
- Whenever you extend ComponentBase, make sure you reference the original ComponentBase methods you are overriding.
- Treat the `parents` and `children` arraylists as read only. Use the methods for removing or adding to the lists.

# Introducing: The Component
The components use a tree structure with one parent and several children. 
## ComponentInfo
Some functions inside the component accept an object called ComponentInfo. This is simply a container for two floats:
- `millis` = The current time in milliseconds
- `dt` = deltatime scale factor
    - Some ticks may take longer than others based on how much the computer has to process in that tick. This scale factor mitigates that issue. Google "deltatime" for more information.
    - For example, use `pos = pos + vel*dt`

In case I want to add more things I want to pass around, I can easily edit the ComponentInfo object instead of changing the paramaters for every function.

Here is the general life cycle of a component:
### 1. Construction
Create the component object but do not start it yet. There may be some cases where you want to create an object but not start the command until later. 

Construction usually involves setting initial values and attaching children to it. It is as simple as calling the object constructor (each component may have different constructor requirements)

Here is an example of instantiating a ParallelComponent
```java
//the constructor for parallelcomponent accepts an array of children components

//pretend that these components do something
ComponentBase component1 = new ComponentBase();
ComponentBase component2 = new ComponentBase();
ComponentBase component3 = new ComponentBase();

ParallelComponent parallelComponent = new ParallelComponent({component1, component2, component3});
```
### 2. Start
Call the `.start(info)` function **once** when you first start the command. This function CAN be overrided by classes that inherent `ComponentBase`. It accepts a `ComponentInfo` object.
```java
ComponentInfo info = new ComponentInfo(millis(), dt);
parallelComponent.start(info);
```
### 3. Update
Call the `.update(info)` every frame. This function CAN be overrided by classes that inherent `ComponentBase`. It accepts a `ComponentInfo` object.
```java
void draw() {
    //millis and dt are updated every frame
    ComponentInfo info = new ComponentInfo(millis(), dt);
    parallelComponent.update();
}
```

### 4. Delete
Call the `.delete(info)` function to end/terminate the command. It can be used from the outside to interrupt the command early, or it can be used from the inside to mark when the command has finished. It accepts a `ComponentInfo` object.

This function **SHOULD NOT** be overrided by an inheriting class. Instead, override the `onDelete(info)` event that is called whenever this component is deleted.
<!-- ```java
//
class Interrupt extends ComponentBase {
    ComponentBase componentRef;
    InterruptComponent(ComponentBase componentRef) {
        this.componentRef = componentRef;
    }
    @Override
    void start(ComponentInfo info) {

    }
}
class SelfEnding extends ComponentBase {

}
``` -->

# Creating a Component
## Inheriting ComponentBase
Inherit componentbase, create a constructor, and override the `start`, `update`, and `onDelete` functions as needed. Remember: you are not required to override every method, so you only have to override the ones you need.
```java
class MyComponent extends ComponentBase {
    MyComponent() {
        //constructor
    }
    @Override
    void start(ComponentInfo info) {
        //runs once at the start of component
    }
    @Override
    void update(ComponentInfo info) {
        //runs every frame
    }
    @Override
    void onDelete(ComponentInfo info) {
        //runs when component is deleted
    }
}
```
**WARNING:** you should ONLY extend ComponentBase. The component system was created to avoid complicated inheritance trees. If you feel the need to extend a pre-existing component, consider separating mechanics into different components. 

(e.g. rocket extends bullet) you should split functionality into different components instead (e.g. BulletMotion component and Shooter component or something)

## Using ComponentBase Constructor
If you need to create a quick and dirty component, you can use the ComponentBase constructor. Pass in 3 different lambdas for init, update, and onDelete. (Look up java lambdas for more information).
```java 
ComponentBase newComponent = new ComponentBase(
    (info) -> {
        //init
    },
    (info) -> {
        //udpate
    },
    (info) -> {
        //onDelete
    }
)
```
If you don't need some of the functions, you can replace it with a null value.
```java
ComponentBase instant = new ComponentBase(
    (info) -> {
        //init
    },
    null,
    null
);
```
## Accessing External Information
You may notice that the paramaters of the `init`, `update`, and `onDelete` function are seemingly limited because they only accept a `ComponentInfo` object.

Note that when you pass lambdas or override functions, they retain the context they were created in. For example:
```java
class NewComponent extends ComponentBase {
    float myFloat = 10;

    @Override
    void init() {
        //do something with myFloat
        println(myFloat);
    }
}
//myComponent is polymorphed (turned into) a ComponentBase object
ComponentBase myComponent = new MyComponent();
myComponent.init(); //prints 10.0
```
Notice how even though the ComponentBase class DOES NOT have access to myFloat, NewComponent does. When NewComponent is turned into a ComponentBase, it STILL retains the context of NewComponent. Thus, it is still able to access myFloat.

You can use this strategy to provide information to the `init`, `update`, and `onDelete` methods even if their functions can't accept other parameters besides `ComponentInfo`.

## Pass By Reference
You can make use of java's reference behavior. When you pass objects in java, it doesn't give a copy of the object, but rather a reference to that object. This means when you change either of the references, both will update with the new contents.
```java
class Person() {
    public name = "Sam";
}

Person personA = new Person();
Person personB = personA; //personB is a reference to personA
personA.name = "John"; //modifies personA, which also modifies personB
print(personB.name) //outputs John
```
Note that this behavior DOES NOT WORK for primitives, such as `int`, `float`, `bool`. If you would like a reference to a primitive, you can use the capital letter version of these classes, such as `Integer`, `Float`, `Boolean`.

### Using Pass by Reference in Components
Here is an example of using pass by reference with components. Consider using this strategy for accessing outside information. 

```java
class NewComponent extends ComponentBase {
    ArrayList<Float> x;

    public NewComponent(ArrayList<Float> myList) {
        //takes the myList reference passed through the constructor and stores it in the local variable.
        this.x = myList;
    }

    @Override
    void init() {
        //do something with myFloat
        println(x);
    }
}

//create a list
ArrayList<Float> someList = new ArrayList<Float>();
//because arraylist is an object, passing someList into the constructor passes a reference
NewComponent myComponent = new NewComponent(someList);
//turn myComponent into a ComponentBase
ComponentBase myComponentBase = myComponent;
myComponentBase.init(); //prints the arraylist
```

# All Component Classes
## ParallelComponent
It runs all of it's children during it's same tick. Within the same tick, it updates in the order of it's array (goes from first element in array to last)
### Constructor
```java
ParallelComponent() {}
ParallelComponent(ComponentBase[] children) {}
```
- ComponentBase[] children = an array of all the children the command should run (order matters)
### Example:
```java
ParallelComponent parallel = new ParallelComponent({
    new ComponentBase(
        null,
        (info) -> {
            //update function
            println("command 1 " + info.millis);
        },
        null
    ),
    new ComponentBase(
        null,
        (info) -> {
            //update function
            println("command 2 " + info.millis);
        },
        null
    ),
});

void draw() {
    parallel.update();
}

/* output:
command 1 10
command 2 10
command 1 121
command 2 121
command 1 253
command 2 253
*/
```
## SequentialComponent
It runs it's children array from first element to last. It waits for the current component to finish, then it moves to the next one.
### Constructor
```java
SequentialComponent() {}
SequentialComponent(ComponentBase[] children) {}
```
- ComponentBase[] children = an array of all the children the command should run (order matters)
### Example:
```java
class Counter extends ComponentBase {
    private String name;
    private int count = 1;

    public Counter(String name) {
        this.name = name;
    }

    @Override
    void update(ComponentInfo info) {
        println(name + " is up to number " + count);
        if (count == 3) {
            this.delete();
            return;
        } else {
            count ++;
        }
    }
}

SequentialComponent sequentialComponent = new SequentialComponent({
    new Counter("component 1"),
    new Counter("component 2"),
    new Counter("component 3")
});

void draw() {
    sequentialComponent.update();
}

/* output:
component 1 is up to number 1
component 1 is up to number 2
component 1 is up to number 3
component 2 is up to number 1
component 2 is up to number 2
component 2 is up to number 3
component 3 is up to number 1
component 3 is up to number 2
component 3 is up to number 3
*/
```

## TimeLoopController
It runs it's child components in parallel. It simulates a tickrate that is indepent of it's parent tickrate. For example, if you wanted a particle system that only runs 30fps instead of the game's 100fps, you can use this.
### Constructors
```java
TimeLoopController(int tickRate) {...}
TimeLoopController(int tickRate, ComponentBase component) {...}
```
- float tickRate = the rate you want the timeloopcontroller to run at
- component = the sub component that it runs every frame