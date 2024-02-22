/// <summary>
/// Codeunit Generate Quote Proposal (ID 50102).
/// </summary>
codeunit 50102 "Generate Quote Proposal"
{
    trigger OnRun()
    begin
        GenerateItemProposal();
    end;

    /// <summary>
    /// SetUserPrompt.
    /// </summary>
    /// <param name="InputUserPrompt">Text.</param>
    procedure SetUserPrompt(InputUserPrompt: Text)
    begin
        _UserPrompt := InputUserPrompt;
    end;

    /// <summary>
    /// SetsalesHeader.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    procedure SetsalesHeader(SalesHeader: Record "Sales Header")
    begin
        _SalesHeader := SalesHeader;
    end;

    /// <summary>
    /// SetSuggestionMode.
    /// </summary>
    /// <param name="SuggestionMode">Option Precise,Balanced,Creative.</param>
    procedure SetSuggestionMode(SuggestionMode: Option Precise,Balanced,Creative)
    begin
        _Temperature := 0;
        if SuggestionMode = SuggestionMode::Precise then _Temperature := 0;
        if SuggestionMode = SuggestionMode::Creative then _Temperature := 1;
        if SuggestionMode = SuggestionMode::Balanced then _Temperature := 0.5;
    end;

    /// <summary>
    /// SetBasedOnItemHistoryOnly.
    /// </summary>
    /// <param name="BasedOnItemHistoryOnly">Option yes,No.</param>
    procedure SetBasedOnItemHistoryOnly(BasedOnItemHistoryOnly: Option Yes,No)
    begin
        if BasedOnItemHistoryOnly = BasedOnItemHistoryOnly::Yes then _BasedOnItemHistoryOnly := _BasedOnItemHistoryOnly::Yes;
        if BasedOnItemHistoryOnly = BasedOnItemHistoryOnly::No then _BasedOnItemHistoryOnly := _BasedOnItemHistoryOnly::No;
    end;

    /// <summary>
    /// SetOnlyAvailableItem.
    /// </summary>
    /// <param name="OnlyAvailableItem">Option Yes,No.</param>
    procedure SetOnlyAvailableItem(OnlyAvailableItem: Option Yes,No)
    begin
        if OnlyAvailableItem = OnlyAvailableItem::Yes then _OnlyAvailableItem := _OnlyAvailableItem::Yes;
        if OnlyAvailableItem = OnlyAvailableItem::No then _OnlyAvailableItem := _OnlyAvailableItem::No;
    end;

    /// <summary>
    /// GetResult.
    /// </summary>
    /// <param name="TempCopilotItemProposal">Temporary VAR Record "Copilot Item Proposal".</param>
    procedure GetResult(var TempCopilotItemProposal: Record "Copilot Item Proposal" temporary)
    begin
        TempCopilotItemProposal.Copy(_TempCopilotItemProposal, true);
    end;

    /// <summary>
    /// GenerateItemProposal.
    /// </summary>
    procedure GenerateItemProposal()
    var
        Item: Record Item;
        TempXmlBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        TmpText: Text;
        Quantity: Decimal;
    begin
        TempBlob.CreateOutStream(OutStream);
        TmpText := Chat(GetSystemPrompt(), GetFinalUserPrompt(_UserPrompt));
        OutStream.WriteText(TmpText);
        TempBlob.CreateInStream(InStream);

        TempXmlBuffer.DeleteAll();
        TempXmlBuffer.LoadFromStream(InStream);

        Clear(OutStream);
        if TempXmlBuffer.FindSet() then
            repeat
                case TempXmlBuffer.Path of
                    '/items/item':
                        _TempCopilotItemProposal.Init();
                    '/items/item/number':
                        begin
                            _TempCopilotItemProposal.Validate("No.", UpperCase(CopyStr(TempXmlBuffer.GetValue(), 1, MaxStrLen(_TempCopilotItemProposal."No."))));
                            _TempCopilotItemProposal.Insert();
                        end;
                    '/items/item/quantity':
                        begin
                            Evaluate(Quantity, TempXmlBuffer.GetValue());
                            _TempCopilotItemProposal.Quantity := Quantity;
                            _TempCopilotItemProposal.Modify();
                        end;
                    '/items/item/explanation':
                        begin
                            _TempCopilotItemProposal.Explanation := CopyStr(TempXmlBuffer.GetValue(), 1, MaxStrLen(_TempCopilotItemProposal.Explanation));
                            _TempCopilotItemProposal."Full Explanation".CreateOutStream(OutStream);
                            OutStream.WriteText(TempXmlBuffer.GetValue());
                            _TempCopilotItemProposal.Modify();
                        end;
                end;
            until TempXmlBuffer.Next() = 0;

        if _OnlyAvailableItem = _OnlyAvailableItem::Yes then
            if _TempCopilotItemProposal.FindSet() then
                repeat
                    if Item.Get(_TempCopilotItemProposal."No.") then begin
                        Item.CalcFields(Inventory);
                        if Item.Inventory = 0 then
                            _TempCopilotItemProposal.Delete();
                    end;
                until _TempCopilotItemProposal.Next() = 0;
    end;

    /// <summary>
    /// Chat.
    /// </summary>
    /// <param name="ChatSystemPrompt">Text.</param>
    /// <param name="ChatUserPrompt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure Chat(ChatSystemPrompt: Text; ChatUserPrompt: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        Result: Text;
    begin
        // These funtions in the "Azure Open AI" codeunit will be available in Business Central online later this year.
        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", IsolatedStorageWrapper.GetEndpoint(), IsolatedStorageWrapper.GetDeployment(), IsolatedStorageWrapper.GetSecretKey());

        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Find Quote Item");

        AOAIChatCompletionParams.SetMaxTokens(2500);
        AOAIChatCompletionParams.SetTemperature(_Temperature);

        AOAIChatMessages.AddSystemMessage(ChatSystemPrompt);
        AOAIChatMessages.AddUserMessage(ChatUserPrompt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Result := AOAIChatMessages.GetLastMessage()
        else
            Error(AOAIOperationResponse.GetError());

        exit(Result);
    end;

    local procedure GetFinalUserPrompt(InputUserPrompt: Text) FinalUserPrompt: Text
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        Item: Record Item;
        Newline: Char;
    begin
        Newline := 10;
        FinalUserPrompt := 'These are list of Sales Invoice:' + Newline;
        Customer.Get(_SalesHeader."Sell-to Customer No.");
        if Customer.HistoricalDataStartDate <> 0D then
            SalesInvoiceLine.SetFilter("Posting Date", '%1..', Customer.HistoricalDataStartDate);
        SalesInvoiceLine.SetRange("Sell-to Customer No.", _SalesHeader."Sell-to Customer No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                FinalUserPrompt +=
                    'Number: ' + SalesInvoiceLine."No." + ', ' +
                    'Description:' + SalesInvoiceLine.Description + ', ' +
                    'Quantity:' + Format(SalesInvoiceLine.Quantity) + ', ' +
                    'OrderDate:' + Format(SalesInvoiceHeader."Order Date") + '.' + Newline;
            until SalesInvoiceLine.Next() = 0;

        FinalUserPrompt += Newline;

        if _BasedOnItemHistoryOnly = _BasedOnItemHistoryOnly::No then begin
            FinalUserPrompt += 'You can propose items from this list:' + Newline;
            if Item.FindSet() then
                repeat
                    FinalUserPrompt +=
                        'Number: ' + Item."No." + ', ' +
                        'Description:' + Item.Description + '.' + Newline;
                until Item.Next() = 0;
        end;

        FinalUserPrompt += Newline;
        if InputUserPrompt <> '' then
            FinalUserPrompt += 'To finish, I have some informations about context for this customer that can be helpful to help me : ' + InputUserPrompt + '.';
    end;

    local procedure GetSystemPrompt() SystemPrompt: Text
    begin
        SystemPrompt += 'The user will provide a list of Historical order for a customer containing only item number, item description, quantity and order date. Your task is to find items that can be proposed to this customer at this date ' + Format(_SalesHeader."Document Date");
        SystemPrompt += ' by using historical given by user.';
        SystemPrompt += 'Try to suggest several relevant items if possible.';
        SystemPrompt += 'The output should be in xml, containing item number (use number tag), quantity (use quantity tag) and explanation why this item was suggested with precise indication about why you selected this quantity and the relation with historical order date and current quote date. (use explanation tag)';
        SystemPrompt += 'Use items as a root level tag, use item as item tag.';
        SystemPrompt += 'Do not use line breaks or other special characters in explanation.';
        SystemPrompt += 'Skip empty nodes.';
    end;

    var
        _TempCopilotItemProposal: Record "Copilot Item Proposal" temporary;
        _SalesHeader: Record "Sales Header";
        _UserPrompt: Text;
        _Temperature: Decimal;
        _BasedOnItemHistoryOnly: Option Yes,No;
        _OnlyAvailableItem: Option Yes,No;
}
