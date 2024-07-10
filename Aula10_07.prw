#include "totvs.ch"


user function Aula10_07()
    //AxCadastro("SB1", "Produtos - Customizado")
    //mBrowse(,,,, "SA3")

    local oBrowse := FWmBrowse():New()

    oBrowse:SetAlias("SA2")
    oBrowse:SetDescription("Fornecedores - FWmBrowse")
    oBrowse:SetMenuDef("AULA10_07")
    oBrowse:DisableDetails()

    oBrowse:Activate()
return

static function MenuDef()

return FWMVCMenu("AULA10_07")




static function ViewDef()
    local oView := FWFormView():New()
    local oStruSA2 := FWFormStruct(2, "SA2")
    local oModel := ModelDef() //FWLoadModel("AULA10_07")

    oView:SetModel(oModel)
    oView:AddField("VIEW_SA2", oStruSA2, "SA2MASTER")

    oView:CreateHorizontalBox("BrwSA2" , 50)
    oView:SetOwnerView("VIEW_SA2", "BrwSA2")
return oView


static function ModelDef()
    local oStruSA2  := FwFormStruct(1, "SA2")
    local oModel    := MPFormModel():New("MD_SA2")

    oModel:AddFields("SA2MASTER", nil, oStruSA2)
    oModel:SetDescription("Fornecedores")
    oModel:GetModel("SA2MASTER"):SetDescription("Cadastro de Fornecedores")
return oModel
