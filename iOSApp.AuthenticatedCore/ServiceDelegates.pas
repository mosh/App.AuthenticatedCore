namespace iOSApp.AuthenticatedCore;

uses
  Foundation;

type

  StartupDelegate = public block ();
  BuildStartupDelegate = public block ():not nullable NSBlockOperation;

end.