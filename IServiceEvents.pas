﻿namespace App.AuthenticatedCore;

uses
  Foundation;

type

  IServiceEvents = public Interface

    method OnError(e:NSException);

    method OnNotAuthorized(initiatedAction:InitiatedActionEnumeration);

    method OnAuthorized;

    method OnAuthorizingDifference (newEmail:NSString; oldEmail:NSString):Boolean;

  end;

end.