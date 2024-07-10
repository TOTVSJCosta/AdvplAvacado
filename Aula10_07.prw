#include "totvs.ch"


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

return FWMVCMenu("AULA10_07")


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
    local oModel := ModelDef() //FWLoadModel("AULA10_07") 

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZZ1", oStruZZ1, "ZZ1MASTER")

    oView:CreateHorizontalBox("BrwZZ1" , 40)
    oView:SetOwnerView("VIEW_ZZ1", "BrwZZ1")

    oView:AddOtherObject("WE_PANEL", {|oPanel| WenEngine(oPanel)})
    oView:CreateHorizontalBox('INFERIOR', 60)
    oView:CreateVerticalBox('EMBAIXOESQ', 50, 'INFERIOR')
    oView:CreateVerticalBox('EMBAIXODIR', 50, 'INFERIOR')

    oView:SetOwnerView('WE_PANEL', 'EMBAIXODIR')
    //oView:SetOwnerView( 'VIEW_ZA5', 'EMBAIXOESQ')
Return oView


static function ModelDef()
    local oStruZZ1  := FwFormStruct(1, "ZZ1")
    local oModel    := MPFormModel():New("MD_ZZ1")

    oModel:AddFields("ZZ1MASTER", nil, oStruZZ1)
    oModel:SetPrimaryKey({"ZZ1_FILIAL", "ZZ1_ID"})

    oModel:SetDescription("Integrações")
    oModel:GetModel("ZZ1MASTER"):SetDescription("Central de Integrações")
return oModel
