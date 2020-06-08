namespace iOSApp.AuthenticatedCore;

type
    operationTypesEnumeration = public enum (none, completed, authenticationRequired, exception, UnableToContinue);

    InitiatedActionEnumeration = public enum(Unknown, Sync, Startup);

    StateEnumeration = public enum(None, Sync, Startup);


end.