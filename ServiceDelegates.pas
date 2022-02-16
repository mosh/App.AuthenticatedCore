namespace App.AuthenticatedCore;

uses
  Foundation;

type

  SimpleDelegate = public block;

  BuildStartupDelegate = public block: Tuple of (BlockResults: array of Integer, InnerBlock : Block);

end.