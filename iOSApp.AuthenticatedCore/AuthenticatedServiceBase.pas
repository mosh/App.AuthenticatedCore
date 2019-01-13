namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  iOSApp.Core,
  iOSApp.AuthenticatedCore.Models;

type

  AuthenticatedServiceBase = public abstract class(ServiceBase,IAuthenticationInterestedService)
  protected
    method newSession(auth:Authenticated); abstract;
    method noSession; abstract;

  private
    {IAuthenticationInterestedService}
    method stateChanged(info:UserInfo);
    begin
      if(assigned(info))then
      begin

        var auth := new Authenticated;
        auth.Name := info.Name;
        auth.Email := info.Email;
        auth.GivenName := info.GivenName;
        auth.FamilyName := info.FamilyName;
        auth.Gender := info.Gender;

        newSession(auth);
      end
      else
      begin
        noSession;
      end;

    end;

  public
    property &delegate:IServiceEvents;

  end;

end.