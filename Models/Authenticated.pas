namespace iOSApp.AuthenticatedCore.Models;

uses
  Foundation,
  iOSApp.Core.Storage.Data;

type

  Authenticated = public class(DataObject)
  public
    property Email:NSString;
    property Name:NSString;
    property GivenName:NSString;
    property FamilyName:NSString;
    property Gender:NSString;

    class method primaryKey: NSString; override;
    begin
      exit 'Email';
    end;
  end;

end.