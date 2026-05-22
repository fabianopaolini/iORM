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
unit iORM.DBBuilder.SqlGenerator.PostgreSQL;

interface

uses
  iORM.DBBuilder.SqlGenerator.Base, iORM.DBBuilder.Interfaces, iORM.Attributes;

const
  INVALID_FIELDTYPE_CONVERSIONS =
    '[timestamp->numeric][timestamp->integer][date->numeric][date->integer]' +
    '[time->numeric][time->decimal][time->integer][varchar->numeric][varchar->integer]' +
    '[varchar->date][varchar->time][varchar->timestamp][char->numeric][char->integer]' +
    '[char->date][char->time][char->timestamp]';

type

  TioDBBuilderSqlGenPostgreSQL = class(TioDBBuilderSqlGenBase, IioDBBuilderSqlGenerator)
  private
    function TranslateFieldTypeForCreate(const AField: IioDBBuilderSchemaField): String;
    function TranslateFieldTypeForModified(const AField: IioDBBuilderSchemaField): String;
    function InternalCreateField(const AField: IioDBBuilderSchemaField): String;
  public
    // Database related methods
    function DatabaseExists: Boolean;
    procedure CreateDatabase;
    // Tables related methods
    function TableExists(const ATable: IioDBBuilderSchemaTable): Boolean;
    procedure BeginCreateTable(const ATable: IioDBBuilderSchemaTable);
    procedure EndCreateTable(const ATable: IioDBBuilderSchemaTable);
    procedure BeginAlterTable(const ATable: IioDBBuilderSchemaTable);
    procedure EndAlterTable(const ATable: IioDBBuilderSchemaTable);
    // Fields related methods
    function FieldExists(const ATable: IioDBBuilderSchemaTable; const AField: IioDBBuilderSchemaField): Boolean;
    function FieldModified(const ATable: IioDBBuilderSchemaTable; const AField: IioDBBuilderSchemaField): Boolean;
    procedure CreateField(const AField: IioDBBuilderSchemaField; ACommaBefore: Char);
    procedure AddField(const AField: IioDBBuilderSchemaField; ACommaBefore: Char);
    procedure AlterField(const AField: IioDBBuilderSchemaField; ACommaBefore: Char);
    // PrimaryKey & other indexes
    procedure AddPrimaryKey(ATable: IioDBBuilderSchemaTable);
    procedure AddIndex(const ATable: IioDBBuilderSchemaTable; const AIndex: ioIndex);
    procedure DropAllIndexes;
    // Foreign keys
    procedure AddForeignKey(const AForeignKey: IioDBBuilderSchemaFK);
    procedure DropAllForeignKeys;
    // Sequences
    procedure AddSequence(const ASequenceName: String; const ACreatingNewDatabase: Boolean);
  end;

implementation

uses
  iORM.Context.Properties.Interfaces, iORM.Exceptions, System.SysUtils,
  iORM.DB.Factory, iORM.DB.Interfaces, System.StrUtils, iORM.CommonTypes,
  iORM.SqlTranslator;

{ TioDBBuilderSqlGenPostgreSQL }

// ---------------------------------------------------------------------------
// FIELD TYPES
// ---------------------------------------------------------------------------

function TioDBBuilderSqlGenPostgreSQL.TranslateFieldTypeForCreate(const AField: IioDBBuilderSchemaField): String;
begin
  case AField.FieldType of
    ioMdVarchar:
      Result := Format('VARCHAR(%d)', [AField.FieldLength]);
    ioMdChar:
      Result := Format('CHAR(%d)', [AField.FieldLength]);
    ioMdInteger:
      Result := 'INTEGER';
    ioMdFloat:
      Result := 'DOUBLE PRECISION';
    ioMdDate:
      Result := 'DATE';
    ioMdTime:
      Result := 'TIME';
    ioMdDateTime:
      Result := 'TIMESTAMP';
    ioMdDecimal:
      Result := Format('DECIMAL(%d,%d)', [AField.FieldPrecision, AField.FieldScale]);
    ioMdNumeric:
      Result := Format('NUMERIC(%d,%d)', [AField.FieldPrecision, AField.FieldScale]);
    ioMdBoolean:
      // PostgreSQL ha un tipo BOOLEAN nativo, ma iORM usa SMALLINT per coerenza con gli altri driver.
      Result := 'SMALLINT';
    ioMdBinary:
      Result := 'BYTEA';
    ioMdCustomFieldType:
      Result := AField.FieldCustomType;
  else
    raise EioGenericException.Create(ClassName, 'TranslateFieldTypeForCreate', 'Wrong Metadata_FieldType');
  end;
end;

function TioDBBuilderSqlGenPostgreSQL.TranslateFieldTypeForModified(const AField: IioDBBuilderSchemaField): String;
begin
  // Restituisce il nome del tipo cosi' come lo riporta information_schema.columns (data_type),
  // in modo che FieldModified possa confrontarlo direttamente con quanto letto dal DB.
  case AField.FieldType of
    ioMdVarchar:         Result := 'character varying';
    ioMdChar:            Result := 'character';
    ioMdInteger:         Result := 'integer';
    ioMdFloat:           Result := 'double precision';
    ioMdDate:            Result := 'date';
    ioMdTime:            Result := 'time without time zone';
    ioMdDateTime:        Result := 'timestamp without time zone';
    ioMdDecimal:         Result := 'numeric';
    ioMdNumeric:         Result := 'numeric';
    ioMdBoolean:         Result := 'smallint';
    ioMdBinary:          Result := 'bytea';
    ioMdCustomFieldType: Result := AField.FieldCustomType;
  else
    raise EioGenericException.Create(ClassName, 'TranslateFieldTypeForModified', 'Wrong Metadata_FieldType');
  end;
end;

function TioDBBuilderSqlGenPostgreSQL.InternalCreateField(const AField: IioDBBuilderSchemaField): String;
var
  LDefault: String;
  LNotNull: String;
begin
  // Per la PK usiamo SERIAL (auto-increment nativo PostgreSQL).
  // Il DEFAULT non si applica alla PK: SERIAL gestisce gia' la sequence internamente.
  if AField.PrimaryKey then
    Exit(Format('%s SERIAL NOT NULL', [AField.FieldName]));
  // Campi normali: default e not null come gli altri driver
  LDefault := ExtractFieldDefaultValue(AField);
  LNotNull  := IfThen(AField.FieldNotNull, 'NOT NULL', '');
  Result := Format('%s %s %s %s', [AField.FieldName, TranslateFieldTypeForCreate(AField), LDefault, LNotNull]).Trim;
end;

// ---------------------------------------------------------------------------
// DATABASE
// ---------------------------------------------------------------------------

function TioDBBuilderSqlGenPostgreSQL.DatabaseExists: Boolean;
begin
  // Tenta di aprire una query sul db; se fallisce la connessione non riesce
  // ad aprirsi (db non esiste o credenziali errate).
  try
    OpenQuery('SELECT 1');
    Result := True;
  except
    Result := False;
  end;
end;

procedure TioDBBuilderSqlGenPostgreSQL.CreateDatabase;
begin
  // In PostgreSQL CREATE DATABASE non puo' essere eseguito dentro una transazione.
  // Si assume che la connessione punti al db di sistema "postgres" (o "template1").
  // L'utente deve creare il DB manualmente o usare questa chiamata solo in quel contesto.
  ExecuteQuery(FSchema.ConnectionDefName,
    Format('CREATE DATABASE "%s"', [FSchema.DatabaseFileName]));
end;

// ---------------------------------------------------------------------------
// TABLES
// ---------------------------------------------------------------------------

function TioDBBuilderSqlGenPostgreSQL.TableExists(const ATable: IioDBBuilderSchemaTable): Boolean;
var
  LQuery: IioQuery;
begin
  // information_schema.tables: i nomi tabella in PG sono case-sensitive ma
  // per convenzione iORM li crea in minuscolo; ToLower garantisce il match.
  LQuery := OpenQuery(Format(
    'SELECT table_name FROM information_schema.tables ' +
    'WHERE table_schema = ''public'' AND table_name = ''%s''',
    [ATable.TableName.ToLower]));
  Result := not (LQuery.Eof or LQuery.Fields[0].IsNull);
end;

procedure TioDBBuilderSqlGenPostgreSQL.BeginCreateTable(const ATable: IioDBBuilderSchemaTable);
begin
  ScriptAdd(Format('CREATE TABLE %s (', [ATable.TableName]));
  IncIndentationLevel;
end;

procedure TioDBBuilderSqlGenPostgreSQL.EndCreateTable(const ATable: IioDBBuilderSchemaTable);
begin
  DecIndentationLevel;
  ScriptAdd(');');
end;

procedure TioDBBuilderSqlGenPostgreSQL.BeginAlterTable(const ATable: IioDBBuilderSchemaTable);
begin
  ScriptAdd(Format('ALTER TABLE %s', [ATable.TableName]));
  IncIndentationLevel;
end;

procedure TioDBBuilderSqlGenPostgreSQL.EndAlterTable(const ATable: IioDBBuilderSchemaTable);
begin
  DecIndentationLevel;
  ScriptAdd(';');
end;

// ---------------------------------------------------------------------------
// FIELDS
// ---------------------------------------------------------------------------

function TioDBBuilderSqlGenPostgreSQL.FieldExists(const ATable: IioDBBuilderSchemaTable;
  const AField: IioDBBuilderSchemaField): Boolean;
var
  LQuery: IioQuery;
begin
  LQuery := OpenQuery(Format(
    'SELECT column_name FROM information_schema.columns ' +
    'WHERE table_schema = ''public'' AND table_name = ''%s'' AND column_name = ''%s''',
    [ATable.TableName.ToLower, AField.FieldName.ToLower]));
  Result := not (LQuery.Eof or LQuery.Fields[0].IsNull);
end;

function TioDBBuilderSqlGenPostgreSQL.FieldModified(const ATable: IioDBBuilderSchemaTable;
  const AField: IioDBBuilderSchemaField): Boolean;
var
  LQuery: IioQuery;
  LOldFieldType: String;
  LNewFieldType: String;
  LOldFieldLength: Smallint;
  LOldFieldPrecision: Smallint;
  LOldFieldDecimals: Smallint;
  LOldFieldNotNull: Boolean;
begin
  Result := False;
  LQuery := OpenQuery(Format(
    'SELECT data_type, character_maximum_length, numeric_precision, numeric_scale, is_nullable ' +
    'FROM information_schema.columns ' +
    'WHERE table_schema = ''public'' AND table_name = ''%s'' AND column_name = ''%s''',
    [ATable.TableName.ToLower, AField.FieldName.ToLower]));
  if LQuery.Eof then
    Exit;

  LOldFieldType      := LQuery.Fields.FieldByName('data_type').AsString.ToLower;
  LNewFieldType      := TranslateFieldTypeForModified(AField).ToLower;
  LOldFieldLength    := LQuery.Fields.FieldByName('character_maximum_length').AsInteger;
  LOldFieldPrecision := LQuery.Fields.FieldByName('numeric_precision').AsInteger;
  LOldFieldDecimals  := LQuery.Fields.FieldByName('numeric_scale').AsInteger;
  // is_nullable restituisce 'YES' o 'NO'
  LOldFieldNotNull   := SameText(LQuery.Fields.FieldByName('is_nullable').AsString, 'NO');

  // Tipo cambiato?
  Result := Result or IsFieldTypeChanged(LOldFieldType, LNewFieldType, AField, ATable, INVALID_FIELDTYPE_CONVERSIONS);
  // Lunghezza cambiata (solo per varchar/char)?
  if 'character varying,character'.Contains(LOldFieldType) then
    Result := Result or IsFieldLengthChanged(LOldFieldLength, AField.FieldLength, AField, ATable);
  // Precision/scale cambiati (solo per numeric/decimal)?
  if 'numeric'.Contains(LOldFieldType) then
  begin
    Result := Result or IsFieldPrecisionChanged(LOldFieldPrecision, AField.FieldPrecision, AField, ATable);
    Result := Result or IsFieldDecimalsChanged(LOldFieldDecimals, AField.FieldScale, AField, ATable);
  end;
  // NotNull cambiato? (PostgreSQL supporta SET/DROP NOT NULL, quindi e' permesso)
  Result := Result or IsFieldNotNullChanged(LOldFieldNotNull, AField.FieldNotNull, AField, ATable, True);
end;

procedure TioDBBuilderSqlGenPostgreSQL.CreateField(const AField: IioDBBuilderSchemaField;
  ACommaBefore: Char);
begin
  ScriptAdd(Format('%s%s', [ACommaBefore, InternalCreateField(AField)]));
end;

procedure TioDBBuilderSqlGenPostgreSQL.AddField(const AField: IioDBBuilderSchemaField;
  ACommaBefore: Char);
begin
  // In ALTER TABLE ... ADD COLUMN ogni ADD e' un comando separato
  ScriptAdd(Format('%s ADD COLUMN %s', [ACommaBefore, InternalCreateField(AField)]));
end;

procedure TioDBBuilderSqlGenPostgreSQL.AlterField(const AField: IioDBBuilderSchemaField;
  ACommaBefore: Char);
begin
  // PostgreSQL richiede clausole ALTER COLUMN separate per tipo, DEFAULT e NOT NULL.
  // Il motore iORM chiama AlterField solo quando FieldModified = True, e il set
  // AField.Altered indica quali aspetti sono cambiati.
  if alFieldType in AField.Altered then
  begin
    ScriptAdd(Format('%s ALTER COLUMN %s TYPE %s',
      [ACommaBefore, AField.FieldName, TranslateFieldTypeForCreate(AField)]));
    ACommaBefore := ',';
  end;
  if alFieldDefault in AField.Altered then
  begin
    if AField.FieldDefaultExists then
      ScriptAdd(Format('%s ALTER COLUMN %s SET %s',
        [ACommaBefore, AField.FieldName, ExtractFieldDefaultValue(AField)]))
    else
      ScriptAdd(Format('%s ALTER COLUMN %s DROP DEFAULT',
        [ACommaBefore, AField.FieldName]));
    ACommaBefore := ',';
  end;
  if alFieldNotNull in AField.Altered then
    ScriptAdd(Format('%s ALTER COLUMN %s %s NOT NULL',
      [ACommaBefore, AField.FieldName, IfThen(AField.FieldNotNull, 'SET', 'DROP')]));
end;

// ---------------------------------------------------------------------------
// PRIMARY KEY & INDEXES
// ---------------------------------------------------------------------------

procedure TioDBBuilderSqlGenPostgreSQL.AddPrimaryKey(ATable: IioDBBuilderSchemaTable);
begin
  ScriptAdd(Format('ALTER TABLE %s ADD CONSTRAINT PK_%s PRIMARY KEY (%s);',
    [ATable.TableName, ATable.TableName, ATable.PrimaryKeyField.FieldName]));
end;

procedure TioDBBuilderSqlGenPostgreSQL.AddIndex(const ATable: IioDBBuilderSchemaTable;
  const AIndex: ioIndex);
var
  LQuery, LIndexName, LFieldList, LUnique: String;
begin
  LIndexName := BuildIndexName(ATable, AIndex);
  LUnique    := BuildIndexUnique(AIndex);
  LFieldList := BuildIndexFieldList(ATable, AIndex, LIndexName, True);
  // IF NOT EXISTS disponibile da PG 9.5+
  LQuery := Format('CREATE %s INDEX IF NOT EXISTS %s ON %s (%s);',
    [LUnique, LIndexName, ATable.TableName, LFieldList]);
  ScriptAdd(LQuery);
end;

procedure TioDBBuilderSqlGenPostgreSQL.DropAllIndexes;
var
  LQuery: IioQuery;
begin
  // pg_indexes esclude automaticamente gli indici di PK/UK (gestiti come constraint).
  // Droppiamo solo quelli con prefisso IDX_ creati da iORM.
  LQuery := NewQuery;
  LQuery.SQL.Add('SELECT indexname FROM pg_indexes');
  LQuery.SQL.Add('WHERE schemaname = ''public''');
  LQuery.SQL.Add('  AND indexname LIKE ''IDX_%''');
  LQuery.Open;
  while not LQuery.Eof do
  begin
    // IF EXISTS evita errori se l'indice e' gia' stato rimosso
    ScriptAdd(Format('DROP INDEX IF EXISTS %s;', [LQuery.Fields[0].AsString]));
    LQuery.Next;
  end;
end;

// ---------------------------------------------------------------------------
// FOREIGN KEYS
// ---------------------------------------------------------------------------

procedure TioDBBuilderSqlGenPostgreSQL.AddForeignKey(const AForeignKey: IioDBBuilderSchemaFK);
begin
  ScriptAdd(Format('ALTER TABLE %s', [AForeignKey.DependentTableName]));
  IncIndentationLevel;
  ScriptAdd(Format(' ADD CONSTRAINT %s', [AForeignKey.Name]));
  IncIndentationLevel;
  ScriptAdd(Format('FOREIGN KEY (%s)', [AForeignKey.DependentFieldName]));
  ScriptAdd(Format('REFERENCES  %s (%s)',
    [AForeignKey.ReferenceTableName, AForeignKey.ReferenceFieldName]));
  if AForeignKey.OnUpdateAction > fkUnspecified then
    ScriptAdd(Format('ON UPDATE %s', [TranslateFKAction(AForeignKey, AForeignKey.OnUpdateAction)]));
  if AForeignKey.OnDeleteAction > fkUnspecified then
    ScriptAdd(Format('ON DELETE %s', [TranslateFKAction(AForeignKey, AForeignKey.OnDeleteAction)]));
  DecIndentationLevel;
  DecIndentationLevel;
  ScriptAdd(';');
end;

procedure TioDBBuilderSqlGenPostgreSQL.DropAllForeignKeys;
var
  LQuery: IioQuery;
begin
  // Recupera tutti i constraint FK con prefisso FK_ nello schema public
  LQuery := NewQuery;
  LQuery.SQL.Add('SELECT tc.table_name, tc.constraint_name');
  LQuery.SQL.Add('FROM information_schema.table_constraints tc');
  LQuery.SQL.Add('WHERE tc.constraint_schema = ''public''');
  LQuery.SQL.Add('  AND tc.constraint_type = ''FOREIGN KEY''');
  LQuery.SQL.Add('  AND tc.constraint_name LIKE ''FK_%''');
  LQuery.Open;
  while not LQuery.Eof do
  begin
    ScriptAdd(Format('ALTER TABLE %s DROP CONSTRAINT %s;',
      [LQuery.Fields.FieldByName('table_name').AsString,
       LQuery.Fields.FieldByName('constraint_name').AsString]));
    LQuery.Next;
  end;
end;

// ---------------------------------------------------------------------------
// SEQUENCES
// ---------------------------------------------------------------------------

procedure TioDBBuilderSqlGenPostgreSQL.AddSequence(const ASequenceName: String;
  const ACreatingNewDatabase: Boolean);
begin
  // In PostgreSQL il tipo SERIAL (usato per la PK in InternalCreateField)
  // crea automaticamente la sequence sottostante: nessuna azione necessaria.
end;

end.
