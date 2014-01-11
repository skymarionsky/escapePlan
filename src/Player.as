package
{
  import nape.geom.Vec2;
  import nape.phys.Body;
  import nape.phys.BodyType;
  
  public class Player extends Body
  {
    public function Player(type:BodyType=null, position:Vec2=null)
    {
      super(type, position);
    }
  }
}