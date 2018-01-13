object DM_Mysql: TDM_Mysql
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 181
  Width = 289
  object Con: TFDConnection
    Params.Strings = (
      'DriverID=MySQL'
      'Server=localhost'
      'User_Name=root'
      'Password=admin'
      'OSAuthent=No'
      'Database=nsm')
    Connected = True
    LoginPrompt = False
    Left = 40
    Top = 32
  end
  object QryAux: TFDQuery
    Connection = Con
    Left = 112
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 80
    Top = 96
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    VendorLib = 'C:\Program Files (x86)\MySQL\MySQL Server 5.5\lib\libmysql.dll'
    Left = 200
    Top = 64
  end
end
