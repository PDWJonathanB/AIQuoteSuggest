codeunit 50101 "Secrets And Capabilities Setup"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        LearnMoreUrlTxt: Label 'YOUR_URL', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Find Quote Item") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Find Quote Item", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        IsolatedStorageWrapper.SetSecretKey('YOUR_SECRET_KEY');
        IsolatedStorageWrapper.SetDeployment('gpt-35-turbo');
        IsolatedStorageWrapper.SetEndpoint('YOUR_ENDPOINT');
    end;
}
