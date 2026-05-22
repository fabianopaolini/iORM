{
  ****************************************************************************
  *                                                                          *
  *           iORM - (interfaced ORM)                                        *
  *                                                                          *
  *           Copyright (C) 2015-2023 Maurizio Del Magno                     *
  *                                                                          *
  *           mauriziodm@levantesw.it                                        *
  *           mauriziodelmagno@gmail.com                                     *
  *           https://github.com/mauriziodm/iORM.git                         *
  *                                                                          *
  ****************************************************************************
  *                                                                          *
  * This file is part of iORM (Interfaced Object Relational Mapper).         *
  *                                                                          *
  * Licensed under the GNU Lesser General Public License, Version 3;         *
  *  you may not use this file except in compliance with the License.        *
  *                                                                          *
  * iORM is free software: you can redistribute it and/or modify             *
  * it under the terms of the GNU Lesser General Public License as published *
  * by the Free Software Foundation, either version 3 of the License, or     *
  * (at your option) any later version.                                      *
  *                                                                          *
  * iORM is distributed in the hope that it will be useful,                  *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of           *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
  * GNU Lesser General Public License for more details.                      *
  *                                                                          *
  * You should have received a copy of the GNU Lesser General Public License *
  * along with iORM.  If not, see <http://www.gnu.org/licenses/>.            *
  *                                                                          *
  ****************************************************************************
}
unit iORM.DB.ConnectionDef.PostgreSQL;

interface

uses
  FireDAC.Phys.PG,   // Driver FireDAC per PostgreSQL - richiede il pacchetto FireDAC PG
  iORM.DB.ConnectionDef,
  System.SysUtils,
  iORM.DBBuilder.Interfaces;

type

  // Componente di configurazione connessione PostgreSQL per iORM.
  // Da inserire nella palette Delphi/FMX accanto agli altri TioXxxConnectionDef.
  //
  // Prerequisiti:
  //   1. FireDAC con driver PostgreSQL installato (FireDAC.Phys.PG)
  //   2. Libreria client PostgreSQL (libpq.dll su Windows) accessibile nel PATH
  //
  // Uso minimo a runtime (senza componente):
  //   io.Connections.NewPostgreSQLConnectionDef('localhost', 'mydb', 'postgres', 'secret');
  //
  TioPostgreSQLConnectionDef = class(TioCustomConnectionDef)
  private
    FPort: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RegisterConnectionDef; override;
    function DBBuilder: IioDBBuilderEngine; override;
  published
    // Standard iORM connection properties
    property AsDefault;
    property AutoCreateDB;
    property Database;
    property Password;
    property Persistent;
    property Pooled;
    property Server;
    property UserName;
    property SynchroStrategy_Client;
    // Events
    property OnAfterCreateOrAlterDB;
    property OnBeforeCreateOrAlterDB;
    // PostgreSQL-specific
    property Port: Integer read FPort write FPort default 5432;
  end;

implementation

uses
  iORM.DB.ConnectionContainer;

{ TioPostgreSQLConnectionDef }

constructor TioPostgreSQLConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  FPort := 5432;
end;

function TioPostgreSQLConnectionDef.DBBuilder: IioDBBuilderEngine;
begin
  inherited;
  // Only to elevate method visibility (same pattern as other ConnectionDef classes)
end;

procedure TioPostgreSQLConnectionDef.RegisterConnectionDef;
begin
  // Fire the OnBeforeRegister event if implemented
  DoBeforeRegister;
  // Register the ConnectionDef via TioConnectionManager
  ConnectionDef := TioConnectionManager.NewPostgreSQLConnectionDef(
    Server,
    Database,
    UserName,
    Password,
    AsDefault,
    SynchroStrategy_Client,
    Persistent,
    Pooled,
    Name
  );
  // Override the port if different from the default
  if FPort <> 5432 then
    ConnectionDef.Params.Values['Port'] := FPort.ToString;
  // NB: Inherited must be the last call (sets FIsRegistered)
  inherited;
end;

end.
