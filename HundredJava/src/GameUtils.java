import org.jbox2d.collision.AABB;
import org.jbox2d.common.Vec2;
import org.jbox2d.dynamics.Body;
import org.jbox2d.dynamics.World;

/**
 * Contains methods that are implemented differently in Java and Javascript due to differences
 * in the Java and Javascript versions of Box2D.
 * <p/>
 * Specifically, the GameUtils class is replaced by a GameUtils module in Javascript (HundredJavascript).
 */
public class GameUtils {

	public static Body getBodyAtPoint(World world, Vec2 pos) {
		// Create a small box at mouse point
		AABB aabb = new AABB();//new Vec2(v.x - 0.001f, v.y - 0.001f), new Vec2(v.x + 0.001f, v.y + 0.001f));
		aabb.lowerBound.set(pos.x - 0.001f, pos.y - 0.001f);
		aabb.upperBound.set(pos.x + 0.001f, pos.y + 0.001f);
		// Look at the shapes intersecting this box (max.: 10)
		org.jbox2d.collision.Shape[] shapes = world.query(aabb, 10);
		if (shapes == null) {
			return null;  // No body there...
		}
		for (int is = 0; is < shapes.length; is++) {
			org.jbox2d.collision.Shape s = shapes[is];
			if (!s.m_body.isStatic())  // Don't pick static shapes
			{
				// Ensure it is really at this point
				if (s.testPoint(s.m_body.getXForm(), pos)) {
					return s.m_body; // Return the first body found
				}
			}
		}
		return null;
	}


	public static Body[] getBodiesInContact(Body body) {
		return body.getBodiesInContact().toArray(new Body[0]);
	}

	public static boolean isLoaded(AudioPlayer player) {
		return player.getAudioData() != null;
	}

}
