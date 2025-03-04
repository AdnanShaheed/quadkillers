//global values that are used
Player player;
ArrayList<Entity> entities = new ArrayList<Entity>();
TimeLoopController gameLoop;

void gameSetup() {
    gameLoop = new TimeLoopController(60, new ParallelComponent({
        new ComponentBase(
            null,
            ()-> {
                pushMatrix();   
            }, 
            null),
        new GameCamera()
    }));
}

class GameGlobals {
    // Player player;
}

class GameCamera extends ComponentBase {
    PVector camPos = new PVector(200, 200);
    float camScale = 1;
    float SCALE_LERP_FACTOR = 0.05;
    float POS_LERP_FACTOR = 0.05;
    float MARGIN = 300;

    @Override
    void update(ComponentInfo info) {
        
        PVector v1.x = pos1.copy();
        PVector v2.x = pos2.copy();
        float scaleX = width / abs(v1.x + MARGIN - v2.x + MARGIN);
        float scaleY = width / abs(v1.y + MARGIN - v2.y + MARGIN);
        camScale = lerp(camScale, min(scaleX, scaleY), SCALE_LERP_FACTOR*info.dt);
        camPos.lerp(PVector.lerp(a, b, 0.5), POS_LERP_FACTOR*info.dt);
    }

}