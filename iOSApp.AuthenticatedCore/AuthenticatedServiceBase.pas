namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  Foundation,
  iOSApp.Core,
  iOSApp.AuthenticatedCore.Models,
  iOSApp.AuthenticatedCore.Storage,
  UIKit;

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

    property AppDelegate:AuthenticationAppDelegate read
      begin
        exit (UIApplication.sharedApplication.&delegate) as AuthenticationAppDelegate;
      end;
  protected
    property AuthenticationService:AuthenticationService read
      begin
        exit AppDelegate.AuthenticationService;
      end;


  public
    property &delegate:IServiceEvents;

    property Storage:AuthenticatedStorageBase read;


    property AccessToken:String read
      begin

        var authenticated := Storage.AuthenticatedUser;
        if(assigned(authenticated))then
        begin
          if(AppDelegate.AuthenticationService.Expired)then
          begin
            NSLog('token has expired, call refresh...');
            AppDelegate.AuthenticationService.refresh;
          end;
          exit AppDelegate.AuthenticationService.AccessToken;
        end
        else
        begin
          NSLog('Not authenticated, no accessToken');
        end;
        exit '';

      end;


  end;

end.