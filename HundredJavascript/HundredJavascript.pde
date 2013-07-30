import org.jbox2d.collision.CircleShape;
import org.jbox2d.collision.Shape;
import org.jbox2d.collision.ShapeType;
import org.jbox2d.common.Vec2;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.World;
import org.jbox2d.p5.Physics;
import processing.core.PApplet;
import processing.core.PImage;

  static final int FPS = 60;
  static final int SCREEN_WIDTH = 400;
  static final int SCREEN_HEIGHT = 400;
  static final float INITIAL_RADIUS = min(SCREEN_HEIGHT, SCREEN_WIDTH) / 30.0f;
  static final float MAX_RADIUS = min(SCREEN_HEIGHT, SCREEN_WIDTH) / 4;
  static final float RADIUS_INCR = (MAX_RADIUS - INITIAL_RADIUS) / (FPS * 1.5f);

  static final float LEVEL1_CIRCLE_SPEED = min(SCREEN_HEIGHT, SCREEN_WIDTH) / 220.0f;
  static final float INCR_CIRCLE_SPEED = LEVEL1_CIRCLE_SPEED / 15;
  static final int INITIAL_CIRCLES = 3;

  private final String CIRCLE_TAG = "circle";
  private final String PART_OF_COLLISION_TAG = "collision";

  static int TARGET_VOLUME = 100;
  private int points;
  private int level;
  private int lives;

  static final int BONUS_LEVEL = 3;
  private boolean bonusLive;

  private final static int GM_CLICK_TO_START = 0;
  private final static int GM_DURING_GAME = 1;
  private final static int GM_END_OF_LEVEL = 2;
  private final static int GM_LEVEL_FAILED = 3;
  private final static int GM_END_OF_GAME = 4;
  private int gameMode = GM_CLICK_TO_START;

  // Game Level data
  private Physics physics;
  private int numberOfCircles;
  private Body[] circleBody;
  private float circleSpeed;
  private float circleRadius;

  private Body bodyAtPoint;

  private Maxim maxim;
  private AudioPlayer pumpSound;
  private AudioPlayer failedSound;
  private PImage backgroundImage;

  public void setup() {
    size(SCREEN_WIDTH, SCREEN_HEIGHT);
    frameRate(FPS);  // jbox2d is optimized for 60 hz

    backgroundImage = loadImage("background.png");

    maxim = new Maxim(this);
    pumpSound = maxim.loadFile("pump.wav");
    pumpSound.setLooping(false);
    pumpSound.volume(1.0f);
    failedSound = maxim.loadFile("failed.wav");
    failedSound.setLooping(false);
    failedSound.volume(1.0f);

    initGame();
  }

  public void mousePressed() {
    if (gameMode == GM_LEVEL_FAILED) {
      lives--;
    } else if (gameMode == GM_END_OF_LEVEL) {
      level++;
    }

    if (gameMode == GM_CLICK_TO_START || gameMode == GM_END_OF_LEVEL || gameMode == GM_LEVEL_FAILED) {
      gameMode = GM_DURING_GAME;
      initLevel();
      initScene();
    } else if (gameMode == GM_END_OF_GAME) {
      initGame();
      gameMode = GM_CLICK_TO_START;
    }
  }

  private void initGame() {
    lives = 3 - 1;
    level = 1;
  }

  void initLevel() {
    bodyAtPoint = null;
    points = 0;
    numberOfCircles = INITIAL_CIRCLES + (level - 1) / 2;
    circleSpeed = LEVEL1_CIRCLE_SPEED + (level / 2 - 1) * INCR_CIRCLE_SPEED;
    circleRadius = INITIAL_RADIUS;
  }

  void initScene() {
    /**
     * Set up a physics world. This takes the following parameters:
     *
     * parent The PApplet this physics world should use
     * gravX The x component of gravity, in meters/sec^2
     * gravY The y component of gravity, in meters/sec^2
     * screenAABBWidth The world's width, in pixels - should be significantly larger than the area you intend to use
     * screenAABBHeight The world's height, in pixels - should be significantly larger than the area you intend to use
     * borderBoxWidth The containing box's width - should be smaller than the world width, so that no object can escape
     * borderBoxHeight The containing box's height - should be smaller than the world height, so that no object can escape
     * pixelsPerMeter Pixels per physical meter
     */
    if (physics != null) {
      destroyWorld(physics, width, height,
                   width, height);
      physics.unsetCustomRenderingMethod();
    } else {
      physics = new Physics(this, width, height,
                            0, 0, // gravity
                            width * 2, height * 2,
                            width, height,
                            100   // pixels/m, TODO
      );
    }
    // this overrides the debug render of the physics engine
    // with the method myCustomRenderer
    // comment out to use the debug renderer
    // (currently broken in JS)
    physics.setCustomRenderingMethod(this, "myCustomRenderer");

    // adding random circles
    physics.setDensity(1);
    physics.setFriction(0);
    physics.setRestitution(0.5f);
    circleBody = new Body[numberOfCircles];
    for (int i = 0; i < numberOfCircles; i++) {
      final Body body = physics.createCircle( // In Screen coordinates!
                                              random(width), random(height), circleRadius);
      final float brightness = random(20, 200);
      final int col = color(brightness, brightness, brightness);
      final UserData userData = new UserData(CIRCLE_TAG, col);
      body.setUserData(userData);
      final float randomAngle = random(2 * PI);
      body.setLinearVelocity(
          new Vec2(circleSpeed * cos(randomAngle), circleSpeed * sin(randomAngle))
      );
      circleBody[i] = body;
    }
  }

  private void destroyWorld(Physics physics, int screenW, int screenH, int borderBoxWidth, int borderBoxHeight) {
    Body body;
    Body next;
    for (body = physics.getWorld().getBodyList(); body != null; body = next) {
      next = body.getNext();
      physics.getWorld().destroyBody(body);
    }
    physics.setDensity(0.0f);
    physics.createHollowBox(screenW * 0.5f, screenH * 0.5f, borderBoxWidth, borderBoxHeight, 10.0f);
  }

  public void draw() {
    if (backgroundImage != null) {
      image(backgroundImage, 0, 0, width, height);
    } else {
      background(255);
    }

    switch (gameMode) {
      case GM_CLICK_TO_START: {
        textAlign(CENTER);
        final int x = width / 2;
        fill(0);
        text("Grow the balls to reach an overall size of 100 points", x, height / 2);
        text("by touching the balls with the mouse.", x, height / 2 + 20);
        text("Do not grow balls when they touch each other.", x, height / 2 + 40);
        text("Click to start.", x, height / 2 + 60);
      }
      break;
      case GM_DURING_GAME: {
        drawScore();
        updateCircles();
      }
      break;
      case GM_END_OF_LEVEL: {
        drawScore();

        fill(20, 240, 20);
        textAlign(CENTER);
        final int x = width / 2;
        text("End of Level.", x, height / 2);
        if (bonusLive) {
          text("You earned a Bonus Live!", x, height / 2 + 30);
        }
        text("Click to enter next level.", x, height / 2 + 75);
      }
      break;
      case GM_LEVEL_FAILED: {
        drawScore();

        fill(240, 20, 20);
        textAlign(CENTER);
        final int x = width / 2;
        text("Level failed.", x, height / 2);
        text("Click to enter same level again.", x, height / 2 + 75);
      }
      break;
      case GM_END_OF_GAME: {
        drawScore();

        fill(0);
        textAlign(CENTER);
        final int x = width / 2;
        text("Game over.", x, height / 2);
        text("Click to restart.", x, height / 2 + 50);
      }
      break;
    }
  }

  private void drawScore() {
    textAlign(LEFT);
    fill(0);
    text("Points: " + points, 20, 20);
    text("Level: " + level, 20, 35);
    text("Lives: " + lives, 20, 50);
  }

  void updateCircles() {
    bodyAtPoint = GameUtils.getBodyAtPoint(physics.getWorld(), physics.screenToWorld(mouseX, mouseY));

    for (int i = 0; i < numberOfCircles; i++) {

      final Body body = circleBody[i];
      // keep moving circles at a constant speed
      final Vec2 velocity = body.getLinearVelocity();
      final float speed = sqrt(velocity.lengthSquared());  // length() does not work in JS
      final float ratio = circleSpeed / speed;
      body.setLinearVelocity(velocity.mul(ratio));

      if (bodyAtPoint == body) {
        boolean failed = false;
        final Body bodiesInContact[] = GameUtils.getBodiesInContact(body);
        for (Body body1 : bodiesInContact) {
          final UserData userData = (UserData) body1.getUserData();
          if (userData != null && CIRCLE_TAG.equals(userData.tag)) {
            failed = true;
            userData.tag = PART_OF_COLLISION_TAG;
          }
        }
        if (failed) {
          final UserData userData = (UserData) body.getUserData();
          userData.tag = PART_OF_COLLISION_TAG;
          failLevel();
          break;
        }

        // circle? let's find its center and radius and draw an ellipse
        CircleShape circle = (CircleShape) body.getShapeList();
        if (physics.worldToScreen(circle.m_radius) <= MAX_RADIUS) {
          circle.m_radius = circle.m_radius + physics.screenToWorld(RADIUS_INCR);
          if (GameUtils.isLoaded(pumpSound)) {
            pumpSound.cue(0);
            pumpSound.play();
          }

          points++;
          if (points >= TARGET_VOLUME) {
            endLevel();
            break;
          }
        }
      }
    }

  }

  private void failLevel() {
    gameMode = lives > 0 ? GM_LEVEL_FAILED : GM_END_OF_GAME;
    if (GameUtils.isLoaded(failedSound)) {
      failedSound.cue(0);
      failedSound.play();
    }
  }

  private void endLevel() {
    gameMode = GM_END_OF_LEVEL;
    bonusLive = level % BONUS_LEVEL == 0;
    if (bonusLive) {
      lives++;
    }
  }


  // This function renders the physics scene.
  // this can either be called automatically from the physics
  // engine if we enable it as a custom renderer or
  // we can call it from draw
  public void myCustomRenderer(World world) {
    stroke(100);

    // Iterate through the bodies
    for (Body body = world.getBodyList(); body != null; body = body.getNext()) {
      if (gameMode == GM_DURING_GAME) {
        if (body == bodyAtPoint) {
          fill(50, 50, 200);
        } else {
          final UserData userData = (UserData) body.getUserData();
          if (userData != null) {
            fill(userData.col);
          } else {
            fill(0);
          }
        }
      } else if (body.getUserData() != null &&
                 PART_OF_COLLISION_TAG.equals(((UserData) body.getUserData()).tag)) {
        fill(200, 10, 10, 128);
      } else {
        fill(128, 128);
      }

      // Iterate through the shapes of the body
      for (Shape shape = body.getShapeList(); shape != null; shape = shape.getNext()) {

        // Find out the shape type
        if (shape.getType() == ShapeType.CIRCLE_SHAPE) {

          // circle? let's find its center and radius and draw an ellipse
          CircleShape circle = (CircleShape) shape;
          Vec2 pos = physics.worldToScreen(body.getWorldCenter());
          float radius = physics.worldToScreen(circle.getRadius());
          ellipseMode(CENTER);
          ellipse(pos.x, pos.y, radius * 2, radius * 2);

//          // TODO DebugDraw
//          // we'll add one more line to see how it rotates
//          line(pos.x, pos.y, pos.x + radius * cos(-body.getAngle()), pos.y + radius * sin(-body.getAngle()));
        }
      }
    }
  }


class UserData {
  String tag;
  int col;

  UserData(String tag, int col) {
    this.col = col;
    this.tag = tag;
  }
}
