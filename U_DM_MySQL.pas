unit U_DM_MySQL;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FMTBcd, SqlExpr, Vcl.Forms,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, Datasnap.Provider,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef;

type
  TDM_Mysql = class(TDataModule)
    Con: TFDConnection;
    QryAux: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    FInicializar: boolean;
  protected
    function ConnectDB: Boolean;
  public
    function GetData(ASQL: string; Parameters: array of Variant): OleVariant;
    function OpenSQL(ASQL: string; Parameters: array of Variant): Variant;
    procedure ExecuteSQL(ASQL: string; Parameters: array of Variant);

    property Inicializar: boolean read FInicializar;
  end;

var
  DM_Mysql: TDM_Mysql;

implementation

uses Windows, Variants, DBClient, IniFiles, Dialogs, U_DM_Firebird;

{$R *.dfm}

{ TDM }

function TDM_Mysql.ConnectDB: Boolean;
var
  CfgServer, CfgUser, CfgPassword, CfgOSAuthent, CfgDatadase : string;
begin
  with TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Config.ini') do
  try
      CfgServer    :=  ReadString('MYSQL', 'Server', 'ERROR');
      CfgUser      :=  ReadString('MYSQL', 'User_Name', 'Estoque');
      CfgPassword  :=  ReadString('MYSQL', 'Password', '15');
      CfgOSAuthent :=  ReadString('MYSQL', 'OSAuthent', '15');
      CfgDatadase  :=  ReadString('MYSQL', 'Database', 'ERROR');

      Con.Params.Clear;
      Con.Params.Add('DriverID=MySQL');
      Con.Params.Add('Server='+CfgServer);
      Con.Params.Add('User_Name='+CfgUser);
      Con.Params.Add('Password='+CfgPassword);
      Con.Params.Add('OSAuthent='+CfgOSAuthent);
      Con.Params.Add('Database='+CfgDatadase);

      try
        con.Open;
        Result := con.Connected;

        if not Con.Connected then Exit;
      except
        Result := False;
        Exit;
      end
  finally
    Free;
  end;
end;

procedure TDM_Mysql.DataModuleCreate(Sender: TObject);
begin
  if not ConnectDB then
    raise Exception.Create(
      '            NÃO FOI POSSÍVEL CONECTAR A BASE DO MySQL!'^m+
      ''^m+
      'Possíveis problemas que podem impedir a conexão:'^m+
      '1- Confira se o MySQL está instalado e funcionando corretamente nos '#13#10 +
      'processos do windows.'#13#10 +
      '2- Confira se o arquivo "Config.ini" está configurado corretamente.'
    );
end;

procedure TDM_Mysql.DataModuleDestroy(Sender: TObject);
begin
  Con.Close;
end;

procedure TDM_Mysql.ExecuteSQL(ASQL: string; Parameters: array of Variant);
var
  QRY: TFDQuery;
  i: integer;
begin
  QRY := TFDQuery.Create(Self);

  try
    QRY.Connection  := Con;
    QRY.SQL.Text    := ASQL;

    for i := 0 to High(Parameters) do
      if VarIsNull(Parameters[i]) or VarIsClear(Parameters[i]) then
      begin
        QRY.Params[i].AsString := '';
        QRY.Params[i].Clear;
      end else
        QRY.Params[i].Value := Parameters[i];
      //
    try
      QRY.ExecSQL();
    except
      on E: Exception do
        raise Exception.Create(E.Message + #13#10 + ASQL);
    end;
  finally
    QRY.Free;
  end;
end;

function TDM_Mysql.GetData(ASQL: string; Parameters: array of Variant): OleVariant;
var
  QRY: TFDQuery;
  DSP: TDataSetProvider;
  CDS: TClientDataSet;
  i: integer;
begin
  QRY := TFDQuery.Create(Self);
  DSP := TDataSetProvider.Create(Self);
  CDS := TClientDataSet.Create(Self);

  try
    QRY.Connection    := Con;
    DSP.Options       := [poAllowCommandText, poRetainServerOrder];
    DSP.Name          := '_DSP';
    DSP.DataSet       := QRY;
    CDS.ProviderName  := '_DSP';
    CDS.CommandText   := ASQL;

    for i := 0 to High(Parameters) do
      if VarIsNull(Parameters[i]) or VarIsClear(Parameters[i]) then
      begin
        CDS.Params[i].AsString := '';
        CDS.Params[i].Clear;
      end else
        CDS.Params[i].Value := Parameters[i];
      //
    try
      CDS.Open;
      Result := CDS.Data;
      CDS.Close;
    except
      on E: Exception do raise Exception.Create(E.Message + #13#10 + ASQL);
    end;
  finally
    DSP.Name := '';
    CDS.Free;
    DSP.Free;
    QRY.Free;
  end;
end;

function TDM_Mysql.OpenSQL(ASQL: string; Parameters: array of Variant): Variant;
var
  QRY: TFDQuery;
  i: integer;
begin
  Result := Null;

  QRY := TFDQuery.Create(nil);

  try
    QRY.Connection := Con;
    QRY.SQL.Text   := ASQL;

    for i := 0 to High(Parameters) do
      if VarIsNull(Parameters[i]) or VarIsClear(Parameters[i]) then
      begin
        QRY.Params[i].AsString := '';
        QRY.Params[i].Clear;
      end else
        QRY.Params[i].Value := Parameters[i];
      //
    try
      QRY.Open;
      if not QRY.IsEmpty then Result := QRY.Fields[0].Value;
      QRY.Close;
    except
      on E: Exception do
        raise Exception.Create(E.Message + #13#10 + ASQL);
    end;
  finally
    QRY.Free;
  end;
end;

initialization
  if not Assigned(DM_Mysql) then
    DM_Mysql := TDM_Mysql.Create(nil);

end.
