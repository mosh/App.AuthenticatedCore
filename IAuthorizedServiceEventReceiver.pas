namespace iOSApp.AuthenticatedCore;

uses
  Foundation,
  iOSApp.Core;

type

  IAuthorizedServiceEventReceiver = public interface(IServiceEventReceiver)
    method OnNotAuthorized(initiatedAction:InitiatedActionEnumeration); {$IF TOFFEE}optional;{$ENDIF}
    method OnAuthorized; {$IF TOFFEE}optional;{$ENDIF}
    method OnAuthorizingWithNewEmail(newEmail:NSString) fromOldEmail(oldEmail:NSString):Boolean; {$IF TOFFEE}optional;{$ENDIF}
  end;


end.