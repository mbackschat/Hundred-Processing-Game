GameUtilsModule = function() {

  var ContactEdge = Box2D.Dynamics.Contacts.b2ContactEdge;

  var scope = {

    getBodyAtPoint: function(world, vec) {
      var aabb = new AABB();
      aabb.lowerBound.Set(vec.x - 0.001, vec.y - 0.001);
      aabb.upperBound.Set(vec.x + 0.001, vec.y + 0.001);

      // Query the world for overlapping shapes.
      var selectedBody = null;
      var callback = function getBodyCB(fixture) {
        if (fixture.GetBody().GetType() != Body.b2_staticBody) {
          if (fixture.GetShape().TestPoint(fixture.GetBody().GetTransform(), vec)) {
            selectedBody = fixture.GetBody();
            return false;
          }
        }
        return true;
      };
      world.QueryAABB(callback, aabb);
      return selectedBody;
    },

    /*
World.prototype.query = function(aabb, maxBodies) {
  var __this = this;
  var selectedBodies = new Array();
  // See https://github.com/kevmoo/box2dWeb/blob/master/demo.html: getBodyCB
  var callback = function(fixture) {
    if(fixture.GetBody().GetType() != Body.b2_staticBody) {
      selectedBodies.push(fixture.GetShape());
      return false;
    }
    else
      return true;
  };
  this.QueryAABB(callback, aabb);
  return selectedBodies;
}

// Missing AABB constructor
function AABB (lb,ub) {
      this.lowerBound = lb;
      this.upperBound = ub;
}
*/


    getBodiesInContact: function(body) {
      var bodies = [];
      var contact;
      for (contact = body.GetContactList(); contact != null;) {

        // Ignore this case, but about also because contactEdges have no getNext
        if (contact instanceof ContactEdge) {
          if (contact.contact.IsTouching()) {
            bodies.push(contact.other);
          }
          contact = contact.next;
        } else if (contact.IsTouching()) {
          var b1 = contact.GetFixtureA.GetBody();
          if (body != b1)
            bodies.push(b1);
          var b2 = contact.GetFixtureB.GetBody();
          if (body != b2)
            bodies.push(b2);
          contact = contact.GetNext();
        }
      }
      return bodies;
    },


    isLoaded: function(audio) {
      return audio.getLengthMs() > 0;
    }


  }
  return scope;

}

GameUtils = new GameUtilsModule();
