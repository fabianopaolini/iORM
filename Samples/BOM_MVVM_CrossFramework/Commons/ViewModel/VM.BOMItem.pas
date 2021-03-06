unit VM.BOMItem;

interface

uses
  System.SysUtils, System.Classes, iORM.MVVM.ViewModelBase, Model.BOMItems,
  iORM.MVVM.Components.ModelPresenter, iORM.Attributes;

type

  [diViewModelFor(TBOMItemMaterial)]
  [diViewModelFor(TBOMItemProcess)]
  [diViewModelFor(TBOMItemProduct)]
  TBOMItemVM = class(TioViewModel)
    MPBOMItem: TioModelPresenter;
    MPBOMArticle: TioModelPresenter;
  private
    { Private declarations }
  public
    { Public declarations }
    [ioAction('acEditArticle', 'Show', OnExecute)]
    procedure acEditArticleExecute(Sender: TObject);

    [ioAction('acPost', 'Post', OnExecute)]
    procedure acPostExecute(Sender: TObject);
    [ioAction('acPost', OnUpdate)]
    procedure acPostUpdate(Sender: TObject);

//    [ioAction('acClose', OnExecute)]
    procedure acCloseExecute(Sender: TObject);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses
  iORM, V.Interfaces;


{$R *.dfm}

{ TBOMItemVM }

procedure TBOMItemVM.acCloseExecute(Sender: TObject);
begin
  FreeViews;
end;

procedure TBOMItemVM.acEditArticleExecute(Sender: TObject);
//var
//  LAlias: String;
begin
  inherited;


  io.di.LocateViewVMfor(MPBOMArticle.Current)
    .SetPresenter('MPArticle', MPBOMArticle)
    .Show;


//  LAlias := MPBOMArticle.Current.ClassName;
//  io.di.LocateViewVM<IArticleView,IArticleVM>(LAlias, LAlias).SetPresenter('MPArticle', MPBOMArticle).Show;
end;

procedure TBOMItemVM.acPostExecute(Sender: TObject);
begin
  if MPBOMItem.Editing then
    MPBOMItem.Post;
end;

procedure TBOMItemVM.acPostUpdate(Sender: TObject);
begin
  Command['acPost'].Enabled :=  MPBOMItem.Editing;
end;

end.
