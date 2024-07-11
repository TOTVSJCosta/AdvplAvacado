#include "totvs.ch"
#include "FWMVCDef.ch"


user function Aula10_07()

    //rpcsetenv("99", "01")

    local oBrowse := FWmBrowse():New()

    oBrowse:SetAlias("ZZ1")
    oBrowse:SetDescription("Integrações")
    oBrowse:SetMenuDef("AULA10_07")
    oBrowse:DisableDetails()
    oBrowse:AddLegend("ZZ1_STATUS = 'H'", 'GREEN', "Habilitada")
    oBrowse:AddLegend("ZZ1_STATUS = 'D'", 'PINK', "Desabilitada")
    //oBrowse:SetFilterDefault("A2_TIPO $ if(__cUserID = '000000', 'FJX', 'FJ')")

    oBrowse:Activate()
return

static function MenuDef()
    local aMenu := {}

    ADD OPTION aMenu Title 'Incluir'    Action "ViewDef.AULA10_07" ;
        OPERATION MODEL_OPERATION_INSERT ACCESS 0

    ADD OPTION aMenu Title 'Alterar'    Action "ViewDef.AULA10_07" ;
        OPERATION MODEL_OPERATION_UPDATE ACCESS 0

    ADD OPTION aMenu Title 'Visualizar' Action "ViewDef.AULA10_07" ;
        OPERATION MODEL_OPERATION_VIEW ACCESS 0

    ADD OPTION aMenu Title 'Histórico'  Action 'U_Historico'       ;
        OPERATION MODEL_OPERATION_VIEW ACCESS 0
return aMenu

user function Historico()

return

/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author jcosta
    @since 10/07/2024
    @version 1.0
    @param nao utiliza
    @return oView, Object, Interface MVC para tabela ZZ1
/*/
Static Function ViewDef()
    local oView := FWFormView():New()
    local oStruZZ1 := FWFormStruct(2, "ZZ1")
    local oStruZZ2 := FWFormStruct(2, "ZZ2")
    local oModel := ModelDef() //FWLoadModel("AULA10_07") 

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZZ1", oStruZZ1, "ZZ1MASTER")

    oView:AddGrid('VIEW_ZZ2', oStruZZ2, 'ZZ2DETAIL' )

    oView:CreateHorizontalBox("BrwZZ1" , 40)
    oView:SetOwnerView("VIEW_ZZ1", "BrwZZ1")

    oView:CreateHorizontalBox('INFERIOR', 60)
    oView:SetOwnerView("VIEW_ZZ2", "INFERIOR")

    oView:EnableTitleView('VIEW_ZZ2', "Historico das execuções")
    oView:AddUserButton("Executar Integração", 'CLIPS', {|oView| ExecInt(oView)})
Return oView

static function ExecInt(oView)
    local cNomePE := allTrim(ZZ1->ZZ1_FUNCAO)

    if ZZ1->ZZ1_STATUS = 'D'
        msgAlert("Integração está desabilitada!" + CRLF + "Não é possível executar", "Exec desabilitada")
    else
        if ExistBlock(cNomePE)
            ExecBlock(cNomePE)
        endif
    endif
return

user function IntVCEP()
    local cCEP
    local cURL := allTrim(ZZ1->ZZ1_URL)
    local oRest := FWRest():New(cURL)
    //local oWebEng := TWebEngine():New()

    cCEP := FWInputBox("Insira o CEP a ser consultado", M->A1_CEP)

    oRest:SetPath('/' + cCEP + "/json")

    if oRest:Get()
        cCEP := oRest:GetResult()

        GravaLog(.t., cCEP)
    else
        cCEP := oRest:cResult
        msgAlert(cCEP, oRest:GetLastError())
        GravaLog(.f., cCEP)
    endif

return

static function GravaLog(lOK, cResult)
/*
    local oModel := FWLoadModel("AULA10_07")
    local oMdlZZ2 := oModel:GetModel("ZZ2DETAIL")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oMdlZZ2:SetValue("ZZ2_ID", GetSX8Num("ZZ2", "ZZ2_ID"))
    oMdlZZ2:SetValue("ZZ2_STATUS", if(lOK, 'S', 'E'))
    oMdlZZ2:SetValue("ZZ2_DATAEX", Date())
    oMdlZZ2:SetValue("ZZ2_HORAEX", Time())
    oMdlZZ2:SetValue("ZZ2_TASKID", ZZ1->ZZ1_ID)
    cResult := decodeUTF8(cResult)
    oMdlZZ2:SetValue("ZZ2_RESULT", cResult)

    if oMdlZZ2:VldData() .and. oMdlZZ2:CommitData()
        lOK := .T.
    else
        lOK := .F.
    endif

    If(lOK, nil, FWAlertError(VarInfo("Erro gravação do Historico", oModel:GetErrorMessage(),, .f.)))

    oModel:DeActivate()
*/

    RecLock("ZZ2", .t.)
        ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
        ZZ2->ZZ2_ID := GetSX8Num("ZZ2", "ZZ2_ID")
        ZZ2->ZZ2_STATUS := if(lOK, 'S', 'E')
        ZZ2->ZZ2_DATAEX := Date()
        ZZ2->ZZ2_HORAEX := Time()
        ZZ2->ZZ2_TASKID := ZZ1->ZZ1_ID
        ZZ2->ZZ2_RESULT := decodeUTF8(cResult)
    ZZ2->(msUnlock())
return

user function IntSB1()
return

static function WebEngine(oPanel)
    local oWebEng := TWebEngine():New(oPanel)

    oWebEng:navigate("youtube.com")
    oWebEng:Align := CONTROL_ALIGN_ALLCLIENT
Return

static function PainelLE(oPanel)

    local oSEdit :=  TSimpleEditor():New(,, oPanel,,, "[ cText ]")
    oSEdit:Align := CONTROL_ALIGN_ALLCLIENT

return

static function ModelDef()
    local oStruZZ1  := FwFormStruct(1, "ZZ1")
    local oStruZZ2  := FwFormStruct(1, "ZZ2")
    local oModel    := MPFormModel():New("MD_ZZ1")

    oModel:AddFields("ZZ1MASTER", nil, oStruZZ1)
    oModel:SetPrimaryKey({"ZZ1_FILIAL", "ZZ1_ID"})

    oModel:AddGrid("ZZ2DETAIL", 'ZZ1MASTER', oStruZZ2) 
    oModel:SetRelation('ZZ2DETAIL', {{'ZZ2_FILIAL', 'xFilial("ZZ2")'}, ;
        {'ZZ2_TASKID', 'ZZ1_ID'}}, ZZ2->(IndexKey(1)))
    
    oModel:GetModel('ZZ2DETAIL'):SetOptional(.T.)
    oModel:GetModel('ZZ2DETAIL'):SetOnlyView (.T.)
    //oModel:GetModel('ZZ2DETAIL'):SetOnlyQuery (.T.)

    oModel:SetDescription("Integrações")
    oModel:GetModel("ZZ1MASTER"):SetDescription("Central de Integrações")
return oModel


user function SA1CEP()
    cIntID := GetNewPar("ES_SA1VCEP", "001")

    ZZ1->(dbSetOrder(5))
    if ZZ1->(dbSeek(xFilial("ZZ1") + cIntID))
        ExecInt()
    else
        FWAlertWarning("Não foi possível executar a integração " + cIntID, "API VIA CEP")
    endif

return .t.
