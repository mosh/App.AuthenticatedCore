namespace iOSApp.AuthenticatedCore.Models;

uses
  Foundation,
  iOSApp.Core.Storage.Data;

type

  Claim = public class(DataObject)
  public
    property UserId:Integer;
    property Name:NSString;
    property Id:Integer;
    class method primaryKey: NSString; override;
    begin
      exit 'Id';
    end;
  end;

end.