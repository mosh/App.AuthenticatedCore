namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  Foundation,
  iOSApp.Core,
  iOSApp.AuthenticatedCore.Models,
  iOSApp.AuthenticatedCore.Storage,
  UIKit;

type

  AuthenticatedServiceBase = public class(ServiceBase,IAuthenticationInterestedService)
  protected

    method newSession(auth:Authenticated); virtual;
    begin
      Authorized(auth);
    end;

    method noSession; virtual;
    begin
    end;

    method clearMySettings; virtual;
    begin
      self.AuthenticationService.clear;
      Storage.clearMySettings;

    end;



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

    method Authorized(auth:Authenticated; overwrite:Boolean := false );
    begin
      var authenticated := Storage.AuthenticatedUser;
      var updatedStore := false;

      if(assigned(authenticated))then
      begin
        if(authenticated.Email <> auth.Email)then
        begin

          if(overwrite = false)then
          begin
            &delegate:OnAuthorizingDifference(authenticated.Email, auth.Email);
          end
          else
          begin
            Storage.MergeAuthenticated(auth);
            clearMySettings;
            updatedStore := true;
          end;

        end
        else
        begin
          Storage.MergeAuthenticated(auth);
          updatedStore := true;
        end;

      end
      else
      begin
        Storage.MergeAuthenticated(auth);
        updatedStore := true;
      end;

      if(updatedStore)then
      begin
        self.delegate:OnAuthorized;
      end;
    end;

  end;

end.