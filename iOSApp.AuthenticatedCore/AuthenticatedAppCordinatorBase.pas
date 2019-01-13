namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  iOSApp.Core,
  Moshine.Foundation,
  UIKit;

type

  AuthenticatedAppCoordinatorBase = public class(AppCordinatorBase, IAuthenticationInterestedParty,IServiceEvents)

  private
    interestedService:IAuthenticationInterestedService;

    method stateChanged(info:UserInfo);
    begin
      interestedService.stateChanged(info);
    end;

    method OnError(e:Exception);
    begin

      if(e is NoNetworkConnectionException)then
      begin
        var found := FindUIViewController;

        if assigned(found) then
        begin
          UIViewController(found).displayAlertForException(e);
          exit;
        end;
      end;

      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin
        if receiver.respondsToSelector(selector(OnError:))then
        begin
          receiver.OnError(e);
        end;
      end;
    end;

    method OnNotAuthorized(initiatedAction:InitiatedActionEnumeration);
    begin
      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin
        if receiver.respondsToSelector(selector(OnNotAuthorized:))then
        begin
          IAuthorizedServiceEventReceiver(receiver).OnNotAuthorized(initiatedAction);
        end;

      end;
    end;


    method OnAuthorized;
    begin
      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin
        if receiver.respondsToSelector(selector(OnAuthorized))then
        begin
          IAuthorizedServiceEventReceiver(receiver).OnAuthorized;
        end;

      end;
    end;

    method OnAuthorizingDifference (newEmail:NSString; oldEmail:NSString):Boolean;
    begin
      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin
        if receiver.respondsToSelector(selector(OnAuthorizingWithNewEmail:fromOldEmail:))then
        begin
          IAuthorizedServiceEventReceiver(receiver).OnAuthorizingWithNewEmail(newEmail) fromOldEmail(oldEmail);
        end;

      end;

    end;

    method initWithAppDelegate(appDelegate: not nullable IUIApplicationDelegate): instancetype;
    begin
      inherited initWithAppDelegate(appDelegate);
    end;




  public

    method initWithAppDelegate(appDelegate: not nullable IUIApplicationDelegate) withServiceRequiringAuthentication(service:AuthenticatedServiceBase) : instancetype;
    begin
      self := initWithAppDelegate(appDelegate);

      if(assigned(self))then
      begin
        self.interestedService := service;
        AuthenticationService.Instance.&delegate := self;

        service.&delegate := self;


      end;

      exit self;
    end;

  end;

end.