namespace iOSApp.AuthenticatedCore.Storage;

uses
  iOSApp.AuthenticatedCore.Models,
  iOSApp.Core.Storage,
  Realm;

type

  AuthenticatedStorageBase = public class(StorageBase)

  public

    method MergeAuthenticated(auth:Authenticated);
    begin
      var currentAuthenticated := AuthenticatedUser;

      if(assigned(currentAuthenticated))then
      begin

        if(currentAuthenticated.Email = auth.Email)then
        begin
          RLMRealm.defaultRealm.beginWriteTransaction;
          RLMRealm.defaultRealm.addOrUpdateObject(auth);
          RLMRealm.defaultRealm.commitWriteTransaction;
        end
        else
        begin
          RLMRealm.defaultRealm.deleteObject(currentAuthenticated);
          RLMRealm.defaultRealm.beginWriteTransaction;
          RLMRealm.defaultRealm.addOrUpdateObject(auth);
          RLMRealm.defaultRealm.commitWriteTransaction;
        end;
      end
      else
      begin
        RLMRealm.defaultRealm.beginWriteTransaction;
        RLMRealm.defaultRealm.addOrUpdateObject(auth);
        RLMRealm.defaultRealm.commitWriteTransaction;
      end;
    end;

    method clearMySettings; virtual;
    begin
      var defaultRealm := RLMRealm.defaultRealm;

      defaultRealm.beginWriteTransaction;
      defaultRealm.deleteObjects(Authenticated.allObjectsInRealm(defaultRealm));
      defaultRealm.commitWriteTransaction;

    end;

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