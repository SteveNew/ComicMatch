unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Vcl.FileCtrl, System.Generics.Collections, System.Generics.Defaults, ocv.highgui_c, ocv.core_c, ocv.core.types_c, ocv.imgproc_c,
  ocv.imgproc.types_c, System.IOUtils;

type
  TFileMatchAttr = class(TObject)
    Name: string;
    Fullpath: string;
    Confidence: Double;
    MatchRect: TRect;
  end;

  TmainForm = class(TForm)
    btnLoadTempl: TButton;
    btnSetSearchDir: TButton;
    btnStartMatch: TButton;
    imgTemplate: TImage;
    imgPreview: TImage;
    StatusBar1: TStatusBar;
    fileList: TListBox;
    fileOpenDialog: TFileOpenDialog;
    lblSearchDir: TLabel;
    Label1: TLabel;
    procedure btnLoadTemplClick(Sender: TObject);
    procedure btnSetSearchDirClick(Sender: TObject);
    procedure fileListClick(Sender: TObject);
    procedure fileListData(Control: TWinControl; Index: Integer;
      var Data: string);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnStartMatchClick(Sender: TObject);
  private
    { Private declarations }
    templw, templh: Integer;
    templateFileName: string;
    FilesToMatch: TObjectList<TFileMatchAttr>;
  public
    { Public declarations }
  end;

var
  mainForm: TmainForm;

implementation

{$R *.dfm}

procedure TmainForm.btnLoadTemplClick(Sender: TObject);
begin
  if fileOpenDialog.Execute then
  begin
    templateFileName := fileOpenDialog.FileName;
    imgTemplate.Picture.LoadFromFile(templateFileName);
    templw := imgTemplate.Picture.Width;
    templh := imgTemplate.Picture.Height;
  end;
end;

procedure TmainForm.btnSetSearchDirClick(Sender: TObject);
var
  dir: string;

  procedure ListDirectory(Start: String; List: TObjectList<TFileMatchAttr>);
  var
     Res: TSearchRec;
     EOFound: Integer;
     fma: TFileMatchAttr;
  begin
     EOFound := FindFirst(Start, faDirectory, Res);
     while EOFound = 0 do begin
       if ((Res.Attr and faDirectory) = fadirectory) and
          (Res.Name <> '.') and (Res.Name <> '..') and
          (Res.Name <> Start) then
         begin
           ListDirectory(ExtractFilePath(Start)+Res.Name+'\*.*', List);
         end
         else
           if (Res.Attr = faArchive) and (ExtractFileExt(Res.Name)='.jpg') then //TODO: add .cb?
           begin
             fma := TFileMatchAttr.Create;
             fma.Name := Res.Name;
             fma.Fullpath := ExtractFilePath(Start)+Res.Name;
             fma.Confidence := 0.0;
             List.Add(fma);
           end;
         EOFound:= FindNext(Res);
       end;
     FindClose(Res);
  end;

begin
  if not Assigned(FilesToMatch) then
    FilesToMatch := TObjectList<TFileMatchAttr>.Create(True);
  fileList.Clear;
  if Vcl.FileCtrl.SelectDirectory(
       'Please select directory with files (currently jpg only), you want to do a template match on. Subdirectories are included.',
        TPath.GetPicturesPath, dir, []) then
  begin
    ListDirectory(dir+'\*.jpg', FilesToMatch);
    fileList.Count := FilesToMatch.Count;
    fileList.Invalidate;
    lblSearchDir.Caption := '...in '+FilesToMatch.Count.ToString+' file(s), in: '+ dir;
  end;
end;

procedure TmainForm.btnStartMatchClick(Sender: TObject);
var
  imgSrc, imgTempl, imgMat: pIplImage;
  min, max: double;
  p1, p2: TCvPoint;
  fma: TFileMatchAttr;
  tfile, sfile: pCVChar;
  i: Integer;
begin
  i  := 0;
  tfile := pCVChar(AnsiString(templateFileName));
  imgTempl := cvLoadImage(tfile, CV_LOAD_IMAGE_GRAYSCALE);
  for fma in FilesToMatch do
  begin
    sfile := pCVChar(AnsiString(fma.Fullpath));
    imgSrc := cvLoadImage(sfile, CV_LOAD_IMAGE_GRAYSCALE);
    imgMat := cvCreateImage(CvSize(imgSrc.width-imgTempl.width+1, imgSrc.height-imgTempl.height+1), IPL_DEPTH_32F, 1);
    cvMatchTemplate(imgSrc, imgTempl, imgMat, CV_TM_CCOEFF_NORMED);
    cvMinMaxLoc(imgMat, @min, @max, nil, @p1, nil);
    fma.Confidence := max;
    p2.X := p1.X + templw - 1;
    p2.Y := p1.Y + templh - 1;
    fma.MatchRect := Rect(p1.x, p1.y, p2.x, p2.y);
    inc(i);
    StatusBar1.SimpleText := 'Files processed: '+i.ToString;
  end;
  cvReleaseImage(imgSrc);
  cvReleaseImage(imgTempl);
  cvReleaseImage(imgMat);
  // Sort according to level of confidence - update ListBox
  FilesToMatch.Sort(TComparer<TFileMatchAttr>.Construct(
      function (const L, R: TFileMatchAttr): integer
      begin
         if L.Confidence=R.Confidence then
            Result:=0
         else if L.Confidence > R.Confidence then
            Result:=-1
         else
            Result:=1;
      end)
  );
  fileList.Invalidate;
end;

procedure TmainForm.fileListClick(Sender: TObject);
var
  pic: TPicture;
  bmp: TBitmap;
  R: TRect;
begin
  R := FilesToMatch.Items[fileList.ItemIndex].MatchRect;
  pic := TPicture.Create;
  try
    pic.LoadFromFile(FilesToMatch.Items[fileList.ItemIndex].Fullpath);
    bmp := TBitmap.Create;
    try
      bmp.Width := pic.Width;
      bmp.Height := pic.Height;
      bmp.Canvas.Draw(0, 0, pic.Graphic);
      bmp.Canvas.Pen.Color := clRed;
      bmp.Canvas.Pen.Width := 10;
      bmp.Canvas.Polyline([R.TopLeft, Point(R.Right, R.Top), R.BottomRight, Point(R.Left, R.Bottom), R.TopLeft]);
      imgPreview.Canvas.StretchDraw(Rect(0, 0, imgPreview.Width, imgPreview.Height), bmp);
    finally
      bmp.Free;
    end;
  finally
    pic.Free;
  end;
end;

procedure TmainForm.fileListData(Control: TWinControl; Index: Integer;
  var Data: string);
begin
  // Remember to set style to lbVirtual
  Data := FilesToMatch.Items[Index].Name+' ('+FormatFloat('0.00', FilesToMatch.Items[Index].Confidence*100)+'%)';
end;

procedure TmainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FilesToMatch.Free;
  CanClose := True;
end;

end.
