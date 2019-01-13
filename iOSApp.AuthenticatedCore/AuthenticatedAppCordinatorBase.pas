namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  iOSApp.Core,
  UIKit;

type

  AuthenticatedAppCoordinatorBase = public class(AppCordinatorBase, IAuthenticationInterestedParty)

  private
    interestedService:IAuthenticationInterestedService;

    method stateChanged(info:UserInfo);
    begin
      interestedService.stateChanged(info);
    end;


  public

    method initWithAppDelegate(appDelegate: not nullable IUIApplicationDelegate) withServiceRequiringAuthentication(service:IAuthenticationInterestedService) : instancetype;
    begin
      self := inherited initWithAppDelegate(appDelegate);

      if(assigned(self))then
      begin
        self.interestedService := service;
        AuthenticationService.Instance.&delegate := self;

      end;

      exit self;
    end;

  end;

end.