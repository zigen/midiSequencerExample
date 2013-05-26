import 'dart:html';
import 'dart:math';
import 'dart:web_audio';


CanvasElement canvas;
CanvasRenderingContext2D ctx;
int width =2280 ,keyWidth = 30,startKey=12*3,keys=12*3,height=keys*keyWidth;
int quantize=16,quantizeWidth=50;
int offsetX,offsetY,mouseX,mouseY;
int note,noteOn;
bool dragging = false, noteEdit=false,noteDelete=false;
final List<int> blackList = [1,3,6,8,10];
final List<String> noteName = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"];
DivElement mainWindow = query("#scrollView");
List<noteBox> notes;
  List<double> noteFreq = new List();

var actx = new AudioContext();

void main() {
  estimateFreq();

  canvasInit();

}
void play(MouseEvent  event){
    for(final n in notes)n.scheduling(actx);

}

void canvasInit(){
  mainWindow.onScroll.listen(scrolling);
  canvas = query("#canvas");
  query("#play").onClick.listen(play);
  canvas.width = width;
  canvas.height= height;
  canvas.style.background="white";

  offsetY = -canvas.offsetTop;
  offsetX = -canvas.offsetLeft;
  print('$offsetX,$offsetY' );
  ctx = canvas.getContext("2d");
  canvas.onMouseDown.listen(mouseDown);
  canvas.onMouseMove.listen(mouseMove);
  canvas.onMouseUp.listen(mouseUp);
  notes = new List<noteBox>();
  drawGrid();
}

void canvasDraw(){
    ctx.clearRect(0,0,width,height);
    drawGrid();
    for(final n in notes)n.noteDraw();
    print("audio Context time :${actx.currentTime}");
}

void canvasUpdate(){

}

void scrolling(e){
  print('${mainWindow.scrollTop} ${mainWindow.scrollLeft}');
  offsetY = mainWindow.scrollTop-canvas.offsetTop;
  offsetX = mainWindow.scrollLeft-canvas.offsetLeft;
}

void mouseDown(MouseEvent event){

  mouseX = event.$dom_clientX+offsetX;
  mouseY = event.$dom_clientY+offsetY;
  note = ((height-mouseY)/keyWidth).ceil();
  noteOn = (mouseX/quantizeWidth).ceil()-1;
  noteOn*=quantizeWidth;
  if(!dragging){
   // print("Down!!");
    dragging = true;
    noteDelete=false;
    for(int i=0;i<notes.length;++i)if(notes[i].isOnNote(noteOn,note)){
      notes.removeRange(i,i+1);
      noteDelete = true;
      print("delete");
    }

  }


  print(noteOn);
  print(note);

}
void mouseMove(MouseEvent event){

   if(dragging){
   //  print("Moving!!"); 
 }
}
void mouseUp(MouseEvent event){
  mouseX = event.$dom_clientX+offsetX;
  int noteOff = (mouseX/quantizeWidth).ceil();
  noteOff*=quantizeWidth;
  print(noteDelete);
    if(!noteDelete){
      notes.add(new noteBox(noteOn+0.0,noteOff+0.0,note,startKey));
      print(noteDelete);

    }
  if(dragging){
     //print("Up!");
     dragging = false;

  }
  canvasDraw();
}

void drawGrid(){
  var x,y;
  for(int i=startKey; i<(keys+startKey);++i){  //draw Keys
    if(blackList.contains(i%12))ctx.fillStyle ="rgba(75,75,75,0.6)"; 
    else ctx.fillStyle ="rgba(175,175,175,0.6)"; 
    x = 0;
    print(i);
    y = height-(i+1-startKey)*keyWidth;
    ctx.fillRect(0,y,width,keyWidth);
    ctx.strokeRect(0,y,width,keyWidth);
    ctx.fillStyle="black";
    ctx.fillText("${i}: ${noteName[i%12]}${((i+1)/12).ceil()-1}",x,y+keyWidth/3);
  }
  for(int i=0;i<width/quantizeWidth;++i){
      ctx.beginPath();

      ctx.moveTo(i*quantizeWidth,0);
      ctx.lineTo(i*quantizeWidth,height);
      ctx.stroke();
  }
  print("hello world");
  print('${height}: ${keys*keyWidth}');


}

class noteBox{
  double start,stop,qStart,qStop,frequency;// when note started and stopped , in real and quantized Time
  int note;
  int sKey;
  int x,y,width,height;
  noteBox(double _qStart,double _qStop,[int _note,int _sKey=0,double _frequency]){//Constructor
    //estimated quantized Time and assign!
    qStart = _qStart;
    qStop = _qStop;
    sKey = _sKey;
    if(_note!=null)note = _note;
    if(_frequency!=null)frequency = _frequency;
  }

  
  void noteDraw(){
     ctx.fillRect(qStart,keyWidth*keys-(note*keyWidth),qStop-qStart,keyWidth);
     print('${start} ${stop}');
  }
  bool isOnNote(int _time,int _note){
    return (qStart<=_time&&_time<=qStop&&note==_note);
  }
  void scheduling(var _actx){
    var osc = actx.createOscillator();
    double iT = actx.currentTime;

    osc.connect(actx.destination,0,0);
    osc.frequency.value  = noteFreq[note+sKey];
    print(noteFreq[note]);
    //osc.frequency.value  = 440.0;

    print(note);
    osc.start((qStart/100.0)+iT);
    osc.stop((qStop/100.0)+iT);
    print("note schedulling at${qStart/100.0}");
  }

}


void estimateFreq(){
  double twRoot = 1.0594630943592953;
  noteFreq.add(27.5);
        for(int i=0;i<10;++i){
      noteFreq.add(noteFreq.last*twRoot);
    }

      for(int i=0;i<11;++i){
      noteFreq.add(noteFreq.last*twRoot);
    }

  for(int j=1;j<9;++j){
    noteFreq.add(noteFreq[0]*pow(2,j));
    for(int i=0;i<11;++i){
      noteFreq.add(noteFreq.last*twRoot);
    }


  }
  for(final n in noteFreq)print(n);
  //print(noteFreq.length);

}
