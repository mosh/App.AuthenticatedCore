namespace AuthenticatedCoreTestApp;


uses
  App.AuthenticatedCore;

type
  TestService = public class(AuthenticatedServiceBase)
  private
  protected
  public
    method SomeMethod;
    begin
      HandleAuthenticatedServiceCall(method begin end);

    end;
  end;

end.