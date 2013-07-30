This is the Java variant of the Game. It runs in any Java IDE like Eclipse and IntelliJ IDEA.

Limitation of the Java variant: the applet doesn't find the sound files.

Dependencies included: box2dwrap (including box2d), maxim, processing-core

I use it for main development. When it works here, I copy the source code of Game.java and GameUtils.java to the other projects like HundredDesktop. Here, only 2 modifications are required:

- Game.java => HundredDesktop.pde
	Remove line "public class Game extends PApplet {" and corresponding "}"

- GameUtils.java => GameUtils.pde
	Add "static" to class definition: "public static class GameUtils {"

You can copy HundredDesktop.pde to HundredJavascript.pde without modifications.
