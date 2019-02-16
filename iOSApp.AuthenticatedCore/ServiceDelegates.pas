namespace iOSApp.AuthenticatedCore;

uses
  Foundation;

type

  StartupDelegate = public block;

  BuildStartupDelegate = public block: Tuple of (BlockResults: array of Integer, InnerBlock : Block);

end.