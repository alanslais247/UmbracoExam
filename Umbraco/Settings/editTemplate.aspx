<%@ Page MasterPageFile="../masterpages/umbracoPage.Master" Language="c#" CodeBehind="EditTemplate.aspx.cs"
    ValidateRequest="false" AutoEventWireup="True" Inherits="Umbraco.Web.UI.Umbraco.Settings.EditTemplate" %>
<%@ Import Namespace="Umbraco.Core.IO" %>
<%@ Register TagPrefix="cc1" Namespace="umbraco.uicontrols" Assembly="controls" %>
<%@ Register TagPrefix="umb" Namespace="ClientDependency.Core.Controls" Assembly="ClientDependency.Core" %>

<asp:Content ID="DocTypeContent" ContentPlaceHolderID="DocType" runat="server">
    <!DOCTYPE html>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <umb:CssInclude ID="CssInclude1" runat="server" FilePath="splitbutton/splitbutton.css" PathNameAlias="UmbracoClient" />
    <umb:JsInclude ID="JsInclude" runat="server" FilePath="splitbutton/jquery.splitbutton.js" PathNameAlias="UmbracoClient" />
    <umb:JsInclude ID="JsInclude1" runat="server" FilePath="Editors/EditTemplate.js" PathNameAlias="UmbracoClient" />
    <script type="text/javascript">
        //this needs to be a global object for the doSubmit() to work
        var editor;

        jQuery(document).ready(function() {
            //create the editor
            editor = new Umbraco.Editors.EditTemplate({
                umbracoPath: '<%= IOHelper.ResolveUrl(SystemDirectories.Umbraco) %>',
                editorClientId: '<%= editorSource.ClientID %>',
                useMasterPages: <%=umbraco.UmbracoSettings.UseAspNetMasterPages.ToString().ToLower()%>,
                templateId: <%= Request.QueryString["templateID"] %>,
                masterTemplateId: jQuery('#<%= MasterTemplate.ClientID %>').val(),
                treeSyncPath: '<%=TemplateTreeSyncPath%>',
                text: {
                    templateErrorHeader: "<%= umbraco.ui.Text("speechBubbles", "templateErrorHeader") %>",
                    templateSavedHeader: "<%= umbraco.ui.Text("speechBubbles", "templateSavedHeader") %>",
                    templateErrorText: "<%= umbraco.ui.Text("speechBubbles", "templateErrorText") %>",
                    templateSavedText: "<%= umbraco.ui.Text("speechBubbles", "templateSavedText") %>"
                }
            });

            editor.init();
        });

        function doSubmit() {
            //this is called when the save button is clicked or invoked            
            editor.save(jQuery('#<%= NameTxt.ClientID %>').val(), jQuery('#<%= AliasTxt.ClientID %>').val(), UmbEditor.GetCode());
        }

        //TODO: the below should be refactored into being part of the EditTemplate.js class but have left it here for now since i don't have time.

        function umbracoTemplateInsertMasterPageContentContainer() {
            var master = document.getElementById('<%= MasterTemplate.ClientID %>')[document.getElementById('<%= MasterTemplate.ClientID %>').selectedIndex].value;
            if (master == "") master = 0;
            umbraco.presentation.webservices.legacyAjaxCalls.TemplateMasterPageContentContainer(<%=Request["templateID"] %>, master, umbracoTemplateInsertMasterPageContentContainerDo);
        }

        function umbracoTemplateInsertMasterPageContentContainerDo(result) {
            UmbEditor.Insert(result + '\n', '\n</asp\:Content>\n', '<%= editorSource.ClientID%>');
        }

        function changeMasterPageFile() {
            var editor = document.getElementById("<%= editorSource.ClientID %>");
            var templateDropDown = document.getElementById("<%= MasterTemplate.ClientID %>");

            var templateCode = UmbEditor.GetCode();
            var selectedTemplate = templateDropDown.options[templateDropDown.selectedIndex].id;
            var masterTemplate = "<%= umbraco.IO.SystemDirectories.Masterpages%>/" + selectedTemplate + ".master";

            if (selectedTemplate == "")
                masterTemplate = "<%= umbraco.IO.SystemDirectories.Umbraco%>/masterpages/default.master";

            var regex = /MasterPageFile=[~a-z0-9/._"-]+/im;

            if (templateCode.match(regex)) {
                templateCode = templateCode.replace(regex, 'MasterPageFile="' + masterTemplate + '"');

                UmbEditor.SetCode(templateCode);

            }
            else {
                //todo, spot if a directive is there, and if not suggest that the user inserts it.. 
                alert("Master directive not found...");
                return false;
            }
        }

        function insertContentElement(id) {

            //nasty hack to avoid asp.net freaking out because of the markup...
            var cp = 'asp:Content ContentPlaceHolderId="' + id + '"';
            cp += ' runat="server"';
            cp += '>\n\t<!-- Insert "' + id + '" markup here -->';

            UmbEditor.Insert('\n<' + cp, '\n</asp:Content' + '>\n', '<%= editorSource.ClientID %>');
        }

        function insertPlaceHolderElement(id) {

            var cp = 'asp:ContentPlaceHolder Id="' + id + '"';
            cp += ' runat="server"';
            cp += '>\n\t<!-- Insert default "' + id + '" markup here -->';

            UmbEditor.Insert('\n<' + cp, '\n</asp:ContentPlaceHolder' + '>\n', '<%= editorSource.ClientID %>');
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">
    <cc1:UmbracoPanel ID="Panel1" runat="server" Width="608px" Height="336px" hasMenu="true">
        <cc1:Pane ID="Pane7" runat="server" Height="44px" Width="528px">
            <cc1:PropertyPanel ID="pp_name" runat="server">
                <asp:TextBox ID="NameTxt" Width="350px" runat="server"></asp:TextBox>
            </cc1:PropertyPanel>
            <cc1:PropertyPanel ID="pp_alias" runat="server">
                <asp:TextBox ID="AliasTxt" Width="350px" runat="server"></asp:TextBox>
            </cc1:PropertyPanel>
            <cc1:PropertyPanel ID="pp_masterTemplate" runat="server">
                <asp:DropDownList ID="MasterTemplate" Width="350px" runat="server" />
            </cc1:PropertyPanel>
            <cc1:PropertyPanel ID="pp_source" runat="server">
                <cc1:CodeArea ID="editorSource" runat="server" CodeBase="HtmlMixed" EditorMimeType="text/html" ClientSaveMethod="doSubmit"
                    AutoResize="true" OffSetX="37" OffSetY="54"/>
            </cc1:PropertyPanel>
        </cc1:Pane>
    </cc1:UmbracoPanel>
    <div id="splitButton" style="display: inline; height: 23px; vertical-align: top;">
        <a href="#" id="sb" class="sbLink">
            <img alt="Insert Inline Razor Macro" src="../images/editor/insRazorMacro.png" title="Insert Inline Razor Macro"
                style="vertical-align: top;">
        </a>
    </div>
    <div id="codeTemplateMenu" style="width: 285px;">
        <asp:Repeater ID="rpt_codeTemplates" runat="server">
            <ItemTemplate>
                <div class="codeTemplate" rel="<%# DataBinder.Eval(Container, "DataItem.Key") %>">
                    <%# DataBinder.Eval(Container, "DataItem.Value") %>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <div id="splitButtonMacro" style="display: inline; height: 23px; vertical-align: top;">
        <a href="#" id="sbMacro" class="sbLink">
            <img alt="Insert Macro" src="../images/editor/insMacroSB.png" title="Insert Macro"
                style="vertical-align: top;">
        </a>
    </div>
    <div id="macroMenu" style="width: 285px">
        <asp:Repeater ID="rpt_macros" runat="server">
            <ItemTemplate>
                <div class="macro" rel="<%# DataBinder.Eval(Container, "DataItem.macroAlias")%>"
                    params="<%#  DoesMacroHaveSettings(DataBinder.Eval(Container, "DataItem.id").ToString()) %>">
                    <%# DataBinder.Eval(Container, "DataItem.macroName")%>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            UmbClientMgr.appActions().bindSaveShortCut();
        });
    </script>
</asp:Content>
