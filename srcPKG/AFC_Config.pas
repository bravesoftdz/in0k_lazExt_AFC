unit AFC_Config;

{$mode objfpc}{$H+}

interface

uses
CbSFP_SubScriber,
Classes, Forms, StdCtrls,
  in0k_lazExt_AFC, in0k_lazExt_AFC_wndDBG;

const
 cUiWND_in0k_lazExt_AFC_CFG_Caption='Configure "Auto Fold Comments" tool';

type


 tAFC_Config_Object = class

  end;



 {inkDoc> "Окно" конфигурации
   настройка работы `tIn0k_lazExt_AFC`
 <inkDoc}

 { tAFC_Config_Editor }

 tAFC_Config_Editor = class(TCbSFP_SubScriber_editor)
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
    procedure RadioButton1Change(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
  private
    procedure _Settings2Form;
    procedure _form2Settings;
  private
    procedure onCreate_setTexts;
  public
    constructor Create(TheOwner: TComponent); override;
  public
    procedure Settings_LOAD(const {%H-}Obj:pointer); override;
    procedure Settings_SAVE(const {%H-}Obj:pointer); override;
  end;

implementation

{$R *.lfm}

procedure tAFC_Config_Editor.Settings_LOAD(const Obj:pointer);
begin

end;

procedure tAFC_Config_Editor.Settings_SAVE(const Obj:pointer);
begin

end;


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

constructor tAFC_Config_Editor.Create(TheOwner:TComponent);
begin
    inherited;
    onCreate_setTexts;
    //---
    CheckBox1.Checked:=FALSE;
    RadioButton1.Checked:=TRUE;
end;

procedure tAFC_Config_Editor.onCreate_setTexts;
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


procedure tAFC_Config_Editor._Settings2Form;
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

procedure tAFC_Config_Editor._form2Settings;
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

procedure tAFC_Config_Editor.CheckBox1Change(Sender: TObject);
begin
    GroupBox1.Enabled:=CheckBox1.Checked;
end;

procedure tAFC_Config_Editor.RadioButton1Change(Sender: TObject);
begin
    memo1    .Enabled:=not RadioButton1.Checked;
    CheckBox2.Enabled:=not RadioButton1.Checked;
    CheckBox3.Enabled:=not RadioButton1.Checked;
end;

procedure tAFC_Config_Editor.RadioButton2Change(Sender: TObject);
begin
    memo1    .Enabled:=RadioButton2.Checked;
    CheckBox2.Enabled:=RadioButton2.Checked;
    CheckBox3.Enabled:=RadioButton2.Checked;
end;

//------------------------------------------------------------------------------

procedure tAFC_Config_Editor.Button1Click(Sender: TObject);
begin
    if Assigned(In0k_lazExt_AFC.In0k_lazExt_AFC) then begin
      _form2Settings;
       In0k_lazExt_AFC.In0k_lazExt_AFC.SaveSettings;
      _Settings2Form;
    end;
end;

procedure tAFC_Config_Editor.Button2Click(Sender: TObject);
begin
    if Assigned(In0k_lazExt_AFC.In0k_lazExt_AFC) then begin
        In0k_lazExt_AFC.In0k_lazExt_AFC.SaveDefSettings;
       _Settings2Form;
    end;
end;

procedure tAFC_Config_Editor.Button3Click(Sender: TObject);
begin
    {$ifOpt D+}
       _dbgLOG_SHOW;
    {$else}
       //sdf
    {$endIf}
end;

initialization
AFC_Config_Editor:=nil;
end.

