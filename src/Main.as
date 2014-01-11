package
{
  import flash.display.BitmapData;
  import flash.events.Event;
  import flash.geom.Matrix;
  
  import nape.callbacks.CbType;
  import nape.geom.Vec2;
  import nape.phys.Body;
  import nape.phys.BodyType;
  import nape.phys.Material;
  import nape.shape.Circle;
  import nape.shape.Polygon;
  import nape.space.Space;
  import nape.util.Debug;
  import nape.util.ShapeDebug;
  
  import starling.core.Starling;
  import starling.display.Image;
  import starling.display.Sprite;
  import starling.textures.Texture;
  
  public class Main extends Sprite
  {
    private const SLICE_HEIGHT:int = 1000;
    private const SLICE_WIDTH:int = 30;
    private const INTERVAL:Number = 1/60;
    private const SPAWN_POSITION:Vec2 = new Vec2(800/2+100,200);
    
    private var _space:Space;
    private var _characterCbType:CbType;
    private var _character:Body;
    private var _hills:Sprite;
    
    private var _groundTexture:Texture;
    private var _slicesCreated:int;
    private var _currentAmplitude:Number;
    private var _slicesInCurrentHill:int;
    private var _indexSliceInCurrentHill:int;
    private var _currentYPoint:Number = 600;
    private var _slices:Vector.<Body>;
    private var _sliceVectorConstructor:Vector.<Vec2>;
    
    private var _debug:Debug;
    
    public function Main():void
    {
      // initialize nape space
      _space = new Space(new Vec2(0, 2000));
      
      _hills = new Sprite();
      addChild(_hills);
      
      _slices = new Vector.<Body>();
      
      // generate a rectangle made of Vec2
      _sliceVectorConstructor = new Vector.<Vec2>();
      _sliceVectorConstructor.push(new Vec2(0, SLICE_HEIGHT));
      _sliceVectorConstructor.push(new Vec2(0, 0));
      _sliceVectorConstructor.push(new Vec2(SLICE_WIDTH, 0));
      _sliceVectorConstructor.push(new Vec2(SLICE_WIDTH, SLICE_HEIGHT));
      
      // create the texture of the ground
      _groundTexture = Texture.fromBitmapData(new BitmapData(SLICE_WIDTH, SLICE_HEIGHT, false, 0xFFFFFF));
      
      // fill the stage with slices of hills
      for(var i:int = 0; i < escapePlan.stage.stageWidth / SLICE_WIDTH*1.5; i++){
        createSlice();
      }
      
      // add character
      _character = new Body(BodyType.DYNAMIC, SPAWN_POSITION);
      _character.space = _space;
      var material:Material = new Material(0.2, 1.0, 2.0, 1.0, 1.0);
      _character.shapes.add(new Circle(50, null, material));
      var texture:Texture = Texture.fromBitmapData(new BitmapData(50, 100, false, 0xccaaff));
      var image:Image = new Image(texture);
      _character.userData.graphic = image;
      image.pivotY += 50;
      var func:Function = playerUpdate;
      _character.userData.onUpdate = func;
      addChild(_character.userData.graphic);
      
      // nape debug
      /*
      _debug = new ShapeDebug(800, 480, 0x33333333);
      _debug.draw(_space);
      var MovieClipDebug:flash.display.MovieClip = new flash.display.MovieClip();
      MovieClipDebug.addChild(_debug.display);
      Starling.current.nativeOverlay.addChild(MovieClipDebug);
      */
      
      startSimulation();
      
    }
    
    private function playerUpdate(b:Body):void
    {
      if(b.velocity.x < 300)
        b.velocity.x = 300;
    }
    
    private function createSlice():void
    {
      // every time a new hill has to be created this algorithm predicts where the slice will be positioned
      if(_indexSliceInCurrentHill >= _slicesInCurrentHill){
        _slicesInCurrentHill = Math.random()*40+10;
        _currentAmplitude = Math.random()*60-20;
        _indexSliceInCurrentHill = 0;
      }
      
      // calculate the position of the next slice
      var nextYPoint:Number = _currentYPoint + (Math.sin(((Math.PI/_slicesInCurrentHill)*_indexSliceInCurrentHill))*_currentAmplitude);
      
      _sliceVectorConstructor[2].y = nextYPoint - _currentYPoint;
      
      var slicePolygon:Polygon = new Polygon(_sliceVectorConstructor);
      var sliceBody:Body = new Body(BodyType.STATIC);
      sliceBody.shapes.add(slicePolygon);
      sliceBody.position.x = _slicesCreated * SLICE_WIDTH;
      sliceBody.position.y = _currentYPoint;
      sliceBody.space = _space;
      
      var image:Image = new Image(_groundTexture);
      sliceBody.userData.graphic = image;
      _hills.addChild(image);
      
      // skew and position the image with a matrix
      var matrix:Matrix = image.transformationMatrix;
      matrix.translate(sliceBody.position.x, sliceBody.position.y);
      matrix.a = 1.04;
      matrix.b = (nextYPoint-_currentYPoint)/SLICE_WIDTH;
      image.transformationMatrix.copyFrom(matrix);
      
      _slicesCreated++;
      _indexSliceInCurrentHill++;
      _currentYPoint = nextYPoint;
      
      _slices.push(sliceBody);
      
    }
    
    private function startSimulation():void
    {
      addEventListener(Event.ENTER_FRAME, loop);
    }
    
    private function loop():void
    {
      _space.liveBodies.foreach(updateGraphics);
      //_debug.clear();
      _space.step(INTERVAL);
      //_debug.draw(_space);
      //_debug.flush();
      checkHills();
      panForeground();
    }
    
    private function updateGraphics(b:Body):void
    {
        b.userData.graphic.x = b.position.x;
        b.userData.graphic.y = b.position.y;
        if(b.userData.onUpdate !== null)
          b.userData.onUpdate(b);
        //b.userData.graphic.rotation = b.rotation;
    }
    
    private function checkHills():void
    {
      for(var i:int = 0; i<_slices.length; i++){
        if(_character.position.x - _slices[i].position.x > 600){
          _space.bodies.remove(_slices[i]);
          if(_slices[i].userData.graphic.parent){
            _slices[i].userData.graphic.parent.removeChild(_slices[i].userData.graphic);
          }
          _slices.splice(i,1);
          i--;
          createSlice();
        }
        else{
          break;
        }
      }
    }
    
    private function panForeground():void
    {
      //_character.position.x += 0.1;
      this.x = escapePlan.stage.stageWidth/2 - _character.position.x;
      this.y = escapePlan.stage.stageHeight/2 - _character.position.y;
    }
    
  }
}