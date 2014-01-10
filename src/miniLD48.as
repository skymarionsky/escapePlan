package
{
  import flash.display.Sprite;
  
  import starling.core.Starling;
  
  [SWF(frameRate=60,backgroundColor="#000000",width=800,height=600)]
  public class miniLD48 extends Sprite
  {
    public function miniLD48()
    {
      var starling:Starling = new Starling(Main, stage);
      starling.start();
    }
  }
}