inherited ArticleViewModel: TArticleViewModel
  OldCreateOrder = True
  object MPArticle: TioModelPresenter
    AsDefault = True
    Async = True
    AutoLoadData = True
    AutoPersist = True
    AutoRefreshOnNotification = arEnabledNoReload
    TypeName = 'IBase'
    ViewDataType = dtList
    WhereDetailsFromDetailAdapters = False
    Left = 192
    Top = 24
  end
end
