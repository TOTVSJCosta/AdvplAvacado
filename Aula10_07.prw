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
    local oModel := ModelDef()

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
    local jVCEP

    //cCEP := if(FWInputBox("Insira o CEP a ser consultado", M->A1_CEP)

    if !FWIsInCallStack("U_SA1CEP")
        cCEP := FWInputBox("Insira o CEP a ser consultado")
    else
        cCEP := M->A1_CEP
    endif

    oRest:SetPath('/' + cCEP + "/json")

    if oRest:Get()
        cCEP  := decodeUTF8(oRest:GetResult())
        jVCEP := jsonObject():New()
        jVCEP:fromJSON(cCEP)

        if !jVCEP:hasProperty("erro")
            FWFldPut("A1_END", jVCEP["logradouro"])
            FWFldPut("A1_EST", jVCEP["uf"])
            FWFldPut("A1_BAIRRO", jVCEP["bairro"])
            FWFldPut("A1_COD_MUN", substr(jVCEP["ibge"], 3))
            FWFldPut("A1_MUN", jVCEP["localidade"])
            FWFldPut("A1_IBGE", jVCEP["ibge"])
            FWFldPut("A1_COMPLEM", jVCEP["complemento"])
            FWFldPut("A1_DDD", jVCEP["ddd"])
            GravaLog(.t., cCEP)
        else
            cCEP := "CEP nao localizado: " + M->A1_CEP
            Aviso("API ViaCEP", cCEP)
            GravaLog(.f., cCEP)
        endif
    else
        cCEP := decodeUTF8(oRest:cResult)
        msgAlert(cCEP, oRest:GetLastError())
        GravaLog(.f., cCEP)
    endif

return

static function GravaLog(lOK, cResult)
    local oModel := FWLoadModel("MVCZZ2")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    FWFldPut("ZZ2_STATUS", if(lOK, 'S', 'E'))
    FWFldPut("ZZ2_DATAEX", Date())
    FWFldPut("ZZ2_HORAEX", Time())
    FWFldPut("ZZ2_TASKID", ZZ1->ZZ1_ID)
    FWFldPut("ZZ2_RESULT", cResult)

    if oModel:VldData() .and. oModel:CommitData()
        lOK := .T.
    else
        lOK := .F.
    endif

    If(lOK, nil, FWAlertError(VarInfo("Erro gravação do Historico", oModel:GetErrorMessage(),, .f.)))

    oModel:DeActivate()

/*
    RecLock("ZZ2", .t.)
        ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
        ZZ2->ZZ2_ID := GetSX8Num("ZZ2", "ZZ2_ID")
        ZZ2->ZZ2_STATUS := if(lOK, 'S', 'E')
        ZZ2->ZZ2_DATAEX := Date()
        ZZ2->ZZ2_HORAEX := Time()
        ZZ2->ZZ2_TASKID := ZZ1->ZZ1_ID
        ZZ2->ZZ2_RESULT := cResult
    ZZ2->(msUnlock())
*/
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

user function SA1CEP()
    cIntID := GetNewPar("ES_SA1VCEP", "001")

    ZZ1->(dbSetOrder(5))
    if ZZ1->(dbSeek(xFilial("ZZ1") + cIntID))
        ExecInt()
    else
        FWAlertWarning("Não foi possível executar a integração " + cIntID, "API VIA CEP")
    endif
return .t.
