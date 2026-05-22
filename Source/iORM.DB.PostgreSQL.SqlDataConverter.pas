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
unit iORM.DB.PostgreSQL.SqlDataConverter;

interface

uses
  iORM.DB.Interfaces, iORM.Context.Properties.Interfaces, System.Rtti,
  iORM.Context.Interfaces, iORM.DB.Firebird.SqlDataConverter;

type

  // Classe che si occupa di convertire i dati per la compilazione dell'SQL
  // PostgreSQL usa lo stesso formato datetime di Firebird, ma:
  // - i nomi dei campi devono essere tra doppi apici se sono case-sensitive
  // - le date usano il formato ISO 8601: 'YYYY-MM-DD HH:NN:SS'
  TioSqlDataConverterPostgreSQL = class(TioSqlDataConverterFirebird)
  public
    class function TValueToSql(const AValue: TValue): String; override;
    class function FieldNameToSqlFieldName(const AFieldName: string): string; override;
  end;

implementation

uses
  System.TypInfo, System.SysUtils, iORM.CommonTypes;

{ TioSqlDataConverterPostgreSQL }

// PostgreSQL usa i doppi apici per i nomi di campo (case-sensitive)
// Per compatibilita' con iORM lasciamo i nomi as-is (senza quoting)
// a meno che non contengano caratteri speciali.
// Se vuoi forzare il quoting, decommenta la riga con i doppi apici.
class function TioSqlDataConverterPostgreSQL.FieldNameToSqlFieldName(const AFieldName: string): string;
begin
  // Result := '"' + AFieldName + '"';  // Forza case-sensitive (opzionale)
  Result := AFieldName;
end;

class function TioSqlDataConverterPostgreSQL.TValueToSql(const AValue: TValue): String;
begin
  // Usa il risultato della classe antenata e ne modifica solo i tipi data/ora
  Result := inherited TValueToSql(AValue);
  // PostgreSQL usa il formato ISO 8601 per le date
  if (AValue.TypeInfo.Kind = tkFloat) then
  begin
    if (AValue.TypeInfo = System.TypeInfo(TDate)) then
      Result := QuotedStr(FormatDateTime('yyyy-mm-dd', AValue.AsExtended))
    else if (AValue.TypeInfo = System.TypeInfo(TTime)) then
      Result := QuotedStr(FormatDateTime('hh:nn:ss', AValue.AsExtended))
    else if (AValue.TypeInfo = System.TypeInfo(TDateTime))
         or (AValue.TypeInfo = System.TypeInfo(TioObjUpdated))
         or (AValue.TypeInfo = System.TypeInfo(TioObjCreated)) then
      Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', AValue.AsExtended));
  end;
end;

end.
