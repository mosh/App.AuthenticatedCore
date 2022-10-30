namespace App.AuthenticatedCore;

uses
  AppAuth.Authentication;

type

  IAuthenticationInterestedService = public interface(IAuthenticationInterestedParty)
    property EventReceiver:IServiceEvents;
  end;

end.