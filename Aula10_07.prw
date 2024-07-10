#include "totvs.ch"


user function Aula10_07()
    //AxCadastro("SB1", "Produtos - Customizado")
    //mBrowse(,,,, "SA3")

    local oBrowse := FWmBrowse():New()

    oBrowse:SetAlias("SA2")
    oBrowse:SetDescription("Fornecedores - FWmBrowse")
    oBrowse:SetMenuDef("AULA10_07")


    oBrowse:Activate()
return

static function MenuDef()

return FWMVCMenu("AULA10_07")
