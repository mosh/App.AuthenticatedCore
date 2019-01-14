namespace iOSApp.AuthenticatedCore;

uses
  AppAuth.Authentication,
  Foundation,
  iOSApp.Core,
  iOSApp.AuthenticatedCore.Models,
  iOSApp.AuthenticatedCore.Storage,
  Moshine.Foundation,
  RemObjects.Elements.RTL,
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

    method executeBlock(someBlock:block):operationTypesEnumeration;
    begin
      try
        someBlock;
        exit operationTypesEnumeration.completed;
      except
        on a:AuthenticationRequiredException do
        begin
          exit operationTypesEnumeration.authenticationRequired;
        end;
        on e:NSException do
        begin
          exit operationTypesEnumeration.exception;
        end;
      end;
    end;


    method Handle(someCode:block; initiatedAction:InitiatedActionEnumeration := InitiatedActionEnumeration.Unknown);
    begin

      var outerExecutionBlock: NSBlockOperation := NSBlockOperation.blockOperationWithBlock(method()
      begin

        var value := AccessToken;

        if(String.IsNullOrEmpty(value))then
        begin

          NSOperationQueue.mainQueue().addOperationWithBlock(method()
          begin
            &delegate:OnNotAuthorized(initiatedAction);
          end);
        end
        else
        begin

          try
            someCode;

          except
            on a:AuthenticationRequiredException do
            begin
              NSOperationQueue.mainQueue().addOperationWithBlock(method()
              begin
                &delegate:OnNotAuthorized(initiatedAction);
              end);
            end;
            on h:HttpStatusCodeException do
            begin

              NSOperationQueue.mainQueue().addOperationWithBlock(method()
              begin
                &delegate:OnError(h);
              end);


            end;
            on e:NSException do
            begin

              NSOperationQueue.mainQueue().addOperationWithBlock(method()
              begin
                &delegate:OnError(e);
              end);

            end;
          end;

        end;

      end);

      workerQueue.addOperation(outerExecutionBlock);

    end;

    method anyExceptions(values:array of Integer):Boolean;
    begin
      for each value in values do
        begin
        if value = operationTypesEnumeration.exception then
        begin
          exit true;
        end;
      end;
      exit false;

    end;

    method anyCantContinue(values:array of Integer):Boolean;
    begin
      for each value in values do
        begin
        if value = operationTypesEnumeration.UnableToContinue then
        begin
          exit true;
        end;
      end;
      exit false;

    end;


    method anyAuthenticationRequired(values:array of Integer):Boolean;
    begin
      for each value in values do
      begin
        if value = operationTypesEnumeration.authenticationRequired then
        begin
          exit true;
        end;
      end;
      exit false;
    end;


    method Ready:Boolean;
    begin
      exit assigned(AccessToken) and (AccessToken.Length > 0);
    end;


  public
    property &delegate:IServiceEvents;

    method Storage:AuthenticatedStorageBase; reintroduce;
    begin
      exit inherited Storage as AuthenticatedStorageBase;
    end;


    method currentAuthenticated:Authenticated;
    begin
      exit Storage.AuthenticatedUser;
    end;

    property localUser:Boolean read
      begin
        exit assigned(Storage.AuthenticatedUser);
      end;


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

    method Startup(results:array of Integer; callback:StartupDelegate; buildStartup:BuildStartupDelegate; reload:Boolean);
    begin


      var outerExecutionBlock: NSBlockOperation := NSBlockOperation.blockOperationWithBlock(method
      begin

        var auth := Storage.AuthenticatedUser;

        if ((not assigned(auth)) and (offline))then
        begin

          NSOperationQueue.mainQueue().addOperationWithBlock(method()
          begin
            var e:= new NoNetworkConnectionException withName('ProxyException') reason('Authentication required but no network connection') userInfo(nil) ;
            &delegate:OnError(e);
          end);

          for each &result in results do
            begin
            &result := operationTypesEnumeration.UnableToContinue;
            end;

        end
        else if((not assigned(auth)) or (assigned(auth) and reload ))then
        begin

          var assignedAccessToken := self.AuthenticationService.AccessToken;

          if(String.IsNullOrEmpty(assignedAccessToken))then
          begin
            NSLog('No access token not requesting data');

            for each &result in results do
              begin
              &result := operationTypesEnumeration.authenticationRequired;
              end;

          end
          else
          begin

            var innerExecutionBlock := buildStartup();

            var innerQueue: NSOperationQueue := new NSOperationQueue();
            innerQueue.addOperation(innerExecutionBlock);
            innerQueue.waitUntilAllOperationsAreFinished;

          end;

        end
        else
        begin
          NSLog('Found Auth row');

          for each &result in results do
            begin
            &result := operationTypesEnumeration.completed;
            end;

        end;

        if(anyCantContinue(results))then
        begin
        end
        else if(anyExceptions(results))then
        begin

          NSOperationQueue.mainQueue().addOperationWithBlock(method()
          begin
            &delegate:OnError(nil);
          end);

        end
        else if(anyAuthenticationRequired(results))then
        begin
          NSOperationQueue.mainQueue().addOperationWithBlock(method()
          begin
            &delegate:OnNotAuthorized(InitiatedActionEnumeration.Startup);
          end);
        end
        else
        begin
          NSOperationQueue.mainQueue().addOperationWithBlock(method()
            begin
              callback;
              end);

      end;

      end);

      workerQueue.addOperation(outerExecutionBlock);

    end;


  end;

end.