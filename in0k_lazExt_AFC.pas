unit in0k_lazExt_AFC;
//----------------------------------------------------------------------------//
//   _____ _____ _____                                                        \\
//  |  _  |   __|     | auto                                                  //
//  |     |   __|   --| fold                                                  \\
//  |__|__|__|  |_____| comment                                               //
//                                                                            \\
//----------------------------------------------------------------------------//

{$mode objfpc}{$H+}

interface

uses {$ifOpt D+} in0k_lazExt_AFC_wndDBG, {$endIf}
    Classes, sysutils,
    AFC_Config_Editor,
     AFC_Config_Handle,
    // in0k_lazExt_AFC,
     CbSFP__Intf,
    LazConfigStorage,
    BaseIDEIntf, LazIDEIntf, SrcEditorIntf,
    CodeCache, SynEdit,
    in0k_lazExt_AFC_synEdit;

const
 cIn0k_lazExt_AFC_Name='in0k_lazExt_AFC';

type

 tIn0k_lazExt_AFC=class
  strict private
   _lastProc:tIn0k_lazExt_AFC_synEdit; //< последний ОБРАБОТАННЫЙ
  protected //< ВСЯ СУТЬ этого "дополнения"
    function  _perform_AFC_getActiveEditor(out CodeBuffer:TCodeBuffer):tIn0k_lazExt_AFC_synEdit;
    procedure _perform_AFC;
  protected //< СОБЫТИЯ
    procedure _ideEvent_srcEditorActivate(Sender: TObject);
    procedure _ideEvent_closeIDE(Sender: TObject);
  protected
   _SubScriber_:pointer;
    procedure _SubScriber_Register;
  protected //< и их РЕГИСТРАЦИЯ
    procedure _ideEvents_Register;
    procedure _ideEvents_unRegister;
  protected //< настройки
   {_nameList:tStrings; //< список "Имен"
   _lazExtON:boolean;  //< мы вообще работаем
   _fold_ALL:boolean;  //< сворачивать ВСЕ
   _fold_LST:boolean;  //< сворачивать ВСЕ
   _fold_HFC:boolean;  //< сворачивать Hint From Comment
    procedure _nameList_set(const names:tStrings);
    procedure _nameList_get(const names:tStrings); }
  protected
    //procedure _settings_Load;
    //procedure _settings_Save;
    //procedure _settings_toDefault;
  public
    constructor Create;
    destructor DESTROY; override;
  public
    //procedure SaveSettings;
    //procedure SaveDefSettings;
  end;

procedure In0k_lazExt_AFC__CREATE;
function  In0k_lazExt_AFC:tIn0k_lazExt_AFC;

implementation

constructor tIn0k_lazExt_AFC.Create;
begin
   _lastProc:=nil;
    //---
   _SubScriber_Register;
   _ideEvents_register;
end;

destructor tIn0k_lazExt_AFC.DESTROY;
begin
    inherited;
 //  _nameList.FREE;
 //  _workList.FREE;
end;

//------------------------------------------------------------------------------

{%region --- события IDE Lazarus ---------------------------------- /fold}

procedure tIn0k_lazExt_AFC._ideEvent_closeIDE(Sender: TObject);
begin
    {*2> причины использования `_closeIDE` /fold
        не понятно по какому принципу необходимо отписываться от событий.
        но без этого Lazarus завершается с утечкой памяти или вообще падает.
    <*2}
   _ideEvents_unRegister;
end;

procedure tIn0k_lazExt_AFC._ideEvent_srcEditorActivate(Sender: TObject);
begin
    {*3> рабочее Событие. /fold
        При АКТИВАЦИИ вкладки редактора исходного кода выполняем "ДОБАВКУ"
    <*3}
    {if _lazExtON then} _perform_AFC;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const cIn0k_lazExt_AFNC_registerEvent=semEditorActivate;

procedure tIn0k_lazExt_AFC._ideEvents_register;
begin
    LazarusIDE.AddHandlerOnIDEClose(@_ideEvent_closeIDE);
    SourceEditorManagerIntf.RegisterChangeEvent(cIn0k_lazExt_AFNC_registerEvent, @_ideEvent_srcEditorActivate);
end;

procedure tIn0k_lazExt_AFC._ideEvents_unRegister;
begin
    LazarusIDE.RemoveHandlerOnIDEClose(@_ideEvent_closeIDE);
    SourceEditorManagerIntf.UnRegisterChangeEvent(cIn0k_lazExt_AFNC_registerEvent, @_ideEvent_srcEditorActivate);
end;

procedure tIn0k_lazExt_AFC._SubScriber_Register;
begin
   _SubScriber_:=CbSFP_SubScriber__REGISTER(tAFC_Config_Handle,tAFC_Config_Editor);
end;


{%endregion}

{%region --- ВСЯ СУТь --------------------------------------------- /fold}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function tIn0k_lazExt_AFC._perform_AFC_getActiveEditor(out CodeBuffer:TCodeBuffer):tIn0k_lazExt_AFC_synEdit;
begin // вытягиваем текущий активный synEdit
    CodeBuffer     :=nil;
    pointer(result):=SourceEditorManagerIntf.ActiveEditor;
    if Assigned(result) then begin
        {$ifOpt D+}
       _dbgLOG_('getActiveEditor found:'+TSourceEditorInterface(pointer(result)).FileName);
        {$endIf}
        CodeBuffer:=TCodeBuffer(TSourceEditorInterface(pointer(result)).CodeToolsBuffer);
        if assigned(CodeBuffer)
        then result:=tIn0k_lazExt_AFC_synEdit(TCustomSynEdit(TSourceEditorInterface(pointer(result)).EditorControl))
        else begin
            result:=nil;
            {$ifOpt D+}
           _dbgLOG_('CodeBuffer is NULL');
            {$endIf}
        end
    end
    {$ifOpt D+}
    else begin
        _dbgLOG_('SourceEditorManagerIntf.ActiveEditor is NULL');
    end
    {$endIf}
end;

procedure tIn0k_lazExt_AFC._perform_AFC;
var tmpEdit:tIn0k_lazExt_AFC_synEdit;
    CodeBuf:TCodeBuffer;

    cnf:pointer;


begin
    tmpEdit:=_perform_AFC_getActiveEditor(CodeBuf);
    if Assigned(tmpEdit) and Assigned(CodeBuf) then begin
        {*1> причины использования `_lastProcessed` /fold
            механизм с `_lastProcessed` приходится использовать из-за того, что
            при переключение "Вкладок Редактора Исходного Кода" вызов данного
            события происходит аж 3(три) раза.
            Почему так происходит - повод для дальнейших разобирательств.
        <*1}
        if _lastProc<>tmpEdit then begin
            {$ifOpt D+}
           _dbgLOG_(' ==== START for file :'+CodeBuf.Filename);
            {$endIf}

            cnf:=CbSFP_SubScriber__cnfg_OBJ(_SubScriber_,CodeBuf.Filename);

            {$ifOpt D+}
            if cnf<>nil then
           _dbgLOG_(' ==== CNFG FIND :'+IntToHex(int64(cnf),8));
            {$endIf}

            {if not _fold_ALL then begin
                if not _fold_HFC

                //then CodeBuf:=nil; //< использовать НЕ будем
                then tmpEdit.foldComments_Name(_workList,nil)
                else tmpEdit.foldComments_Name(_workList,CodeBuf)
            end
            else tmpEdit.foldComments_ALL;   }
            {$ifOpt D+}
           _dbgLOG_(' ====  END  =========:');
            {$endIf}
           _lastProc:=tmpEdit;
        end;
    end
    else _lastProc:=nil;
end;

{%endregion}

//==============================================================================
var _In0k_lazExt_AFNC_:tIn0k_lazExt_AFC;

function In0k_lazExt_AFC:tIn0k_lazExt_AFC;
begin
    result:=_In0k_lazExt_AFNC_;
end;

procedure In0k_lazExt_AFC__CREATE;
begin
   _In0k_lazExt_AFNC_:=tIn0k_lazExt_AFC.Create;
end;

initialization
_In0k_lazExt_AFNC_:=nil;
finalization
_In0k_lazExt_AFNC_.Free;
end.

