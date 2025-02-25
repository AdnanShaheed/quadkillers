# Guide to Component System Infrastructure
This system is not an idiot-proof design. To avoid overcomplicating the design, only surface level inheritance is used. This means it's up to the programmers to make sure that functionality is consistent over all components.

## Key Rules to Follow
- Only ever extend ComponentBase. If you feel like you have to extend another class (e.g. rocket extends bullet) you should split functionality into different components instead (e.g. BulletMotion component and Shooter component or something)
- Whenever you extend ComponentBase, make sure you reference the original ComponentBase methods you are overriding.
- Treat the `parents` and `children` arraylists as read only. Use the methods for removing or adding to the lists.
- All things should be done from the perspective of the parent. (For example, the `disconnectParent` method goes to the parent object and calls `disconnectChild`)

## Extending Command Base
```
