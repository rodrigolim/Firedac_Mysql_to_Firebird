unit U_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, Data.DB, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Datasnap.Provider, Datasnap.DBClient, FireDAC.Comp.DataSet, Vcl.ExtCtrls,
  Vcl.DBCtrls, Vcl.StdCtrls;

type
  Tfrm_main = class(TForm)
    Button2: TButton;
    Log: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_main: Tfrm_main;

implementation

{$R *.dfm}

uses U_DM_MySQL, U_DM_Firebird, U_Func;

procedure Tfrm_main.Button2Click(Sender: TObject);
const
  VALID_ALUNO =
   'SELECT COUNT(*) FROM ALUNOS WHERE ALU_ID = :ID';

  SQL_ALUNO =
   ' select '+
   '   codigoInt, DATAB, Nome, SEXO, NACIONALIDADE, DATACAD, DATAATUAL '+
   ' from '+
   '   aluno';

  INS_ALUNO =
  'INSERT INTO ALUNOS ( '+
  '  ALU_ID, ALU_NOME, ALU_NASCIM, ALU_SEXO, ALU_COR, ALU_FILIACAO, '+
  '  ALU_NACION, ALU_PAIS, ALU_ZONARES, ALU_DATAALT, ALU_DATAINC '+
  ' )VALUES( '+
  '  :ALU_ID, :ALU_NOME, :ALU_NASCIM, :ALU_SEXO, :ALU_COR, :ALU_FILIACAO, '+
  '  :ALU_NACION, :ALU_PAIS, :ALU_ZONARES, :ALU_DATAALT, :ALU_DATAINC '+
  ' )';
var
  regImp, regNaoImp :Integer;
begin
    Log.Lines.Clear;


    with TClientDataSet.Create(Self) do
    try
      Data := DM_Mysql.GetData(SQL_ALUNO, []);
      //
      regImp   := 0;
      regNaoImp := 0;
      Log.Lines.Add('Encontrado '+ IntToStr(recordCount)+' registros de alunos para importação.');
      if not(IsEmpty) then
      begin
        First;

        while not(Eof) do
        begin
          if DM_Firebird.OpenSQL(VALID_ALUNO,[FieldByName('codigoInt').Value]) = 0 then
          Begin
            DM_Firebird.ExecuteSQL(INS_ALUNO,[FieldByName('codigoInt').Value,
                                              TFunc.IfThen(FieldByName('Nome').AsString='','NÃO INFORMADO',FieldByName('Nome').Value),
                                              TFunc.IfThen(FieldByName('DATAB').IsNull,Date,FieldByName('DATAB').Value),
                                              TFunc.IfThen(not(FieldByName('SEXO').AsString=''),FieldByName('SEXO').AsString,'Masculino'),
                                              'NÃO DECLARADA',
                                              '0',
                                              TFunc.IfThen(not(FieldByName('NACIONALIDADE').AsString=''),FieldByName('NACIONALIDADE').AsString,'Brasileira'),
                                              '10',
                                              'URBANA',
                                              FieldByName('DATACAD').Value,
                                              FieldByName('DATAATUAL').Value
                                             ]);
            inc(regImp);
          End
          else
            inc(regNaoImp);

          Next;
        end;

        Log.Lines.Add('Registros importados = '+IntToStr(regImp));
        Log.Lines.Add('Registros NÃO importados = '+IntToStr(regNaoImp));
        Log.Lines.Add('Importação do cadastro de alunos concluida com sucesso!');
      end;
    finally
      Free;
    end;
end;

end.
