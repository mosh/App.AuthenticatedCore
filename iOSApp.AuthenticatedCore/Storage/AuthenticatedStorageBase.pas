namespace iOSApp.AuthenticatedCore.Storage;

uses
  iOSApp.AuthenticatedCore.Models,
  iOSApp.Core.Storage,
  Realm.Realm;

type

  AuthenticatedStorageBase = public class(StorageBase)

  public
    method AuthenticatedUser:Authenticated;
    begin
      var all := Authenticated.allObjectsInRealm(RLMRealm.defaultRealm);
      if(all.count > 0)then
      begin
        exit all[0];
      end
      else
      begin
        exit nil;
      end;
    end;

  end;

end.