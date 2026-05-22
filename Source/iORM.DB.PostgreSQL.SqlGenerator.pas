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
unit iORM.DB.PostgreSQL.SqlGenerator;

interface

uses
  System.Classes, System.SysUtils,
  iORM.DB.SqLite.SqlGenerator, iORM.DB.Interfaces,
  iORM.Context.Interfaces, iORM.CommonTypes;

type

  // Classe che genera il codice SQL delle query per PostgreSQL.
  // Eredita da TioSqlGenerator (via SQLite che e' la classe base piu' completa)
  // e sovrascrive i metodi che differiscono rispetto alla sintassi PostgreSQL.
  TioSqlGeneratorPostgreSQL = class(TioSqlGenerator)
  public
    // Ritorna il timestamp corrente (sintassi PostgreSQL: SELECT NOW())
    class procedure GenerateSqlCurrentTimestamp(const AQuery: IioQuery); override;

    // Verifica se un record esiste (usa CAST ... AS INTEGER per coerenza)
    class procedure GenerateSqlExists(const AQuery: IioQuery; const AContext: IioContext); override;

    // Genera il comando per leggere il valore dell'ID appena inserito.
    // PostgreSQL usa "SELECT lastval()" oppure RETURNING (qui usiamo lastval).
    class procedure GenerateSqlNextID(const AQuery: IioQuery; const AContext: IioContext); override;

    // DROP INDEX: in PostgreSQL l'indice non e' legato alla tabella
    class procedure GenerateSqlDropIndex(const AQuery: IioQuery; const AContext: IioContext;
      AIndexName: String); override;

    // CREATE INDEX con sintassi PostgreSQL (ASC/DESC inline, no ASCENDING/DESCENDING)
    class procedure GenerateSqlCreateIndex(const AQuery: IioQuery; const AContext: IioContext;
      AIndexName: String; const ACommaSepFieldList: String;
      const AIndexOrientation: TioIndexOrientation; const AUnique: Boolean); override;
  end;

implementation

uses
  iORM.SqlTranslator;

{ TioSqlGeneratorPostgreSQL }

class procedure TioSqlGeneratorPostgreSQL.GenerateSqlCurrentTimestamp(const AQuery: IioQuery);
begin
  AQuery.SQL.Add('SELECT NOW()');
end;

class procedure TioSqlGeneratorPostgreSQL.GenerateSqlExists(const AQuery: IioQuery;
  const AContext: IioContext);
begin
  AQuery.SQL.Add(
    'SELECT CAST(CASE WHEN EXISTS (SELECT 1 FROM ' + AContext.GetTable.GetSql +
    ' WHERE ' + AContext.GetProperties.GetIdProperty.GetSqlQualifiedFieldName +
    '=:' + AContext.GetProperties.GetIdProperty.GetSqlWhereParamName +
    ') THEN 1 ELSE 0 END AS INTEGER)'
  );
end;

class procedure TioSqlGeneratorPostgreSQL.GenerateSqlNextID(const AQuery: IioQuery;
  const AContext: IioContext);
begin
  // PostgreSQL: dopo un INSERT con SERIAL/SEQUENCE si recupera l'ultimo ID
  // generato nella sessione corrente con lastval().
  // NOTA: se si usa GENERATED ALWAYS AS IDENTITY si puo' usare ugualmente lastval().
  AQuery.SQL.Add('SELECT lastval()');
end;

class procedure TioSqlGeneratorPostgreSQL.GenerateSqlDropIndex(const AQuery: IioQuery;
  const AContext: IioContext; AIndexName: String);
begin
  // In PostgreSQL DROP INDEX non richiede il nome della tabella
  AIndexName := TioSqlTranslator.Translate(AIndexName, AContext.GetClassRef.ClassName, False);
  AQuery.SQL.Add('DROP INDEX IF EXISTS ' + AIndexName);
end;

class procedure TioSqlGeneratorPostgreSQL.GenerateSqlCreateIndex(const AQuery: IioQuery;
  const AContext: IioContext; AIndexName: String; const ACommaSepFieldList: String;
  const AIndexOrientation: TioIndexOrientation; const AUnique: Boolean);
var
  LFieldList: TStrings;
  LQueryText, LIndexOrientationText, LField, LUniqueText: String;
begin
  // Index Name
  if AIndexName.IsEmpty then
    AIndexName := Self.BuildIndexName(AContext, ACommaSepFieldList, AIndexOrientation, AUnique)
  else
    AIndexName := TioSqlTranslator.Translate(AIndexName, AContext.GetClassRef.ClassName, False);

  // PostgreSQL usa ASC/DESC inline (come MS SQL Server)
  case AIndexOrientation of
    ioAscending:  LIndexOrientationText := ' ASC';
    ioDescending: LIndexOrientationText := ' DESC';
  else
    LIndexOrientationText := '';
  end;

  // UNIQUE keyword
  if AUnique then
    LUniqueText := 'UNIQUE '
  else
    LUniqueText := '';

  // Field list
  LFieldList := TStringList.Create;
  try
    LFieldList.Delimiter := ',';
    LFieldList.DelimitedText := ACommaSepFieldList;
    LQueryText := '';
    for LField in LFieldList do
    begin
      if not LQueryText.IsEmpty then
        LQueryText := LQueryText + ', ';
      LQueryText := LQueryText + LField + LIndexOrientationText;
    end;
  finally
    LFieldList.Free;
  end;

  // Compose & translate
  LQueryText := 'CREATE ' + LUniqueText + 'INDEX ' + AIndexName +
    ' ON ' + AContext.GetTable.TableName + ' (' + LQueryText + ')';
  LQueryText := TioSqlTranslator.Translate(LQueryText, AContext.GetClassRef.ClassName, False);
  AQuery.SQL.Add(LQueryText);
end;

end.
