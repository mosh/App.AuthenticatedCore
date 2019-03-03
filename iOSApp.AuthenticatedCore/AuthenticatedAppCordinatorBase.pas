namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  iOSApp.Core,
  Moshine.Foundation,
  UIKit;

type

  AuthenticatedAppCoordinatorBase = public abstract class(AppCordinatorBase, IAuthenticationInterestedParty,IServiceEvents)

  private

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


  protected
    interestedService:IAuthenticationInterestedService;

    method loadAuthenticationValues: tuple of (clientId:String, issuer:String, redirect:String, stateKey:String);abstract;

  public

    property AuthenticationService:AuthenticationService read begin
        exit AuthenticationAppDelegate(UIApplication.sharedApplication.&delegate).AuthenticationService;
      end;


    method initWithAppDelegate(appDelegate: not nullable IUIApplicationDelegate) withServiceRequiringAuthentication(service:AuthenticatedServiceBase) : InstanceType;
    begin
      self := initWithAppDelegate(appDelegate);

      if(assigned(self))then
      begin

        self.AuthenticationService.&delegate := self;

        self.interestedService := service;

        service.&delegate := self;

        var values := loadAuthenticationValues;
        self.AuthenticationService.Setup(values.issuer, values.clientId, values.redirect, values.stateKey);


      end;

      exit self;
    end;

  end;

end.