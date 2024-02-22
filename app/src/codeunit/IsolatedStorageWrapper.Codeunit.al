codeunit 50100 "Isolated Storage Wrapper"
{
    SingleInstance = true;
    Access = Internal;

    var
        IsolatedStorageSecretKeyKeyLbl: Label 'CopilotToolkitSecret', Locked = true;
        IsolatedStorageDeploymentKeyLbl: Label 'CopilotToolkitDeployment', Locked = true;
        IsolatedStorageEndpointKeyLbl: Label 'CopilotToolkitEndpoint', Locked = true;

    procedure GetSecretKey() SecretKey: Text
    begin
        IsolatedStorage.Get(IsolatedStorageSecretKeyKeyLbl, SecretKey);
    end;

    procedure GetDeployment() Deployment: Text
    begin
        IsolatedStorage.Get(IsolatedStorageDeploymentKeyLbl, Deployment);
    end;

    procedure GetEndpoint() Endpoint: Text
    begin
        IsolatedStorage.Get(IsolatedStorageEndpointKeyLbl, Endpoint);
    end;

    procedure SetSecretKey(SecretKey: Text)
    begin
        IsolatedStorage.Set(IsolatedStorageSecretKeyKeyLbl, SecretKey);
    end;

    procedure SetDeployment(Deployment: Text)
    begin
        IsolatedStorage.Set(IsolatedStorageDeploymentKeyLbl, Deployment);
    end;

    procedure SetEndpoint(Endpoint: Text)
    begin
        IsolatedStorage.Set(IsolatedStorageEndpointKeyLbl, Endpoint);
    end;

}