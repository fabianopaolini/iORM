{***************************************************************************}
{                                                                           }
{           iORM - (interfaced ORM)                                         }
{                                                                           }
{           Copyright (C) 2015-2016 Maurizio Del Magno                      }
{                                                                           }
{           mauriziodm@levantesw.it                                         }
{           mauriziodelmagno@gmail.com                                      }
{           https://github.com/mauriziodm/iORM.git                          }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  This file is part of iORM (Interfaced Object Relational Mapper).         }
{                                                                           }
{  Licensed under the GNU Lesser General Public License, Version 3;         }
{  you may not use this file except in compliance with the License.         }
{                                                                           }
{  iORM is free software: you can redistribute it and/or modify             }
{  it under the terms of the GNU Lesser General Public License as published }
{  by the Free Software Foundation, either version 3 of the License, or     }
{  (at your option) any later version.                                      }
{                                                                           }
{  iORM is distributed in the hope that it will be useful,                  }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of           }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            }
{  GNU Lesser General Public License for more details.                      }
{                                                                           }
{  You should have received a copy of the GNU Lesser General Public License }
{  along with iORM.  If not, see <http://www.gnu.org/licenses/>.            }
{                                                                           }
{***************************************************************************}





unit iORM.DB.Components.ConnectionDef;

interface

uses
  System.Classes, iORM.DB.Interfaces, iORM.CommonTypes;

type

  TioDBStdFolder = (sfUndefined, sfDocuments, sfSharedDocuments, sfHome, sfPublic, sfTemp);
  TioOSAuthent = (oaNo, oaYes);
  TioSQLDialect = (sqlDialect1, sqlDialect2, sqlDialect3);
  TioProtocol = (pLocal, pNetBEUI, pSPX, pTCPIP);

  // Base class for all ConnectionDef components
  TioCustomConnectionDef = class(TComponent)
  strict private
    // Events
    FOnAfterRegister: TNotifyEvent;
    FOnBeforeRegister: TNotifyEvent;
    // Fields
    FAutoCreateDatabase: Boolean;
    FBaseURL: String;
    FCharSet: String;
    FConnectionDef: IIoConnectionDef;
    FDatabase: String;
    FDatabaseStdFolder: TioDBStdFolder;
    FDefaultConnection: Boolean;
    FEncrypt: String;
    FIsRegistered: Boolean;
    FNewPassword: String;
    FOSAuthent: TioOSAuthent;
    FPassword: String;
    FPersistent: Boolean;
    FPooled: Boolean;
    FPort: Integer;
    FProtocol: TioProtocol;
    FServer: String;
    FSQLDialect: TioSQLDialect;
    FUserName: String;
    procedure SetDefaultConnection(const Value: Boolean);
    procedure DoAfterRegister;
    procedure DoBeforeRegister;
  protected
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
    function GetFullPathDatabase: String;
    // Properties
    property AutoCreateDatabase:Boolean read FAutoCreateDatabase write FAutoCreateDatabase;
    property BaseURL: String read FBaseURL write FBaseURL;
    property CharSet: String read FCharSet write FCharSet;
    property Database: String read FDatabase write FDatabase;
    property DatabaseStdFolder: TioDBStdFolder read FDatabaseStdFolder write FDatabaseStdFolder;
    property Encrypt: String read FEncrypt write FEncrypt;
    property NewPassword: String read FNewPassword write FNewPassword;
    property OSAuthent: TioOSAuthent read FOSAuthent write FOSAuthent;
    property Password: String read FPassword write FPassword;
    property Pooled: Boolean read FPooled write FPooled;
    property Port: Integer read FPort write FPort;
    property Protocol: TioProtocol read FProtocol write FProtocol;
    property Server:String read FServer write FServer;
    property SQLDialect: TioSQLDialect read FSQLDialect write FSQLDialect;
    property UserName: String read FUserName write FUserName;
  public
    procedure RegisterConnectionDef; virtual;
    // Properties
    property ConnectionDef: IIoConnectionDef read FConnectionDef write FConnectionDef;
    property DefaultConnection: Boolean read FDefaultConnection write SetDefaultConnection;
    property IsRegistered:Boolean read FIsRegistered;
    property Persistent: Boolean read FPersistent write FPersistent;
  published
    // Events
    property OnAfterRegister: TNotifyEvent read FOnAfterRegister write FOnAfterRegister;
    property OnBeforeRegister: TNotifyEvent read FOnBeforeRegister write FOnBeforeRegister;
  end;

(*&&&& inizio
  // Class for REST remoted connection
  TioRESTConnectionDef = class(TioCustomConnectionDef)
  public
    constructor Create(AOwner: TComponent); override;
  public
    procedure RegisterConnectionDef; override;
  published
    property BaseURL;
    property DefaultConnection;
    property Persistent;
  end;

  // Class for SQLite connection
  TioSQLiteConnectionDef = class(TioCustomConnectionDef)
  public
    constructor Create(AOwner: TComponent); override;
    procedure RegisterConnectionDef; override;
    property ConnectionDef;
  published
    // Properties
    property AutoCreateDatabase;
    property Database;
    property DatabaseStdFolder;
    property DefaultConnection;
    property Encrypt;
    property NewPassword;
    property Password;
    property Persistent;
    property Pooled;
  end;

  // Class for Firebird connection
  TioFirebirdConnectionDef = class(TioCustomConnectionDef)
  public
    constructor Create(AOwner: TComponent); override;
    procedure RegisterConnectionDef; override;
    property ConnectionDef;
  published
    // Properties
    property CharSet;
    property Database;
    property DatabaseStdFolder;
    property DefaultConnection;
    property OSAuthent;
    property Password;
    property Persistent;
    property Pooled;
    property Port;
    property Protocol;
    property Server;
    property SQLDialect;
    property UserName;
  end;

  // Class for MSSQLServer connection
  TioSQLServerConnectionDef = class(TioCustomConnectionDef)
  public
    procedure RegisterConnectionDef; override;
    property ConnectionDef;
  published
    // Properties
    property Database;
    property DatabaseStdFolder;
    property DefaultConnection;
    property Encrypt;
    property OSAuthent;
    property Password;
    property Persistent;
    property Pooled;
    property Server;
    property UserName;
  end;

//%%%% inizio
  // Class for Oracle connection
  TioOracleConnectionDef = class(TioCustomConnectionDef)
  public
    procedure RegisterConnectionDef; override;
    property ConnectionDef;
  published
    // Properties
    property Database;
//    property DatabaseStdFolder;
//    property DefaultConnection;
//    property Encrypt;
//    property OSAuthent;
    property Password;
    property Persistent;
    property Pooled;
//    property Server;
    property UserName;
  end;

  // Class for Postgres connection
  TioPostgresConnectionDef = class(TioCustomConnectionDef)
  public
    constructor Create(AOwner: TComponent); override;
    procedure RegisterConnectionDef; override;
    property ConnectionDef;
  published
    // Properties
    property Database;
//    property DatabaseStdFolder;
//    property DefaultConnection;
//    property Encrypt;
//    property OSAuthent;
    property Password;
    property Persistent;
    property Pooled;
    property Port;
    property Server;
    property UserName;
  end;
//%%%% fine

  // Class for MySQL connection
  TioMySQLConnectionDef = class(TioCustomConnectionDef)
  public
    constructor Create(AOwner: TComponent); override;
    procedure RegisterConnectionDef; override;
    property ConnectionDef;
  published
    // Properties
    property CharSet;
    property Database;
    property DatabaseStdFolder;
    property DefaultConnection;
    property Password;
    property Persistent;
    property Pooled;
    property Port;
    property Server;
    property UserName;
  end;
*)

  // Class for SQL Monitor functionalities
  TioSQLMonitor = class(TComponent)
  strict private
    FMode: TioMonitorMode;
    procedure SetMode(const Value: TioMonitorMode);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Mode: TioMonitorMode read FMode write SetMode;
  end;

implementation

uses
  System.IOUtils, iORM.DB.ConnectionContainer, System.SysUtils,
  iORM;

{ TioCustomConnectionDef }

constructor TioCustomConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  FAutoCreateDatabase := False;
  FBaseURL := '';
  FCharSet := '';
  FDatabase := '';
  FDatabaseStdFolder := TioDBStdFolder.sfUndefined;
  FDefaultConnection := True;
  FEncrypt := '';
  FIsRegistered := False;
  FNewPassword := '';
  FOSAuthent := TioOSAuthent.oaNo;
  FPassword := '';
  FPersistent := False;
  FPooled := False;
  FPort := 0;
  FProtocol := TioProtocol.pTCPIP;
  FServer := '';
  FSQLDialect := TioSQLDialect.sqlDialect3;
  FUserName := '';
end;

procedure TioCustomConnectionDef.DoAfterRegister;
begin
  if Assigned(FOnAfterRegister) then
    FOnAfterRegister(Self);
end;

procedure TioCustomConnectionDef.DoBeforeRegister;
begin
  if Assigned(FOnBeforeRegister) then
    FOnBeforeRegister(Self);
end;

function TioCustomConnectionDef.GetFullPathDatabase: String;
var
  LDBFolder: String;
begin
  case FDatabaseStdFolder of
    TioDBStdFolder.sfDocuments:       LDBFolder := TPath.GetDocumentsPath;
    TioDBStdFolder.sfSharedDocuments: LDBFolder := TPath.GetSharedDocumentsPath;
    TioDBStdFolder.sfHome:            LDBFolder := TPath.GetHomePath;
    TioDBStdFolder.sfPublic:          LDBFolder := TPath.GetPublicPath;
    TioDBStdFolder.sfTemp:            LDBFolder := TPath.GetTempPath;
  else
    LDBFolder := '';
  end;
  Result := TPath.GetFullPath(TPath.Combine(LDBFolder, FDatabase));
end;

procedure TioCustomConnectionDef.Loaded;
begin
  inherited;
  // Register itself in the ConnectionManager if not already registered (byTioPrototypeBindSource)
  if (csDesigning in ComponentState) then
    Exit;
  if (not FIsRegistered) then
    RegisterConnectionDef;
end;

procedure TioCustomConnectionDef.RegisterConnectionDef;
begin
  inherited;
  // Mark the connection as registered in the ConnectionManager
  FIsRegistered := True;
  // Fire the OnBeforeRegister event if implemented
  DoBeforeRegister;
  // Autocreate Database if enabled
  if FAutoCreateDatabase then
    io.AutoCreateDatabase(Self.Name);
  // Fire the OnAfterRegister event if implemented
  DoAfterRegister;
end;

procedure TioCustomConnectionDef.SetDefaultConnection(const Value: Boolean);
var
  I: Integer;
  LConnectionDef: TioCustomConnectionDef;
begin
  FDefaultConnection := Value;
  if Value then
  begin
    // Uncheck previous default connection
    for I := 0 to Owner.ComponentCount-1 do
    begin
      if (Owner.Components[I] is TioCustomConnectionDef) and (Owner.Components[I] <> Self) then
      begin
        LConnectionDef := TioCustomConnectionDef(Owner.Components[I]);
        LConnectionDef.DefaultConnection := False;
      end;
    end;
    // If not in design or load mode the
    //  NB: Messo anche qui perch� venga impostata la connessione di default anche a runtime
    if not (  (csDesigning in ComponentState) or (csLoading in ComponentState)   ) then
      TioConnectionManager.SetDefaultConnectionName(Self.Name);
  end;
end;

(*&&&& inizio
{ TioRESTConnectionDef }

constructor TioRESTConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  Persistent := True;
end;

procedure TioRESTConnectionDef.RegisterConnectionDef;
begin
  TioConnectionManager.NewRESTConnection(BaseURL, DefaultConnection, Persistent, Name);
  // NB: Inherited must be the last line (set FIsRegistered)
  inherited;
end;

{ TioSQLiteConnectionDef }

constructor TioSQLiteConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  AutoCreateDatabase := True;
end;

procedure TioSQLiteConnectionDef.RegisterConnectionDef;
begin
  ConnectionDef := TioConnectionManager.NewSQLiteConnectionDef(GetFullPathDatabase, DefaultConnection, Persistent, Pooled, Name);
  // Encript
  if not Encrypt.IsEmpty then
    ConnectionDef.Params.Values['Encrypt'] := Encrypt;
  // NewPassword
  if not NewPassword.IsEmpty then
    ConnectionDef.Params.NewPassword := NewPassword;
  // Password
  if not Password.IsEmpty then
    ConnectionDef.Params.Password := Password;
  // NB: Inherited must be the last line (set FIsRegistered)
  inherited;
end;

{ TioFirebirdConnectionDef }

constructor TioFirebirdConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  Port := 3050;
end;

procedure TioFirebirdConnectionDef.RegisterConnectionDef;
begin
  ConnectionDef := TioConnectionManager.NewFirebirdConnectionDef(Server,
    GetFullPathDatabase, UserName, Password, CharSet, DefaultConnection,
    Persistent, Pooled, Name);
  // OSAuthent
  case OSAuthent of
    TioOSAuthent.oaNo:  ConnectionDef.Params.Values['OSAuthent'] := 'No';
    TioOSAuthent.oaYes: ConnectionDef.Params.Values['OSAuthent'] := 'Yes';
  end;
  // Port
  ConnectionDef.Params.Values['Port'] := Port.ToString;
  // Protocol
  case Protocol of
    TioProtocol.pTCPIP:   ConnectionDef.Params.Values['Protocol'] := 'TCPIP';
    TioProtocol.pLocal:   ConnectionDef.Params.Values['Protocol'] := 'Local';
    TioProtocol.pNetBEUI: ConnectionDef.Params.Values['Protocol'] := 'NetBEUI';
    TioProtocol.pSPX:     ConnectionDef.Params.Values['Protocol'] := 'SPX';
  end;
  // SQL dialect
  case SQLDialect of
    TioSQLDialect.sqlDialect3: ConnectionDef.Params.Values['SQLDialect'] := '3';
    TioSQLDialect.sqlDialect2: ConnectionDef.Params.Values['SQLDialect'] := '2';
    TioSQLDialect.sqlDialect1: ConnectionDef.Params.Values['SQLDialect'] := '1';
  end;
  // NB: Inherited must be the last line (set FIsRegistered)
  inherited;
end;

{ TioSQLServerConnectionDef }

procedure TioSQLServerConnectionDef.RegisterConnectionDef;
begin
  ConnectionDef := TioConnectionManager.NewSQLServerConnectionDef(Server,
    GetFullPathDatabase, UserName, Password, DefaultConnection,
    Persistent, Pooled, Name);
  // Encript
  if not Encrypt.IsEmpty then
    ConnectionDef.Params.Values['Encrypt'] := Encrypt;
  // OSAuthent
  case OSAuthent of
    TioOSAuthent.oaNo:  ConnectionDef.Params.Values['OSAuthent'] := 'No';
    TioOSAuthent.oaYes: ConnectionDef.Params.Values['OSAuthent'] := 'Yes';
  end;
  // NB: Inherited must be the last line (set FIsRegistered)
  inherited;
end;

//%%%% inizio
{ TioOracleConnectionDef }

procedure TioOracleConnectionDef.RegisterConnectionDef;
begin
  ConnectionDef := TioConnectionManager.NewOracleConnectionDef(Database,
    UserName, Password, DefaultConnection,
    Persistent, Pooled, Name);
{  %%%%%%%
 //Encript
  if not Encrypt.IsEmpty then
    ConnectionDef.Params.Values['Encrypt'] := Encrypt;
  // OSAuthent
  case OSAuthent of
    TioOSAuthent.oaNo:  ConnectionDef.Params.Values['OSAuthent'] := 'No';
    TioOSAuthent.oaYes: ConnectionDef.Params.Values['OSAuthent'] := 'Yes';
  end;
  // NB: Inherited must be the last line (set FIsRegistered)
}
  inherited;
end;

{ TioPostgresConnectionDef }

constructor TioPostgresConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  Port := 5432;
end;

procedure TioPostgresConnectionDef.RegisterConnectionDef;
begin
  ConnectionDef := TioConnectionManager.NewPostgresConnectionDef(Server,Database,
    UserName, Password, DefaultConnection,
    Persistent, Pooled, Name);
  ConnectionDef.Params.Values['Port'] := Port.ToString;
{  %%%%%%%
 //Encript
  if not Encrypt.IsEmpty then
    ConnectionDef.Params.Values['Encrypt'] := Encrypt;
  // OSAuthent
  case OSAuthent of
    TioOSAuthent.oaNo:  ConnectionDef.Params.Values['OSAuthent'] := 'No';
    TioOSAuthent.oaYes: ConnectionDef.Params.Values['OSAuthent'] := 'Yes';
  end;
  // NB: Inherited must be the last line (set FIsRegistered)
}
  inherited;
end;
//%%%% fine

{ TioMySQLConnectionDef }

constructor TioMySQLConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  Port := 3306;
end;

procedure TioMySQLConnectionDef.RegisterConnectionDef;
begin
  ConnectionDef := TioConnectionManager.NewMySQLConnectionDef(Server,
    GetFullPathDatabase, UserName, Password, CharSet, DefaultConnection,
    Persistent, Pooled, Name);
  // Port
  ConnectionDef.Params.Values['Port'] := Port.ToString;
  // NB: Inherited must be the last line (set FIsRegistered)
  inherited;
end;
*)

{ TioSQLMonitor }

constructor TioSQLMonitor.Create(AOwner: TComponent);
begin
  inherited;
  FMode := TioMonitorMode.mmDisabled;
end;

procedure TioSQLMonitor.SetMode(const Value: TioMonitorMode);
begin
  FMode := Value;
{$IFDEF MSWINDOWS}
  // Set the monitor mode
  if not (csDesigning in ComponentState) then
    io.Connections.Monitor.Mode := FMode;
{$ENDIF}
end;

end.

