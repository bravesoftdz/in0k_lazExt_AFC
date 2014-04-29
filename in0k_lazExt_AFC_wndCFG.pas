unit in0k_lazExt_AFC_wndCFG;

{$mode objfpc}{$H+}

interface

uses Classes, Forms, StdCtrls,
  in0k_lazExt_AFC, in0k_lazExt_AFC_wndDBG;

const
 cUiWND_in0k_lazExt_AFC_CFG_Caption='Configure "Auto Fold Comments" tool';

type

 {inkDoc> "Окно" конфигурации
   настройка работы `tIn0k_lazExt_AFC`
 <inkDoc}

 { TuiWND_in0k_lazExt_AFC_CFG }

 TuiWND_in0k_lazExt_AFC_CFG = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
  private
    procedure _Settings2Form;
    procedure _form2Settings;
  private
    procedure onCreate_setTexts;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

var uiWND_in0k_lazExt_AFC_CFG:TuiWND_in0k_lazExt_AFC_CFG;

implementation

{$R *.lfm}

const
  cUiWND_in0k_lazExt_AFC_CFG_texts_L01='Use "Auto Fold Comments" tool.';
  cUiWND_in0k_lazExt_AFC_CFG_texts_L02='Settings';

  cUiWND_in0k_lazExt_AFC_CFG_texts_L03='fold All comments';
  cUiWND_in0k_lazExt_AFC_CFG_texts_L04='fold selectively';

  cUiWND_in0k_lazExt_AFC_CFG_texts_L05='use the "search list"';
  cUiWND_in0k_lazExt_AFC_CFG_texts_L06='fold "Hint from Comment"';


  cUiWND_in0k_lazExt_AFC_CFG_texts_B01='Save';
  cUiWND_in0k_lazExt_AFC_CFG_texts_B02='set Default and Save';
  cUiWND_in0k_lazExt_AFC_CFG_texts_B03='deBug window';

constructor TuiWND_in0k_lazExt_AFC_CFG.Create(TheOwner:TComponent);
begin
    inherited;
    onCreate_setTexts;
    //---
    CheckBox1.Checked:=FALSE;
    RadioButton1.Checked:=TRUE;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG.onCreate_setTexts;
begin
    self.Caption:=cUiWND_in0k_lazExt_AFC_CFG_Caption;
    //---
    CheckBox1.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_L01;
    GroupBox1.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_L02;
    //---
    RadioButton1.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_L03;
    RadioButton2.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_L04;
       CheckBox2.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_L05;
       CheckBox3.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_L06;
    //---
    Button1.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_B01;
    Button2.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_B02;
    Button3.Caption:=cUiWND_in0k_lazExt_AFC_CFG_texts_B03;
end;

//------------------------------------------------------------------------------

procedure TuiWND_in0k_lazExt_AFC_CFG.FormCreate(Sender: TObject);
begin
   _Settings2Form;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG.FormClose(Sender:TObject; var CloseAction: TCloseAction);
begin
    CloseAction:=caFree;
    uiWND_in0k_lazExt_AFC_CFG:=nil;
end;

//------------------------------------------------------------------------------

procedure TuiWND_in0k_lazExt_AFC_CFG._Settings2Form;
begin
    if Assigned(In0k_lazExt_AFC.In0k_lazExt_AFC) then
        with In0k_lazExt_AFC.In0k_lazExt_AFC do begin
            AutoFoldComments_NAMEs_get(memo1.Lines);
            CheckBox2.Checked:=AutoFoldComments_LST;
            CheckBox3.Checked:=AutoFoldComments_HFC;
            if AutoFoldComments_ALL
            then RadioButton1.Checked:=true
            else RadioButton2.Checked:=true;
            CheckBox1.Checked:=Extension_ON;
        end;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG._form2Settings;
begin
    if Assigned(In0k_lazExt_AFC.In0k_lazExt_AFC) then
    with In0k_lazExt_AFC.In0k_lazExt_AFC do begin
        AutoFoldComments_NAMEs_set(memo1.Lines);
        AutoFoldComments_LST:=CheckBox2.Checked;
        AutoFoldComments_HFC:=CheckBox3.Checked;
        AutoFoldComments_ALL:=RadioButton1.Checked;
        Extension_ON:=CheckBox1.Checked;
    end;
end;

//------------------------------------------------------------------------------

procedure TuiWND_in0k_lazExt_AFC_CFG.CheckBox1Change(Sender: TObject);
begin
    GroupBox1.Enabled:=CheckBox1.Checked;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG.RadioButton1Change(Sender: TObject);
begin
    memo1    .Enabled:=not RadioButton1.Checked;
    CheckBox2.Enabled:=not RadioButton1.Checked;
    CheckBox3.Enabled:=not RadioButton1.Checked;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG.RadioButton2Change(Sender: TObject);
begin
    memo1    .Enabled:=RadioButton2.Checked;
    CheckBox2.Enabled:=RadioButton2.Checked;
    CheckBox3.Enabled:=RadioButton2.Checked;
end;

//------------------------------------------------------------------------------

procedure TuiWND_in0k_lazExt_AFC_CFG.Button1Click(Sender: TObject);
begin
    if Assigned(In0k_lazExt_AFC.In0k_lazExt_AFC) then begin
      _form2Settings;
       In0k_lazExt_AFC.In0k_lazExt_AFC.SaveSettings;
      _Settings2Form;
    end;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG.Button2Click(Sender: TObject);
begin
    if Assigned(In0k_lazExt_AFC.In0k_lazExt_AFC) then begin
        In0k_lazExt_AFC.In0k_lazExt_AFC.SaveDefSettings;
       _Settings2Form;
    end;
end;

procedure TuiWND_in0k_lazExt_AFC_CFG.Button3Click(Sender: TObject);
begin
    {$ifOpt D+}
       _dbgLOG_SHOW;
    {$else}
       //sdf
    {$endIf}
end;

initialization
uiWND_in0k_lazExt_AFC_CFG:=nil;
end.

