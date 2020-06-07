namespace iOSApp.AuthenticatedCore.Models;

uses
  Foundation,
  iOSApp.Core.Storage.Data;

type

  Claim = public class(DataObject)
  public
    property ClaimTypeId:Integer;
    property Claim:String;

    class method primaryKey: NSString; override;
    begin
      exit 'ClaimTypeId';
    end;

  end;

end.