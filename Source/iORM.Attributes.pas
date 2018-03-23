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



unit iORM.Attributes;

interface

uses
  iORM.CommonTypes, System.UITypes, ObjMapper.Attributes;

type

  // destination event for VM action
  TioActionEvent = (Null, OnExecute, OnUpdate, OnHint);

  // Type of class mapping
  TioMapModeType = (ioProperties, ioFields);

  // Relation types
  TioRelationType = (ioRTNone, ioRTBelongsTo, ioRTHasMany, ioRTHasOne, ioRTEmbeddedHasMany, ioRTEmbeddedHasOne);

  // LazyLoad
  TioLoadType = (ioImmediateLoad = 0, ioLazyLoad);

  // Join types
  TioJoinType = (ioInner, ioCross, ioLeftOuter, ioRightOuter, ioFullOuter);

  // ===========================================================================
  // START BASE ATTRIBUTES
  // ---------------------------------------------------------------------------

  // Base simple attribute
  TioCustomAttribute = class(TCustomAttribute)
  end;

  // Base String attribute
  TioCustomStringAttribute = class(TCustomAttribute)
  strict private
    FValue: String;
  public
    constructor Create(const AValue:String='');
    property Value:String read FValue;
  end;

  // Base integer attribute
  TioCustomIntegerAttribute = class(TCustomAttribute)
  strict private
    FValue: Integer;
  public
    constructor Create(const AValue:Integer);
    property Value:Integer read FValue;
  end;

  // Base boolean attribute
  TioCustomBoolAttribute = class(TCustomAttribute)
  strict private
    FValue: Boolean;
  public
    constructor Create(const AValue:Boolean);
    property Value:Boolean read FValue;
  end;

  // Base class for relation attribute
  TioCustomRelationAttribute = class(TioCustomAttribute)
  strict private
    FChildTypeName: String;
    FChildTypeAlias: String;
  public
    constructor Create(AChildClassRef:TioClassRef); overload;
    constructor Create(const AChildTypeName:String; const AChildTypeAlias:String=''); overload;
    property ChildTypeName: String read FChildTypeName;
    property ChildTypeAlias: String read FChildTypeAlias;
  end;

  // Standard AttributeLabel
  ioMarker = class(TioCustomStringAttribute)
  end;

  TioCustomForTargetModelClass = class(TioCustomAttribute)
  strict private
    FTargetClassName: String;
    FAlias: String;
  public
    constructor Create(ATargetClassName:String; const AAlias:String=''); overload;
    constructor Create(ATargetClass:TioClassRef; const AAlias:String=''); overload;
    property TargetClassName:String read FTargetClassName;
    property Alias:String read FAlias;
  end;

  // ---------------------------------------------------------------------------
  // END BASE ATTRIBUTES
  // ===========================================================================





  // ===========================================================================
  // START MVVM ATTRIBUTES
  // ---------------------------------------------------------------------------

   ioBindAction = class(TioCustomStringAttribute)
   end;

  //  NB: Questo metodo � stato aggiunto (con il relativo attributo "ioUniBindAction" perch�
  //       si � visto che nel caso delle TUniForm e TUniFrame gli attributi relativi ai campi
  //       non vengono creati e quindi l'attributo "ioBindAction" era inefficace. Per�
  //       si era notato che invece gli attributi della classe (non del campo) venivano creati
  //       e quindi si � aggiunto l'attributo "ioUniBindAction" da usare appunto sulla classe
  //       invece che sul controllo.
   ioUniBindAction = class(TioCustomAttribute)
   strict private
     FControlName: String;
     FCommandName: String;
   public
     constructor Create(const AControlName, ACommandName:String);
     property ControlName:String read FControlName;
     property CommandName:String read FCommandName;
   end;

   ioAction = class(TioCustomAttribute)
   private
     FName: String;
     FCaption: String;
     FEvent: TioActionEvent;
   public
     constructor Create(const AName, ACaption:String; const AEvent:TioActionEvent=TioActionEvent.Null); overload;
     constructor Create(const AName:String; const AEvent:TioActionEvent=TioActionEvent.Null); overload;
     property Name:String read FName;
     property Caption:String read FCaption;
     property Event:TioActionEvent read FEvent;
   end;

   ioCommand = class(TioCustomAttribute)
   private
     FName: String;
   public
     constructor Create(const AName: String);
     property Name:String read FName;
   end;

   ioDisabled = class(TioCustomAttribute)
   end;

   ioChecked = class(TioCustomAttribute)
   end;

   ioGroupIndex = class(TioCustomIntegerAttribute)
   end;

   ioHint = class(TioCustomStringAttribute)
   end;

   ioImageIndex = class(TioCustomIntegerAttribute)
   end;

   ioInvisible = class(TioCustomAttribute)
   end;

   ioNotificationTarget = class(TioCustomAttribute)
   end;

  // ---------------------------------------------------------------------------
  // END MVVM ATTRIBUTES
  // ===========================================================================





  // ===========================================================================
  // START PROPERTY ATTRIBUTES
  // ---------------------------------------------------------------------------

  // Skip attribute
  ioSkip = class(TioCustomAttribute)
  end;

  // ID attribute
  ioOID = class(TioCustomAttribute)
  strict private
    FSkipOnInsert: Boolean;
  public
    constructor Create(const ASkipOnInsert:Boolean=True);
    property SkipOnInsert:Boolean read FSkipOnInsert;
  end;

  // FieldName attribute
  ioField = class(TioCustomStringAttribute)
  end;

  // FieldName attribute
  ioLoadSQL = class(TioCustomStringAttribute)
  end;

  // FieldType attribute
  ioFieldType = class(TioCustomStringAttribute)
  end;

  // Relation BelongsTo attribute
  ioBelongsTo = class(TioCustomRelationAttribute)
  end;

  // Relation HasMany attribute
  ioHasMany = class(TioCustomRelationAttribute)
  strict private
    FChildPropertyName: String;
    FLoadType: TioLoadType;
    FAutoIndex: Boolean;
  public
    constructor Create(const AChildClassRef:TioClassRef; const AChildPropertyName:String; const ALoadType:TioLoadType=ioImmediateLoad; const AAutoIndex:Boolean=True); overload;
    constructor Create(const AChildTypeName, AChildTypeAlias, AChildPropertyName:String; const ALoadType:TioLoadType=ioImmediateLoad; const AAutoIndex:Boolean=True); overload;
    constructor Create(const AChildTypeName, AChildPropertyName:String; const ALoadType:TioLoadType=ioImmediateLoad; const AAutoIndex:Boolean=True); overload;
    property ChildPropertyName: String read FChildPropertyName;
    property LoadType: TioLoadType read FLoadType;
    property AutoIndex: Boolean read FAutoIndex;
  end;

  // Relation BelongsTo attribute
  ioHasOne = class(ioHasMany)
  end;

  // ReadOnly attribute
  ioReadOnly = class(TioCustomAttribute)
  end;

  // WriteOnly attribute
  ioWriteOnly = class(TioCustomAttribute)
  end;

  // TypeAlias attribute
  ioTypeAlias = class(TioCustomStringAttribute)
  end;

  // ---------------------------------------------------------------------------
  // END PROPERTY ATTRIBUTES
  // ===========================================================================




  // ===========================================================================
  // START CLASS ATTRIBUTES
  // ---------------------------------------------------------------------------

  // Table & Entity attribute
  ioTable = class(TioCustomStringAttribute)
  strict private
    FMapMode: TioMapModeType;
  public
    constructor Create(const AValue:String=''; const AMapMode:TioMapModeType=ioProperties); overload;
    constructor Create(const AMapMode:TioMapModeType); overload;
    property MapMode: TioMapModeType read FMapMode;
  end;
  ioEntity = class(ioTable)
  end;

//%%%%%% inizio
  ioTableAbbr = class(TioCustomStringAttribute)
  end;

  ioEntityAbbr = class(ioTableAbbr)
  end;
//%%%%%%% fine

  // KeyGeneratorName attribute
  ioKeyGenerator = class(TioCustomStringAttribute)
  end;

  // ConnectionDefName attribute
  ioConnectionDefName = class(TioCustomStringAttribute)
  end;

  // ClassFromField
  ioClassFromField = class(TioCustomAttribute)
  end;
  ioTrueClass = ioClassFromField;

  // GroupBy
  ioGroupBy = class(TioCustomStringAttribute)
  end;

  // Join attribute
  ioJoin = class(TioCustomAttribute)
  strict private
    FJoinType: TioJoinType;
    FJoinClassRef: TioClassRef;
    FJoinCondition: String;
  public
    constructor Create(const AJoinType:TioJoinType; AJoinClassRef:TioClassRef; AJoinCondition:String='');
    property JoinType: TioJoinType read FJoinType;
    property JoinClassRef: TioClassRef read FJoinClassRef;
    property JoinCondition: String read FJoinCondition;
  end;

  // Indexes attribute
  ioIndex = class(TioCustomAttribute)
  strict private
    FIndexName: String;
    FCommaSepFieldList: String;
    FIndexOrientation: TioIndexOrientation;
    FUnique: Boolean;
  public
    constructor Create(const AIndexName:String; ACommaSepFieldList:String; const AIndexOrientation:TioIndexOrientation=ioAscending; const AUnique:Boolean=False); overload;
    constructor Create(ACommaSepFieldList:String; const AIndexOrientation:TioIndexOrientation=ioAscending; const AUnique:Boolean=False); overload;
    constructor Create(const AIndexOrientation:TioIndexOrientation=ioAscending; const AUnique:Boolean=False); overload;
    property IndexName:String read FIndexName;
    property CommaSepFieldList:String read FCommaSepFieldList write FCommaSepFieldList;
    property IndexOrientation:TioIndexOrientation read FIndexOrientation;
    property Unique:Boolean read FUnique;
  end;

  // KeyGeneratorName attribute
  ioDisableAutoCreateDB = class(TioCustomAttribute)
  end;

  // DIC - diRegister attribute (register the class as is, without interfaces)
  diRegister = class(TioCustomAttribute)
  end;

  // DIC - diImplements attribute
  diImplements = class(TioCustomAttribute)
  strict private
    FIID: TGUID;
    FAlias: String;
  public
    constructor Create(AIID:TGUID; const AAlias:String='');
    property IID:TGUID read FIID;
    property Alias:String read FAlias;
  end;

  // DIC - diAsSingleton attribute
  diAsSingleton = class(TioCustomAttribute)
  end;

  // DIC - diViewFor(TargetModelClassName) (register the calss as View for the TargetModelClassName)
  diViewFor = class(TioCustomForTargetModelClass)
  end;

  // DIC - diViewModelFor(TargetModelClassName) (register the calss as View for the TargetModelClassName)
  diViewModelFor = class(TioCustomForTargetModelClass)
  end;
  // ---------------------------------------------------------------------------
  // END CLASS ATTRIBUTES
  // ===========================================================================




  // ===========================================================================
  // START EMBEDDED ATTRIBUTES
  // ---------------------------------------------------------------------------

  // EmbeddedHasMany attribute
  ioEmbeddedHasMany = class(TioCustomRelationAttribute)

  end;

  // EmbeddedHasOne attribute
  ioEmbeddedHasOne = class(TioCustomRelationAttribute)

  end;

  // EmbeddedSkip attribute
  ioEmbeddedSkip = class(DoNotSerializeAttribute)  // from DMVC ObjectsMappers

  end;

  // EmbeddedSkip attribute
  ioEmbeddedStreamable = class(StreamableAttribute)  // from DMVC ObjectsMappers

  end;

  // ---------------------------------------------------------------------------
  // end EMBEDDED ATTRIBUTES
  // ===========================================================================




  // ===========================================================================
  // START DEPENDENCY INJECTION ATTRIBUTES
  // ---------------------------------------------------------------------------

  // ioInject attribute
  ioInject = class(TioCustomAttribute)
  strict private
    FTypeName: String;
    FTypeAlias: String;
  public
    constructor Create(const ATypeAlias:String=''); overload;
    constructor Create(const ATypeName, ATypeAlias:String); overload;
    property TypeName:String read FTypeName;
    property TypeAlias:String read FTypeAlias;
  end;

  // ---------------------------------------------------------------------------
  // END DEPENDENCY INJECTION ATTRIBUTES
  // ===========================================================================


implementation

uses
  System.SysUtils, iORM.Rtti.Utilities;

{ TioStringAttribute }

constructor TioCustomStringAttribute.Create(const AValue: String);
begin
  FValue := AValue;
end;

{ ioSkip }

{ TCustomRelationAttribute }

constructor TioCustomRelationAttribute.Create(AChildClassRef: TioClassRef);
begin
  Create(AChildClassRef.ClassName, '');
end;

constructor TioCustomRelationAttribute.Create(const AChildTypeName, AChildTypeAlias: String);
begin
  FChildTypeName := AChildTypeName;
  FChildTypeAlias := AChildTypeAlias;
end;

{ ioHasMany }

constructor ioHasMany.Create(const AChildClassRef: TioClassRef;
  const AChildPropertyName: String; const ALoadType:TioLoadType=ioImmediateLoad; const AAutoIndex:Boolean=True);
begin
  inherited Create(AChildClassRef);
  FChildPropertyName := AChildPropertyName;
  FLoadType := ALoadType;
  FAutoIndex := AAutoIndex;
end;


constructor ioHasMany.Create(const AChildTypeName, AChildTypeAlias, AChildPropertyName: String; const ALoadType: TioLoadType; const AAutoIndex:Boolean);
begin
  inherited Create(AChildTypeName, AChildTypeAlias);
  FChildPropertyName := AChildPropertyName;
  FLoadType := ALoadType;
  FAutoIndex := AAutoIndex;
end;

constructor ioHasMany.Create(const AChildTypeName, AChildPropertyName: String; const ALoadType: TioLoadType; const AAutoIndex:Boolean);
begin
  Self.Create(AChildTypeName, '', AChildPropertyName, ALoadType);
  FAutoIndex := AAutoIndex;
end;

{ ioJoin }

constructor ioJoin.Create(const AJoinType: TioJoinType;
  AJoinClassRef: TioClassRef; AJoinCondition: String);
begin
  inherited Create;
  FJoinType := AJoinType;
  FJoinClassRef := AJoinClassRef;
  FJoinCondition := AJoinCondition;
end;

{ ioTable }

constructor ioTable.Create(const AValue:String; const AMapMode: TioMapModeType);
begin
  inherited Create(AValue);
  FMapMode := AMapMode;
end;

constructor ioTable.Create(const AMapMode: TioMapModeType);
begin
  inherited Create('');
  FMapMode := AMapMode;
end;

{ ioIndex }

constructor ioIndex.Create(const AIndexName: String; ACommaSepFieldList: String;
  const AIndexOrientation: TioIndexOrientation; const AUnique: Boolean);
begin
  inherited Create;
  FIndexName := AIndexName;
  FCommaSepFieldList := ACommaSepFieldList;
  FIndexOrientation := AIndexOrientation;
  FUnique := AUnique;
end;

constructor ioIndex.Create(ACommaSepFieldList: String;
  const AIndexOrientation: TioIndexOrientation; const AUnique: Boolean);
begin
  Self.Create('', ACommaSepFieldList, AIndexOrientation, AUnique);
end;

constructor ioIndex.Create(const AIndexOrientation: TioIndexOrientation;
  const AUnique: Boolean);
begin
  Self.Create('', '', AIndexOrientation, AUnique);
end;

{ ioInject }

constructor ioInject.Create(const ATypeAlias: String);
begin
  inherited Create;
  FTypeName := '';
  FTypeAlias := ATypeAlias;
end;

constructor ioInject.Create(const ATypeName, ATypeAlias: String);
begin
  Self.Create(ATypeAlias);
  FTypeName := ATypeName;
end;


{ TioCustomIntegerAttribute }

constructor TioCustomIntegerAttribute.Create(const AValue: Integer);
begin
  FValue := AValue;
end;

{ TioCustomBoolAttribute }

constructor TioCustomBoolAttribute.Create(const AValue: Boolean);
begin
  FValue := AValue;
end;

{ ioAction }

constructor ioAction.Create(const AName, ACaption: String;
  const AEvent: TioActionEvent);
begin
  inherited Create;
  FName := AName;
  FCaption := ACaption;
  FEvent := AEvent;
end;

constructor ioAction.Create(const AName: String; const AEvent: TioActionEvent);
begin
  Self.Create(AName, '', AEvent);
end;

{ ioCommand }

constructor ioCommand.Create(const AName: String);
begin
  FName := AName;
end;

{ ioSkip }

{ ioOID }

constructor ioOID.Create(const ASkipOnInsert: Boolean);
begin
  inherited Create;
  FSkipOnInsert := ASkipOnInsert;
end;

{ diImplements }

constructor diImplements.Create(AIID:TGUID; const AAlias:String);
begin
  inherited Create;
  FIID := AIID;
  FAlias := AAlias;
end;

{ diViewFor }

constructor TioCustomForTargetModelClass.Create(ATargetClassName: String; const AAlias: String);
begin
  inherited Create;
  FTargetClassName := ATargetClassName;
  FAlias := AAlias;
end;

constructor TioCustomForTargetModelClass.Create(ATargetClass: TioClassRef;
  const AAlias: String);
begin
  inherited Create;
  FTargetClassName := ATargetClass.ClassName;
  FAlias := AAlias;
end;


{ ioUniBindAction }

constructor ioUniBindAction.Create(const AControlName, ACommandName: String);
begin
  inherited Create;
  FControlName := AControlName;
  FCommandName := ACommandName;
end;

end.
