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
    AFC_Config_Object,
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
   _lastProc:TSourceEditorInterface; //< последний ОБРАБОТАННЫЙ
  protected //< ВСЯ СУТЬ этого "дополнения"
    function  _ideLaz_get_ActvEDT:TSourceEditorInterface;
    function  _ideLaz_get_CodeBUF(const Editor:TSourceEditorInterface):TCodeBuffer;
    function  _ideLaz_get_cnfgOBJ(const Editor:TSourceEditorInterface):pAFC_Config_Object;
    function  _ideLaz_get_afcEDIT(const Editor:TSourceEditorInterface):tIn0k_lazExt_AFC_synEdit;



    //function  _ideLaz_getActiveEditor_fileName:string;
  protected //< ВСЯ СУТЬ этого "дополнения"
    function  _perform_AFC_getActiveEditor(out CodeBuffer:TCodeBuffer):tIn0k_lazExt_AFC_synEdit;
    function  _perform_AFC_execute(const afcEdit:tIn0k_lazExt_AFC_synEdit; const cnfgOBJ:pAFC_Config_Object):boolean;
    procedure _perform_AFC;
  protected //< СОБЫТИЯ
    procedure _ideEvent_semEditorActivate(Sender: TObject);
    procedure _ideEvent_closeIDE(Sender: TObject);
  protected
   _SubScriber_:pointer;
    procedure _SubScriber_Register;
  protected //< и их РЕГИСТРАЦИЯ
    procedure _ideEvents_Register;
    procedure _ideEvents_unRegister;
  protected
    function  _DEBUG_get_ActiveEditor_Name:string;
    procedure  DEBUG(const msgType,msgText:string);
  public
    constructor Create;
    destructor DESTROY; override;
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
begin {***> причины использования `_closeIDE`
            не понятно по какому принципу необходимо отписываться от событий.
            но без этого Lazarus завершается с утечкой памяти или вообще падает.
      }
    {$ifOpt D+}
    DEBUG('ideEvent','closeIDE');
    {$endIf}
   _ideEvents_unRegister;
end;

procedure tIn0k_lazExt_AFC._ideEvent_semEditorActivate(Sender: TObject);
begin {***> рабочее Событие.
            При АКТИВАЦИИ вкладки редактора исходного кода выполняем "ДОБАВКУ"
      }
    {$ifOpt D+}
    DEBUG('ideEvent','semEditorActivate: '+_DEBUG_get_ActiveEditor_Name);
    {$endIf}
   _perform_AFC;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const cIn0k_lazExt_AFNC_registerEvent=semEditorActivate;

procedure tIn0k_lazExt_AFC._ideEvents_register;
begin
    LazarusIDE.AddHandlerOnIDEClose(@_ideEvent_closeIDE);
    SourceEditorManagerIntf.RegisterChangeEvent(cIn0k_lazExt_AFNC_registerEvent, @_ideEvent_semEditorActivate);
end;

procedure tIn0k_lazExt_AFC._ideEvents_unRegister;
begin
    LazarusIDE.RemoveHandlerOnIDEClose(@_ideEvent_closeIDE);
    SourceEditorManagerIntf.UnRegisterChangeEvent(cIn0k_lazExt_AFNC_registerEvent, @_ideEvent_semEditorActivate);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tIn0k_lazExt_AFC._SubScriber_Register;
begin
   _SubScriber_:=CbSFP_SubScriber__REGISTER(tAFC_Config_Handle,tAFC_Config_Editor);
end;

{%endregion}

{%region --- ВСЯ СУТь --------------------------------------------- /fold}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function tIn0k_lazExt_AFC._ideLaz_get_ActvEDT:TSourceEditorInterface;
begin
    result:=SourceEditorManagerIntf.ActiveEditor;
    {$ifOpt D+}
    if not Assigned(result) then DEBUG('ER','ActiveEditor is NULL');
    {$endIf}
end;

function tIn0k_lazExt_AFC._ideLaz_get_afcEDIT(const Editor:TSourceEditorInterface):tIn0k_lazExt_AFC_synEdit;
begin
    result:=tIn0k_lazExt_AFC_synEdit(Editor.EditorControl);
    {$ifOpt D+}
    if not Assigned(result) then DEBUG('ER','AFC_synEdit is NULL');
    {$endIf}
end;

function tIn0k_lazExt_AFC._ideLaz_get_CodeBUF(const Editor:TSourceEditorInterface):TCodeBuffer;
begin
    result:=TCodeBuffer(Editor.CodeToolsBuffer);
    {$ifOpt D+}
    if not Assigned(result) then DEBUG('ER','CodeBuffer is NULL');
    {$endIf}
end;

function tIn0k_lazExt_AFC._ideLaz_get_cnfgOBJ(const Editor:TSourceEditorInterface):pAFC_Config_Object;
begin
    result:=CbSFP_SubScriber__cnfg_OBJ(_SubScriber_,Editor.FileName);
    {$ifOpt D+}
    if not Assigned(result) then DEBUG('ER','cnfgOBJECT is NULL');
    {$endIf}
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function tIn0k_lazExt_AFC._perform_AFC_getActiveEditor(out CodeBuffer:TCodeBuffer):tIn0k_lazExt_AFC_synEdit;
begin // вытягиваем текущий активный synEdit
  (*  CodeBuffer     :=nil;
    pointer(result):=_ideLaz_getActiveEditor{SourceEditorManagerIntf.ActiveEditor};
    if Assigned(result) then begin
        {$ifOpt D+}
        DEBUG('ok','ActiveEditor found : '+'@'+IntToHex( PtrUInt(pointer(result)), sizeOf(pointer)*2 ));
        {$endIf}
        CodeBuffer:=TCodeBuffer(TSourceEditorInterface(pointer(result)).CodeToolsBuffer);
        if assigned(CodeBuffer)
        then begin
            result:=tIn0k_lazExt_AFC_synEdit(TCustomSynEdit(TSourceEditorInterface(pointer(result)).EditorControl));
            {$ifOpt D+}
            DEBUG('ok','CodeBuffer found : '+'@'+IntToHex( PtrUInt(pointer(CodeBuffer)), sizeOf(pointer)*2 ));
            {$endIf}
        end
        else begin
            result:=nil;
            {$ifOpt D+}
            DEBUG('ER','CodeBuffer is NULL');
            {$endIf}
        end
    end
    {$ifOpt D+}
    else begin
        DEBUG('ER','ActiveEditor is NULL');
    end
    {$endIf}
    *)
end;


function tIn0k_lazExt_AFC._perform_AFC_execute(const afcEdit:tIn0k_lazExt_AFC_synEdit; const cnfgOBJ:pAFC_Config_Object):boolean;
begin
    {$ifOpt D+}
    DEBUG('Execute ','>>>>> START ===== '+'afcSynEDIT->@'+IntToHex( PtrUInt(pointer(afcEdit)), sizeOf(pointer)*2 )+' cnfgOBJ->@'+IntToHex( PtrUInt(pointer(cnfgOBJ)), sizeOf(pointer)*2 ));
    {$endIf}
    //--------------------------------------------------------------------------
    result:=TRUE;

    {if not _fold_ALL then begin
        if not _fold_HFC

        //then CodeBuf:=nil; //< использовать НЕ будем
        then ActvEdt.foldComments_Name(_workList,nil)
        else ActvEdt.foldComments_Name(_workList,CodeBuf)
    end
    else ActvEdt.foldComments_ALL;   }
    afcEdit.foldComments_ALL;
    //--------------------------------------------------------------------------
    {$ifOpt D+}
    DEBUG('Execute ','<<<<<  END  =====');
    {$endIf}
end;


procedure tIn0k_lazExt_AFC._perform_AFC;
var ActvEdt:TSourceEditorInterface;
    cnfgOBJ:pAFC_Config_Object;
    CodeBuf:TCodeBuffer;
    afcEdit:tIn0k_lazExt_AFC_synEdit;
begin
    ActvEdt:=_ideLaz_get_ActvEDT;//(CodeBuf);
    if Assigned(ActvEdt) then begin
        if ActvEdt<>_lastProc then begin
            {*1> причины использования `_lastProc`
                механизм с `_lastProcessed` приходится использовать из-за того, что
                при переключение "Вкладок Редактора Исходного Кода" вызов данного
                события происходит аж 3(три) раза.
                Почему так происходит - повод для дальнейших разобирательств.
                -----
                еще это событие происходит КОГДА идет навигация (прыжки по файлу)
                -----
                Используем только ПЕРВЫЙ вход
            }
            {todo: проверка на обрабатывание ТОЛЬКО в слючае ОТКРЫТИЯ}
            afcEdit:=_ideLaz_get_afcEDIT(ActvEdt);
            if Assigned(afcEdit) then begin
                cnfgOBJ:=_ideLaz_get_cnfgOBJ(ActvEdt);
                if Assigned(cnfgOBJ) then begin
                    if _perform_AFC_execute(afcEdit,cnfgOBJ) then begin //< тут работа
                       _lastProc:=ActvEdt;
                    end
                    else begin
                       _lastProc:=nil;
                        {$ifOpt D+}
                        DEBUG('SKIP','EXECUTE FAILs');
                        {$endIf}
                    end;
                end
                else begin
                   _lastProc:=nil;
                    {$ifOpt D+}
                    DEBUG('SKIP','cnfgOBJ not Ready');
                    {$endIf}
                end;
            end
            else begin
               _lastProc:=nil;
                {$ifOpt D+}
                DEBUG('SKIP','afcEdit not Ready');
                {$endIf}
            end;
        end
        else begin
            {$ifOpt D+}
            DEBUG('SKIP','already processed');
            {$endIf}
        end;
    end
    else begin
       _lastProc:=nil;
        {$ifOpt D+}
        DEBUG('SKIP','IDE not Ready');
        {$endIf}
    end;
end;


{%endregion}

function tIn0k_lazExt_AFC._DEBUG_get_ActiveEditor_Name:string;
var tmp:TSourceEditorInterface;
begin
    tmp:=_ideLaz_get_ActvEDT;
    if not Assigned(tmp) then result:='ndf'
    else begin
        result:='ActiveEDT->@'+IntToHex( PtrUInt(pointer(tmp)), sizeOf(pointer)*2 );
        result:=result+' '+ExtractFileName(tmp.FileName);
    end;
end;

procedure tIn0k_lazExt_AFC.DEBUG(const msgType,msgText:string);
begin
    CbSFP_SubScriber__DebugMSG(_SubScriber_,msgType,msgText);
end;


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

