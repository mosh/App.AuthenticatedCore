namespace iOSApp.AuthenticatedCore;

type

  IAuthorizedServiceEventReceiver = public interface(IServiceEventReceiver)
    method OnNotAuthorized(initiatedAction:InitiatedActionEnumeration); optional;
    method OnAuthorized; optional;
    method OnAuthorizingWithNewEmail(newEmail:NSString) fromOldEmail(oldEmail:NSString):Boolean; optional;
  end;



end.