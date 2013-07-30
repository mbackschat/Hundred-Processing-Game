Body.prototype.getUserData = Body.prototype.GetUserData;
Body.prototype.setUserData = Body.prototype.SetUserData;
Body.prototype.setPositionUnsafe = Body.prototype.SetPositionUnsafe;
Body.prototype.getNext = Body.prototype.GetNext
World.prototype.getBodyList = World.prototype.GetBodyList
World.prototype.destroyBody = World.prototype.DestroyBody;


//
// Changed API:
// Shape stuff: jbox2d from 2008 has body -> shape; box2dweb and new jbox2d has body -> fixture -> shape
//

var current_fixture;  // Bad hack: keep track of current iteration

Body.prototype.getShapeList = function() {
  current_fixture = this.GetFixtureList();
  if (current_fixture != null) {
    return current_fixture.GetShape();
  }
  else {
    return null;
  }
}
CircleShape.prototype.getNext = function() {
  if (current_fixture == null)
    return null;

  current_fixture = current_fixture.m_next;

  if (current_fixture != null)
    return current_fixture.GetShape();
  else
    return null;
}
PolygonShape.prototype.getNext = CircleShape.prototype.getNext;

CircleShape.prototype.getType = function() {
  return 1;  // CIRCLE_SHAPE
} 
PolygonShape.prototype.getType = function() {
  return 2;  // POLYGON_SHAPE
} 

var ShapeType = {};
ShapeType.CIRCLE_SHAPE = 1;
ShapeType.POLYGON_SHAPE = 2;

CircleShape.prototype.getRadius = CircleShape.prototype.GetRadius;


