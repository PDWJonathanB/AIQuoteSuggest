/// <summary>
/// Page Copilot Quote Proposal (ID 50100).
/// </summary>
page 50100 "Copilot Quote Proposal"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Suggest item with Copilot';

    layout
    {
        area(PromptOptions)
        {
            field(OnlyAvailableItem; _OnlyAvailableItem)
            {
                ApplicationArea = All;
                OptionCaption = 'Yes,No';
                ToolTip = 'Only propose available items';
                Caption = 'Only Available Items';
            }
            field(SuggestionMode; _SuggestionMode)
            {
                ApplicationArea = All;
                OptionCaption = 'Precise,Balanced,Creative';
                ToolTip = 'Set the suggestion mode of Copilot';
                Caption = 'Suggestion Mode';
            }
            field(BasedOnItemHistoryOnly; _BasedOnItemHistoryOnly)
            {
                ApplicationArea = All;
                OptionCaption = 'Yes,No';
                ToolTip = 'Say yes if copilot can suggest items that this customer never ordered';
                Caption = 'Based on item history only';
            }

        }
        area(Prompt)
        {
            label(InformationAboutCustomer)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Help Copilot by writing here some informations you know about your customer that can impact futures orders ...';
            }
            field(CustomerInfo; _CustomerInfo)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;


                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }

        area(Content)
        {
            part(CopilotItemProposal; "Copilot Item Proposal")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate Item proposal with Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
                ToolTip = 'Add selected Items to quote';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard Items proposed by Dynamics 365 Copilot.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate Items proposal with Dynamics 365 Copilot.';
                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption := 'Suggest Quote for ' + _CustomerName + ' with Copilot';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then
            CurrPage.CopilotItemProposal.Page.SaveSubsForQuote(_SalesHeader);
    end;

    local procedure RunGeneration()
    var
        Attempts: Integer;
        ErrorSomethingWrongLbl: Label 'Something went wrong. Please try again. %1', comment = '%1="Last Error"';
    begin
        CurrPage.Caption := 'Suggested items for ' + _CustomerName;
        _GenerateQuoteProposal.SetUserPrompt(_CustomerInfo);
        _GenerateQuoteProposal.SetsalesHeader(_SalesHeader);
        _GenerateQuoteProposal.SetSuggestionMode(_SuggestionMode);
        _GenerateQuoteProposal.SetOnlyAvailableItem(_OnlyAvailableItem);
        _GenerateQuoteProposal.SetBasedOnItemHistoryOnly(_BasedOnItemHistoryOnly);

        _TempCopilotItemProposal.Reset();
        _TempCopilotItemProposal.DeleteAll();

        Attempts := 0;
        while _TempCopilotItemProposal.IsEmpty and (Attempts < 5) do begin
            if _GenerateQuoteProposal.Run() then
                _GenerateQuoteProposal.GetResult(_TempCopilotItemProposal);
            Attempts += 1;
        end;

        if (Attempts < 5) then
            Load(_TempCopilotItemProposal)
        else
            Error(ErrorSomethingWrongLbl, GetLastErrorText());
    end;

    /// <summary>
    /// SetSalesHeader.
    /// </summary>
    /// <param name="Salesheader">Record "Sales Header".</param>
    procedure SetSalesHeader(Salesheader: Record "Sales Header")
    var
        Customer: Record Customer;
        ErrorFindCustomerLbl: Label 'Unable to find customer %1', comment = '%1="Customer No"';
    begin
        if Customer.Get(Salesheader."Sell-to Customer No.") then begin
            _SalesHeader := Salesheader;
            _CustomerName := Customer.Name;
        end else
            Error(ErrorFindCustomerLbl, Salesheader."Sell-to Customer No.");
    end;

    /// <summary>
    /// Load.
    /// </summary>
    /// <param name="TempCopilotItemProposal">Temporary VAR Record "Copilot Item Proposal".</param>
    procedure Load(var TempCopilotItemProposal: Record "Copilot Item Proposal" temporary)
    begin
        CurrPage.CopilotItemProposal.Page.Load(TempCopilotItemProposal);

        CurrPage.Update(false);
    end;

    var
        _SalesHeader: Record "Sales Header";
        _TempCopilotItemProposal: Record "Copilot Item Proposal" temporary;
        _GenerateQuoteProposal: Codeunit "Generate Quote Proposal";
        _CustomerInfo: Text;
        _CustomerName: Text[100];
        _OnlyAvailableItem: Option Yes,No;
        _SuggestionMode: Option Precise,Balanced,Creative;
        _BasedOnItemHistoryOnly: Option Yes,No;
}
