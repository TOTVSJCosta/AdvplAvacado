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

    ADD OPTION aMenu Title 'Incluir'    Action "ViewDef.AULA10_07"  OPERATION 3 ACCESS 0
    ADD OPTION aMenu Title 'Alterar'    Action "ViewDef.AULA10_07"  OPERATION 4 ACCESS 0
    ADD OPTION aMenu Title 'Visualizar' Action "ViewDef.AULA10_07"  OPERATION 2 ACCESS 0
    ADD OPTION aMenu Title 'Histórico'  Action 'U_Historico'        OPERATION 2 ACCESS 0
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
Return oView

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
        {'ZZ2_TASKID', 'ZZ1_ID'}}, ZA2->(IndexKey(1)))

    oModel:SetDescription("Integrações")
    oModel:GetModel("ZZ1MASTER"):SetDescription("Central de Integrações")
return oModel
