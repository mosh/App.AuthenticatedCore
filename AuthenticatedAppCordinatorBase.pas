namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  AppAuth.Authentication.Models,
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

    method OnError(e:NSException);
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

        {$IF TOFFEE}
        if receiver.respondsToSelector(selector(OnError:))then
        begin
          receiver.OnError(e);
        end;
        {$ENDIF}
        {$IF ISLAND}
        receiver.OnError(e);
        {$ENDIF}


      end;
    end;

    method OnNotAuthorized(initiatedAction:InitiatedActionEnumeration);
    begin
      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin
        {$IF TOFFEE}
        if receiver.respondsToSelector(selector(OnNotAuthorized:))then
        begin
          IAuthorizedServiceEventReceiver(receiver).OnNotAuthorized(initiatedAction);
        end;
        {$ENDIF}
        {$IF ISLAND}
        IAuthorizedServiceEventReceiver(receiver).OnNotAuthorized(initiatedAction);
        {$ENDIF}
      end;
    end;


    method OnAuthorized;
    begin
      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin

        {$IF TOFFEE}
        if receiver.respondsToSelector(selector(OnAuthorized))then
        begin
          IAuthorizedServiceEventReceiver(receiver).OnAuthorized;
        end;
        {$ENDIF}
        {$IF ISLAND}
        IAuthorizedServiceEventReceiver(receiver).OnAuthorized;
        {$ENDIF}

      end;
    end;

    method OnAuthorizingDifference (newEmail:NSString; oldEmail:NSString):Boolean;
    begin
      var receiver:IServiceEventReceiver := FindReceiver;

      if(assigned(receiver))then
      begin

        {$IF TOFFEE}
        if receiver.respondsToSelector(selector(OnAuthorizingWithNewEmail:fromOldEmail:))then
        begin
          IAuthorizedServiceEventReceiver(receiver).OnAuthorizingWithNewEmail(newEmail) fromOldEmail(oldEmail);
        end;
        {$ENDIF}
        {$IF ISLAND}
        IAuthorizedServiceEventReceiver(receiver).OnAuthorizingWithNewEmail(newEmail) fromOldEmail(oldEmail);
        {$ENDIF}

      end;

    end;


  protected
    interestedService:IAuthenticationInterestedService;

    method loadAuthenticationValues: tuple of (clientId:String, issuer:String, redirect:String, stateKey:String);abstract;

  public

    property AuthenticationService:AuthenticationService read begin
        exit AuthenticationAppDelegate(UIApplication.sharedApplication.&delegate).AuthenticationService;
      end;

    method initialize(service:AuthenticatedServiceBase);
    begin
      self.AuthenticationService.&delegate := self;

      self.interestedService := service;

      service.&delegate := self;

      var values := loadAuthenticationValues;
      self.AuthenticationService.setup(values.issuer, values.clientId, values.redirect, values.stateKey);

    end;


    constructor WithAppDelegate(appDelegate: not nullable IUIApplicationDelegate) withServiceRequiringAuthentication(service:AuthenticatedServiceBase);
    begin
      inherited constructor WithAppDelegate(appDelegate);

      initialize(service);
    end;

    constructor WithNavigationController(navigationController:UINavigationController) Window(window:UIWindow) AppDelegate(appDelegate: not nullable IUIApplicationDelegate) ServiceRequiringAuthentication(service:AuthenticatedServiceBase);
    begin

      inherited constructor WithNavigationController(navigationController) Window(window) AppDelegate(appDelegate);

      initialize(service);
    end;




  end;

end.