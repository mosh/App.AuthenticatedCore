namespace iOSApp.AuthenticatedCore;

uses
  Foundation,
  Moshine.Foundation;

type

  BlocksWithAuthorizationHelper = public class
  public

    class method executeBlock(someBlock:block):operationTypesEnumeration;
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

  end;

end.